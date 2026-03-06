#' Quantile-remap welfare within groups
#'
#' Generates synthetic welfare values that preserve the per-group weighted mean
#' of the original data using quantile interpolation and ratio scaling.
#'
#' @param dt A `data.table` with at least columns `welfare` and `weight`.
#' @param grp_col Character. Name of the grouping column (`"area"` or
#'   `"reporting_level"`). If all values are `NA`, data is treated as a single
#'   group.
#' @param n_obs Integer. Total number of synthetic observations to generate.
#'
#' @return A `data.table` with columns `welfare`, `weight`, and `<grp_col>`.
#' @keywords internal
synth_welfare_qmap <- function(dt, grp_col, n_obs) {

  # --- handle grouping --------------------------------------------------
  grp_vals <- dt[[grp_col]]
  all_na   <- all(is.na(grp_vals))

  if (all_na) {
    # Treat entire dataset as one group
    groups <- list(list(
      grp_value  = NA,
      grp_dt     = dt,
      grp_share  = 1
    ))
  } else {
    # Drop NAs in group column for share computation
    dt_valid  <- dt[!is.na(get(grp_col))]
    total_w   <- sum(dt_valid$weight)
    uvals     <- unique(dt_valid[[grp_col]])

    groups <- lapply(uvals, function(gv) {
      grp_dt   <- dt_valid[get(grp_col) == gv]
      grp_share <- sum(grp_dt$weight) / total_w
      list(grp_value = gv, grp_dt = grp_dt, grp_share = grp_share)
    })
  }

  # --- synthesise per group ---------------------------------------------
  result_list <- lapply(groups, function(g) {

    n_grp <- max(1L, floor(n_obs * g$grp_share))

    orig_welfare <- g$grp_dt$welfare
    orig_weight  <- g$grp_dt$weight

    # Remove NAs from welfare for quantile computation
    valid_idx <- !is.na(orig_welfare)
    if (!any(valid_idx)) {
      # All welfare NA — return NAs
      out <- data.table::data.table(
        welfare = rep(NA_real_, n_grp),
        weight  = rep(1 / n_grp, n_grp)
      )
      out[, (grp_col) := g$grp_value]
      return(out)
    }

    orig_welfare_v <- orig_welfare[valid_idx]

    # Quantile-remap: draw n_grp values from the empirical quantile function
    probs        <- seq(0, 1, length.out = n_grp)
    synth_welf   <- stats::quantile(orig_welfare_v, probs = probs, type = 7,
                                    names = FALSE)
    synth_weight <- rep(1 / n_grp, n_grp)

    # Ratio-scale to match original weighted mean
    orig_wmean  <- stats::weighted.mean(orig_welfare[valid_idx],
                                        orig_weight[valid_idx])
    synth_wmean <- stats::weighted.mean(synth_welf, synth_weight)

    if (synth_wmean > 0) {
      synth_welf <- synth_welf * (orig_wmean / synth_wmean)
    }

    out <- data.table::data.table(
      welfare = synth_welf,
      weight  = synth_weight
    )
    out[, (grp_col) := g$grp_value]
    out
  })

  data.table::rbindlist(result_list)
}


