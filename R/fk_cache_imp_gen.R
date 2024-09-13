#' Fake data generator for cache imputed
#'
#' @param pip_files character vector with all `cache_file` location from `pip_cache_inventory`.
#' Needs to be larger than 5 characters.
#' @param n_obs number of observation per imputation.
#' @param n_sim number of imputations. Default is 50.
#' @param seed_svy Seed for sampling of surveys from `cache_inventory`
#'
#' @import collapse
#'
#' @return data.table
fk_cache_imputed_gen <- function(pip_files,
                                 n_obs = NULL,
                                 n_sim = 50,
                                 seed_svy = 51089) {

  ## WARNING IF FILES ARE LESS THAN 5.
  if (length(pip_files) < 5){

    cli::cli_abort(c("The number of files from `pip_files` needs to be",
                     "larger than 5"))

  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Select sample of surveys   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  svy_tst <- load_svys(pip_files,
                       seed_svy,
                       1)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create new dataset   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if (is.null(n_obs)){
    n_obs_rural <- nrow(svy_tst_rural)/max(as.numeric(svy_tst_rural$imputation_id))
    n_obs_urban <- nrow(svy_tst_urban)/max(as.numeric(svy_tst_urban$imputation_id))
  }else{
    n_obs_rural <- round(n_obs*(1/3))
    n_obs_urban <- n_obs - n_obs_rural
  }

  svy_tst <- svy_tst[[1]]
  svy_tst_rural <- svy_tst[svy_tst$reporting_level=="rural",]
  svy_tst_urban <- svy_tst[svy_tst$reporting_level=="urban",]

  fake_svy_rural <- fk_uniq(svy_tst_rural, n_obs_rural)
  fake_svy_urban <- fk_uniq(svy_tst_urban, n_obs_urban)

  fake_svy <- collapse::rowbind(fake_svy_rural,
                                fake_svy_urban)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Household ID   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  fake_svy$hhid <- data.table::rowidv(fake_svy)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Wealth and Weight   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ### Rural

  lw_vec_all <- c(0)

  for(j in 1:max(as.numeric(svy_tst_rural$imputation_id))){
    w_vec <- svy_tst_rural$welfare[as.numeric(svy_tst_rural$imputation_id)==j]
    w_vec <- unique(w_vec)
    lw_vec <- log(w_vec + 1 + abs(min(w_vec)))
    lw_vec_sc <- scale(lw_vec)
    lw_vec_smp <- sample(lw_vec_sc, 100, replace = TRUE)
    lw_vec_all <- rbind(lw_vec_all, lw_vec_smp)
  }

  lw_vec_all <- lw_vec_all[-1]
  w_vec_rural <- exp(lw_vec_all)
  w_vec_rural <- w_vec_rural + 1 + abs(min(svy_tst_rural$welfare))

  ### Urban

  lw_vec_all <- c(0)

  for(j in 1:max(as.numeric(svy_tst_urban$imputation_id))){
    w_vec <- svy_tst_urban$welfare[as.numeric(svy_tst_urban$imputation_id)==j]
    w_vec <- unique(w_vec)
    lw_vec <- log(w_vec + 1 + abs(min(w_vec)))
    lw_vec_sc <- scale(lw_vec)
    lw_vec_smp <- sample(lw_vec_sc, 100, replace = TRUE)
    lw_vec_all <- rbind(lw_vec_all, lw_vec_smp)
  }

  lw_vec_all <- lw_vec_all[-1]
  w_vec_urban <- exp(lw_vec_all)

  w_vec_urban <- w_vec_urban + 1 + abs(min(svy_tst_urban$welfare))

  ### Sample per imputation

  fake_imp <- data.table::copy(fake_svy[,`:=`(welfare = ifelse(reporting_level == "rural",
                                        sample(w_vec_rural,n_obs_rural,replace = TRUE),
                                        sample(w_vec_urban,n_obs_urban,replace = TRUE)),
                       imputation_id = 1)])

  for(i in 2:n_sim){
    dt <- data.table::copy(fake_svy[,`:=`(welfare = ifelse(reporting_level == "rural",
                              sample(w_vec_rural,n_obs_rural,replace = TRUE),
                              sample(w_vec_urban,n_obs_urban,replace = TRUE)),
                              imputation_id = i)])
    fake_imp <- collapse::rowbind(fake_imp,dt)
    rm(dt)
  }
  rm(fake_svy)

  fake_imp <- fake_imp[,
           weight := ifelse(reporting_level == "rural",
                            1/n_obs_rural,
                            1/n_obs_urban)]

  # As performed in pip_ingestion_pipeline::process_svy_data_to_cache:

  fake_imp <- fake_imp[
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
  return(fake_imp)

}
