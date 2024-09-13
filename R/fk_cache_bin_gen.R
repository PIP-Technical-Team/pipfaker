#' Fake data generator for cache bin data
#'
#' @param pip_files character vector with all `cache_file` location from `pip_cache_inventory`.
#' @param svy_sample number of surveys to sample from `cache_inventory`. Default is 20.
#' @param n_bins number of bins of data.table. Default is 400.
#' @param seed_svy Seed for sampling of surveys from `cache_inventory`. Default is 51089.
#'
#' @import collapse
#'
#' @return data.table
fk_cache_bin_gen <- function(pip_files,
                             svy_sample = 20,
                             n_bins = 400,
                             seed_svy = 51089) {


  ## WARNING IF FILES ARE LESS THAN 20.
  if (length(pip_files) < svy_sample){

    cli::cli_abort(c("The number of files from `pip_files` needs to be",
                     "larger than `svy_sample` (Default 20)"))

  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Select sample of surveys   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  svy_tst <- load_svys(pip_files,
                       seed_svy,
                       svy_sample)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create new dataset   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  fake_svy <- fk_uniq(svy_tst[[1]], n_bins)

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

  fake_svy <- fake_svy[
    , welfare := wbpip::md_compute_quantiles(w_vec_all, n_quantile = n_bins)
  ][
    , weight := 1/n_bins
  ]

  # As performed in pip_ingestion_pipeline::process_svy_data_to_cache:

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