#' Synthesise a single survey_data file
#'
#' Reads one survey file, generates synthetic welfare via quantile-remapping
#' grouped by `area`, preserves all original column names and types, and writes
#' to the output directory as `.fst`.
#'
#' @param file_path Character. Full path to the original survey file.
#' @param output_dir Character. Directory where the synthetic `.fst` is written.
#' @param pct Numeric in (0, 1]. Fraction of original rows to generate.
#'
#' @return The output file path (invisibly).
#' @keywords internal
synth_svy_file <- function(file_path, output_dir, pct) {

  dt <- load_files_pip(file_path)

  orig_names <- names(dt)
  orig_types <- vapply(dt, class, character(1))
  n_orig     <- nrow(dt)
  n_obs      <- max(1L, ceiling(n_orig * pct))

  # --- synthesise welfare/weight/area -----------------------------------
  synth_core <- synth_welfare_qmap(dt, grp_col = "area", n_obs = n_obs)

  # --- carry forward other columns (scalar / constant columns) ----------
  other_cols <- setdiff(orig_names, c("welfare", "weight", "area"))

  if (length(other_cols) > 0) {
    # For each non-core column, check if it has a single unique value
    # If so, replicate it; otherwise resample from original
    for (col in other_cols) {
      uvals <- unique(dt[[col]])
      if (length(uvals) == 1L) {
        data.table::set(synth_core, j = col, value = rep(uvals, n_obs))
      } else {
        # Resample from original, preserving type
        sampled <- sample(dt[[col]], size = n_obs, replace = TRUE)
        data.table::set(synth_core, j = col, value = sampled)
      }
    }
  }

  # Ensure column order matches original
  data.table::setcolorder(synth_core, intersect(orig_names, names(synth_core)))

  # --- write output ------------------------------------------------------
  out_file <- fs::path(output_dir, fs::path_file(file_path))
  # Ensure output has .fst extension
  if (fs::path_ext(out_file) != "fst") {
    out_file <- fs::path_ext_set(out_file, "fst")
  }
  fst::write_fst(synth_core, path = out_file)

  invisible(out_file)
}


#' Synthesise a single lineup_data file
#'
#' Reads one lineup file, generates synthetic welfare via quantile-remapping
#' grouped by `reporting_level`, recomputes derived columns (`cw`, `cwy`,
#' `cwy2`, `cwylog`, `index`) from the synthetic welfare, and writes to the
#' output directory as `.fst`.
#'
#' @param file_path Character. Full path to the original lineup file.
#' @param output_dir Character. Directory where the synthetic `.fst` is written.
#' @param pct Numeric in (0, 1]. Fraction of original rows to generate.
#'
#' @return The output file path (invisibly).
#' @keywords internal
synth_lineup_file <- function(file_path, output_dir, pct) {

  dt <- load_files_pip(file_path)

  orig_names <- names(dt)
  n_orig     <- nrow(dt)
  n_obs      <- max(1L, ceiling(n_orig * pct))

  # --- synthesise welfare/weight/reporting_level -------------------------
  synth_core <- synth_welfare_qmap(dt, grp_col = "reporting_level",
                                   n_obs = n_obs)

  # Sort by reporting_level and welfare for cumulative computations
  data.table::setorderv(synth_core, c("reporting_level", "welfare"))

  # --- recompute derived columns from synthetic welfare ------------------
  synth_core[, `:=`(
    cw     = weight,
    cwy    = weight * welfare,
    cwy2   = weight * welfare * welfare,
    cwylog = log(pmax(welfare, 1e-10)) * weight,
    index  = seq_len(.N) - 1L
  ), by = reporting_level]

  # --- carry forward any remaining columns ------------------------------
  known_cols <- c("welfare", "weight", "reporting_level",
                  "cw", "cwy", "cwy2", "cwylog", "index")
  other_cols <- setdiff(orig_names, known_cols)

  if (length(other_cols) > 0) {
    for (col in other_cols) {
      uvals <- unique(dt[[col]])
      if (length(uvals) == 1L) {
        data.table::set(synth_core, j = col, value = rep(uvals, n_obs))
      } else {
        sampled <- sample(dt[[col]], size = n_obs, replace = TRUE)
        data.table::set(synth_core, j = col, value = sampled)
      }
    }
  }

  # Ensure column order matches original
  data.table::setcolorder(synth_core, intersect(orig_names, names(synth_core)))

  # --- write output ------------------------------------------------------
  out_file <- fs::path(output_dir, fs::path_file(file_path))
  if (fs::path_ext(out_file) != "fst") {
    out_file <- fs::path_ext_set(out_file, "fst")
  }
  fst::write_fst(synth_core, path = out_file)

  invisible(out_file)
}
