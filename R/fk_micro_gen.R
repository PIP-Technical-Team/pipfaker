#' Fake data generator
#'
#' @param svy_sample number of surveys to sample from `pip_inventory`
#' @param n_obs number of observation of data.table. Default is average of
#' observations of `svy_sample`
#' @param seed_svy Seed for sampling of surveys from `pip_inventory`
#'
#' @return data.table
fk_micro_gen <- function(svy_sample = 20,
                         n_obs = NULL,
                         seed_svy = NULL) {

  ### set seed ---------

  if(is.null(seed_svy)){
    seed_svy <- 51089
  }

  ### Load inventory (needs access to Y Drive) ------------

  # pip_inventory <-
  #   pipload::pip_find_data(
  #     inv_file = "//w1wbgencifs01/pip/PIP-Data_QA/_inventory/inventory.fst",
  #     filter_to_pc = TRUE,
  #     maindir = "//w1wbgencifs01/pip/PIP-Data_QA/")

  cache_inventory <- pipload::pip_load_cache_inventory(version = "20240326_2017_01_02_PROD")
  cache_inventory$source <- stringr::str_split(cache_inventory$cache_id, "_", simplify = TRUE)[,6]

  ### Choose only micro data

  #Note: dta is an internal file with a list of distribution_type

  ls_svy <- cache_inventory|>
    joyn::joyn(dta, by = "cache_id", match_type = "1:m",
                    y_vars_to_keep = "distribution_type",
                    keep = "left",
                    reportvar = FALSE,
                    verbose = FALSE)|>
    collapse::fsubset(distribution_type == "micro")

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Select sample of surveys   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #ls_svy <- cache_inventory[cache_inventory$source=="GPWG",]

  ls_smp <- ls_svy[withr::with_seed(seed_svy,
                                    sample(1:nrow(ls_svy),
                                           svy_sample,
                                           replace=FALSE)),]

  svy_tst <- load_files_pip(ls_smp$orig)

  names(svy_tst) <- basename(ls_smp$survey_id)

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

  if (is.null(n_obs)){
    n_obs <- collapse::rapply2d(svy_tst, nrow)
    av_n_obs <- round(collapse::fmean(collapse::unlist2d(n_obs)$V1))
    n_obs <- av_n_obs
  }

  fake_svy <- var_uniq[rep(1,each=n_obs),]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Household and Person ID   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  n_hh <- round(n_obs/2)

  n_id_hh <- round(stats::rpois(n_hh, 2))

  n_id_hh <- rep(n_id_hh[n_id_hh!=0],4)

  fake_svy$hhid <- rep(1:n_hh,times = n_id_hh[1:n_hh])[1:n_obs]

  fake_svy <- data.table::setDT(fake_svy)

  fake_svy$pid <- data.table::rowidv(fake_svy, cols = "hhid")

  n_hh <- collapse::fndistinct(fake_svy$hhid)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Gender and Area   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  if(!("gender" %in% names(fake_svy))){

    fake_svy$gender <- sample(c("male","female"),
                             nrow(fake_svy),
                             prob=c(0.5,0.5),
                             replace =TRUE)
  }

  if(!("area" %in% names(fake_svy))){

    fake_svy <- fake_svy[, c("area") := sample(c("urban","rural"), 1,
                              prob = c(0.3,0.7)), by = c("hhid")]

  }

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
  fake_svy$weight <- 1/n_obs

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(fake_svy)

}
