#' Fake data generator for raw micro
#'
#' @param pip_files data.table with origin file location from `pip_cache_inventory`.
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
  if (nrow(pip_files)<20){

    cli::cli_abort(c("The number of files from `pip_files` needs to be",
                     "larger than `svy_sample` (Default 20)"))

    }


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Select random sample of surveys and load data ------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ls_smp <- pip_files[withr::with_seed(seed_svy,
                                    sample(1:nrow(pip_files),
                                           svy_sample,
                                           replace=FALSE)),]

  svy_tst <- lapply(ls_smp$orig,load_files_pip)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create new data set   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if (is.null(n_obs)){
    n_obs <- collapse::rapply2d(svy_tst, nrow)
    av_n_obs <- round(collapse::fmean(collapse::unlist2d(n_obs)$V1))
    n_obs <- av_n_obs
  }

  var_dist <- collapse::fndistinct(svy_tst[[1]], na.rm = FALSE)
  uniq     <- var_dist[var_dist==1]
  var_uniq <- collapse::funique(svy_tst[[1]]|>
                                  collapse::fselect(names(uniq)))

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

  #if(!("area" %in% names(fake_svy))){

  #Note: generate area according to new hhid

  fake_svy <- fake_svy[, c("area") := sample(c("urban","rural"), 1,
                              prob = c(0.3,0.7)), by = c("hhid")]

  #}

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
