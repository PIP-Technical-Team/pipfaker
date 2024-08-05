#' Fake data generator for cache bin data
#'
#' @param svy_sample number of surveys to sample from `cache_inventory`. Default is 20.
#' @param n_bins number of bins of data.table. Default is 400.
#' @param seed_svy Seed for sampling of surveys from `cache_inventory`
#'
#' @import collapse
#'
#' @return data.table
fk_cache_bin_gen <- function(svy_sample = 20,
                               n_bins = 400,
                               seed_svy = 51089) {

  ### Load inventory (needs access to Y Drive) ------------

  cache_inventory <- pipload::pip_load_cache_inventory(version = "20240326_2017_01_02_PROD")
  cache_inventory$source <- stringr::str_split(cache_inventory$cache_id, "_", simplify = TRUE)[,6]

  ### Choose only micro data

  #Note: dta is an internal file with a list of distribution_type

  ls_svy <- cache_inventory |>
    joyn::joyn(dta, by = "cache_id", match_type = "1:m",
                    y_vars_to_keep = "distribution_type",
                    keep = "left",
                    reportvar = FALSE,
                    verbose = FALSE)|>
    collapse::fsubset(distribution_type == "micro" & source == "BIN")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Select sample of surveys   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ls_smp <- ls_svy[withr::with_seed(seed_svy,
                                    sample(1:nrow(ls_svy),
                                           svy_sample,
                                           replace=FALSE)),]

  svy_tst <- load_files_cache(ls_smp$cache_file)

  names(svy_tst) <- basename(ls_smp$cache_id)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Variables with unique values   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  var_uniq <- c(0)

  for(j in 1:length(svy_tst[[1]])){
    uniq <- collapse::fndistinct(svy_tst[[1]][j], na.rm = FALSE)
    if(uniq==1){
      var_uniq <- cbind(var_uniq, collapse::funique(svy_tst[[1]][j]))
    }
  }
  var_uniq <- var_uniq[-1]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create new dataset   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  fake_svy <- var_uniq[rep(1,each=n_bins),]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Wealth and Weight   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  w_vec_all <- c(0)

  for(j in 2:length(svy_tst)){
    lw_vec <- wbpip::md_compute_lorenz(svy_tst[[j]]$welfare)
    w_vec <- wbpip:::sd_create_synth_vector(lw_vec$lorenz_welfare,
                                            lw_vec$lorenz_weight,
                                            mean = collapse::fmean(svy_tst[[j]]$welfare))$welfare
    w_vec_smp <- sample(w_vec, 100, replace = TRUE)
    w_vec_all <- rbind(w_vec_all, w_vec_smp)
  }

  fake_svy$welfare <- wbpip::md_compute_quantiles(w_vec_all, n_quantile = n_bins)
  fake_svy$weight <- 1/n_bins

  # As performed in pip_ingestion_pipeline::process_svy_data_to_cache:

  fake_svy <- data.table::as.data.table(fake_svy)

  fake_svy <- fake_svy[
    ,
    welfare_lcu := welfare
  ][
    ,
    welfare_ppp := wbpip::deflate_welfare_mean(
      welfare_mean = welfare_lcu,
      ppp          = ppp,
      cpi          = cpi
    )
  ]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(fake_svy)

}
