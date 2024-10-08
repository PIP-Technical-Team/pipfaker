#' Fake data generator for raw micro
#'
#' @param pip_files character vector with all `orig` files location from `pip_cache_inventory`.
#' @param svy_sample number of surveys to sample from `pip_cache_inventory`. Default is 20.
#' @param n_obs number of observation of data.table. Default is average of
#' observations of `svy_sample`.
#' @param seed_svy Seed for sampling of surveys from `pip_cache_inventory`. Default is 51089
#'
#' @import collapse
#'
#' @return data.table
fk_micro_gen <- function(pip_files,
                         svy_sample = 20,
                         n_obs = NULL,
                         seed_svy = 51089) {

  ## WARNING IF FILES ARE LESS THAN 20.
  if (length(pip_files) < svy_sample){

    cli::cli_abort(c("The number of files from `pip_files` needs to be",
                     "larger than `svy_sample` (Default 20)"))

    }


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Select random sample of surveys and load data ------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  svy_tst <- load_svys(pip_files,
                       seed_svy,
                       svy_sample)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create new data set   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if (is.null(n_obs)){
    n_obs <- collapse::rapply2d(svy_tst, nrow)
    n_obs <- round(collapse::fmean(collapse::unlist2d(n_obs)$V1))
  }

  fake_svy <- fk_uniq(svy_tst[[1]], n_obs)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Household and Person ID   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  n_hh <- round(n_obs/2)
  n_id_hh <- round(stats::rpois(n_hh, 2))
  n_id_hh <- rep(n_id_hh[n_id_hh!=0],4)

  fake_svy <- fake_svy[
    , hhid := rep(1:n_hh,times = n_id_hh[1:n_hh])[1:n_obs]
  ][
    , pid := data.table::rowidv(fake_svy, cols = "hhid")
  ]

  n_hh <- collapse::fndistinct(fake_svy$hhid)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Gender and Area   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #Note: generate area according to new hhid

  fake_svy <- fake_svy[
    , c("gender") := sample(c("male","female"),nrow(fake_svy),
                            prob=c(0.5,0.5), replace =TRUE)
  ][
    , c("area") := sample(c("urban","rural"), 1,
                          prob = c(0.3,0.7)), by = c("hhid")
  ]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Wealth and Weight   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Note: The sampling does not account for size of the household
  # (larger households tend to have higher consumption/income) and
  # it does not differentiate between consumption and income

  lw_vec_all <- c(0)

  for(j in 2:length(svy_tst)){
    w_vec <- svy_tst[[j]]$welfare[!is.na(svy_tst[[j]]$welfare)]
    w_vec <- unique(w_vec)
    lw_vec <- log(w_vec + 1 + abs(min(w_vec)))
    lw_vec_sc <- scale(lw_vec)
    lw_vec_smp <- sample(lw_vec_sc, 100, replace = TRUE)
    lw_vec_all <- rbind(lw_vec_all, lw_vec_smp)
  }

  lw_vec_all <- lw_vec_all[-1]
  w_vec_all <- exp(lw_vec_all)

  min_svy <- lapply(svy_tst, function(x) min(x$welfare[!is.na(x$welfare)]))
  w_vec_all <- w_vec_all + 1 + abs(mean(unlist(min_svy)))

  w_vec_smp <- data.frame(hhid = c(1:n_hh),
                          welfare = sample(w_vec_all,n_hh,replace = TRUE))
  fake_svy <- joyn::joyn(fake_svy, w_vec_smp,
                    by = "hhid",
                    match_type = "m:1",
                    reportvar = FALSE,
                    verbose = FALSE)

  fake_svy <- fake_svy[
    , weight := 1/n_obs
  ]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(fake_svy)

}
