#' Fake data generator for cache imputed
#'
#' @param n_obs number of observation per imputation.
#' @param n_sim number of imputations. Default is 50
#' @param d_type Either `D1` or `D2`
#' @param seed_svy Seed for sampling of surveys from `cache_inventory`
#'
#' @import collapse
#'
#' @return data.table
fk_cache_imputed_gen <- function(n_obs = NULL,
                                 n_sim = 50,
                                 d_type = "D2",
                                 seed_svy = 51089) {



  ### Load inventory (needs access to Y Drive) ------------

  cache_inventory <- pipload::pip_load_cache_inventory(version = "20240326_2017_01_02_PROD")
  cache_inventory$source <- stringr::str_split(cache_inventory$cache_id, "_", simplify = TRUE)[,6]
  cache_inventory$DV <- stringr::str_split(cache_inventory$cache_id, "_", simplify = TRUE)[,4]

  ### Choose only micro data

  #Note: dta is an internal file with a list of distribution_type

  ls_svy <- cache_inventory|>
    joyn::joyn(dta, by = "cache_id", match_type = "1:m",
                    y_vars_to_keep = "distribution_type",
                    keep = "left",
                    reportvar = FALSE,
                    verbose = FALSE)|>
    collapse::fsubset(distribution_type == "imputed" & DV == d_type)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Select sample of surveys   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ls_smp <- ls_svy[withr::with_seed(seed_svy,
                                    sample(1:nrow(ls_svy),
                                           1,
                                           replace=FALSE)),]

  svy_tst <- lapply(ls_smp$cache_file,load_files_pip)

  names(svy_tst) <- basename(ls_smp$cache_id)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Variables with unique values   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  svy_tst <- svy_tst[[1]]

  svy_tst_rural <- svy_tst[svy_tst$reporting_level=="rural",]

  var_uniq_rural <- c(0)

  for(j in 1:length(svy_tst_rural)){
    uniq <- collapse::fndistinct(svy_tst_rural[j], na.rm = FALSE)
    if(uniq==1){
      var_uniq_rural <- cbind(var_uniq_rural, collapse::funique(svy_tst_rural[j]))
    }
  }

  var_uniq_rural <- var_uniq_rural[-1]

  svy_tst_urban <- svy_tst[svy_tst$reporting_level=="urban",]

  var_uniq_urban <- c(0)

  for(j in 1:length(svy_tst_urban)){
    uniq <- collapse::fndistinct(svy_tst_urban[j], na.rm = FALSE)
    if(uniq==1){
      var_uniq_urban <- cbind(var_uniq_urban, collapse::funique(svy_tst_urban[j]))
    }
  }

  var_uniq_urban <- var_uniq_urban[-1]

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

  fake_svy <- collapse::rowbind(var_uniq_rural[rep(1,each=n_obs_rural),],
                                var_uniq_urban[rep(1,each=n_obs_urban),])

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

  fake_svy <- data.table::as.data.table(fake_svy)

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
