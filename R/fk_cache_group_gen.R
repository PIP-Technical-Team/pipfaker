#' Fake data generator for cache group
#'
#' The group data is calculated from a synthetic vector
#' generated using the Indian rural data from 1983 (Datt, 1998).
#'
#' @param n_quantiles number of quantiles of data.table. Default is 20.
#'
#' @return data.table
fk_cache_group_gen <- function(n_quantiles = 20) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Load IND 1983   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  cache_inventory <- pipload::pip_load_cache_inventory(version = "20240326_2017_01_02_PROD")

  orig_file <- cache_inventory[cache_id=="IND_1983_NSS_D2_CON_GROUP","cache_file"]|>
    as.character()

  svy_ind <- load_files_pip(orig_file)

  svy_ind_rural <- svy_ind[svy_ind$reporting_level=="rural",]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Variables with unique values   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  var_dist <- collapse::fndistinct(svy_ind_rural, na.rm = FALSE)
  uniq     <- var_dist[var_dist==1]
  var_uniq <- collapse::funique(svy_ind_rural|>
                                  collapse::fselect(names(uniq)))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create new dataset   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  fake_svy <- data.table::as.data.table(var_uniq[rep(1,each=n_quantiles),])

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Wealth and Weight   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Note: We create a synthetic from the Datt data and create quantiles

  datt <- datt

  welfare <- wbpip:::sd_create_synth_vector(datt$lwelfare,datt$weight,mean = 109.90)$welfare

  fake_svy$welfare <- wbpip::md_compute_quantiles(welfare, n_quantile = n_quantiles)

  fake_svy$weight <- 1/n_quantiles

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
