#' Generate synthetic PIP data from a reference folder
#'
#' Takes a reference PIP API folder and creates a synthetic copy that mirrors
#' its structure. Folders `_aux` and `estimations` are copied verbatim. Root
#' files are copied except `cache.duckdb`. Survey micro files are synthesised
#' using quantile-remapping (preserving per-area weighted mean); files ending in
#' `_GROUP` or `_BIN` are copied directly. Lineup files are synthesised with
#' distribution-preserving quantile interpolation.
#'
#' @param input_path Character. Path to the reference PIP folder containing
#'   subfolders such as `_aux`, `estimations`, `survey_data`, `lineup_data`.
#' @param output_path Character. Path where the synthetic folder will be
#'   created. Will be created if it does not exist.
#' @param pct Numeric in (0, 1]. Fraction of original rows to generate for each
#'   synthesised file. Default is `1` (same number of rows as original).
#' @param parallel Logical. If `TRUE`, synthesises `survey_data` and
#'   `lineup_data` files in parallel using `future.apply::future_lapply()`.
#'   Requires the `future.apply` package and a `future::plan()` set by the
#'   user before calling. Default is `FALSE`.
#'
#' @return The output path (invisibly).
#' @export
fk_pip_ref <- function(input_path,
                       output_path,
                       pct = 1,
                       parallel = FALSE) {

  # ---- Validation --------------------------------------------------------


  if (!is.numeric(pct) || length(pct) != 1 || pct <= 0 || pct > 1) {
    cli::cli_abort("{.arg pct} must be a single number in (0, 1].")
  }

  if (!is.logical(parallel) || length(parallel) != 1) {
    cli::cli_abort("{.arg parallel} must be a single logical value.")
  }

  if (isTRUE(parallel)) {
    rlang::check_installed("future.apply",
                           reason = "to use parallel processing in fk_pip_ref()")
  }

  if (!dir.exists(input_path)) {
    cli::cli_abort("The reference folder {.path {input_path}} does not exist.")
  }

  # ---- Create output root ------------------------------------------------

  fs::dir_create(output_path)

  cli::cli_alert_info("Creating synthetic PIP folder in {.path {output_path}}")

  # ---- Mirror subfolder tree ---------------------------------------------

  # Get all subdirectories in the reference folder
  ref_dirs <- fs::dir_ls(input_path, type = "directory", recurse = TRUE)
  if (length(ref_dirs) > 0) {
    rel_dirs <- fs::path_rel(ref_dirs, start = input_path)
    fs::dir_create(fs::path(output_path, rel_dirs))
  }

  # ==== (a) Copy _aux and estimations verbatim ============================

  dirs_to_copy <- c("_aux", "estimations")

  for (d in dirs_to_copy) {
    src <- fs::path(input_path, d)
    if (fs::dir_exists(src)) {
      dst <- fs::path(output_path, d)

      # Recreate full nested subfolder structure
      sub_dirs <- fs::dir_ls(src, type = "directory", recurse = TRUE)
      if (length(sub_dirs) > 0) {
        rel_sub <- fs::path_rel(sub_dirs, start = src)
        fs::dir_create(fs::path(dst, rel_sub))
      } else {
        fs::dir_create(dst)
      }

      # Copy all files (recursively) preserving subfolder placement
      all_files <- fs::dir_ls(src, type = "file", recurse = TRUE)
      if (length(all_files) > 0) {
        rel_files <- fs::path_rel(all_files, start = src)
        fs::file_copy(all_files,
                      fs::path(dst, rel_files),
                      overwrite = TRUE)
      }

      # Remove _vintage subfolder if present
      vintage <- fs::path(dst, "_vintage")
      if (fs::dir_exists(vintage)) {
        fs::dir_delete(vintage)
      }

      cli::cli_alert_success("Copied {.path {d}} (including all subfolders)")
    }
  }

  # ==== (b) Copy root files except cache.duckdb ===========================

  root_files <- fs::dir_ls(input_path, type = "file")
  root_files <- root_files[fs::path_file(root_files) != "cache.duckdb"]

  if (length(root_files) > 0) {
    fs::file_copy(root_files,
                  fs::path(output_path, fs::path_file(root_files)),
                  overwrite = TRUE)
    cli::cli_alert_success(
      "Copied {length(root_files)} root file{?s} (excluding cache.duckdb)"
    )
  }

  # ==== (c) survey_data: synthesise micro, copy GROUP/BIN =================

  svy_dir <- fs::path(input_path, "survey_data")

  if (fs::dir_exists(svy_dir)) {

    svy_out <- fs::path(output_path, "survey_data")
    fs::dir_create(svy_out)

    svy_files <- fs::dir_ls(svy_dir, type = "file")

    if (length(svy_files) > 0) {

      # Helper to process one survey file
      process_svy <- function(f) {
        fname <- fs::path_file(f)
        is_group_bin <- grepl("_(GROUP|BIN)\\.[^.]+$", fname,
                              ignore.case = FALSE)
        if (is_group_bin) {
          fs::file_copy(f, fs::path(svy_out, fname), overwrite = TRUE)
        } else {
          synth_svy_file(file_path = f, output_dir = svy_out, pct = pct)
        }
        invisible(fname)
      }

      if (isTRUE(parallel)) {
        cli::cli_alert_info("Synthesising survey_data in parallel...")
        future.apply::future_lapply(svy_files, process_svy,
                                    future.seed = TRUE)
      } else {
        cli::cli_progress_bar("Synthesising survey_data",
                              total = length(svy_files))
        for (f in svy_files) {
          process_svy(f)
          cli::cli_progress_update()
        }
        cli::cli_progress_done()
      }

      cli::cli_alert_success("Processed {length(svy_files)} survey_data file{?s}")
    }
  }

  # ==== (d) lineup_data: synthesise all ===================================

  lineup_dir <- fs::path(input_path, "lineup_data")

  if (fs::dir_exists(lineup_dir)) {

    lineup_out <- fs::path(output_path, "lineup_data")
    fs::dir_create(lineup_out)

    lineup_files <- fs::dir_ls(lineup_dir, type = "file")

    if (length(lineup_files) > 0) {

      # Helper to process one lineup file
      process_lineup <- function(f) {
        synth_lineup_file(file_path = f, output_dir = lineup_out, pct = pct)
        invisible(fs::path_file(f))
      }

      if (isTRUE(parallel)) {
        cli::cli_alert_info("Synthesising lineup_data in parallel...")
        future.apply::future_lapply(lineup_files, process_lineup,
                                    future.seed = TRUE)
      } else {
        cli::cli_progress_bar("Synthesising lineup_data",
                              total = length(lineup_files))
        for (f in lineup_files) {
          process_lineup(f)
          cli::cli_progress_update()
        }
        cli::cli_progress_done()
      }

      cli::cli_alert_success(
        "Processed {length(lineup_files)} lineup_data file{?s}"
      )
    }
  }

  # ---- Done --------------------------------------------------------------

  cli::cli_alert_success("Synthetic PIP folder ready at {.path {output_path}}")

  invisible(output_path)
}
