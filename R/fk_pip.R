#' Fake PIP data for API
#'
#' This function recreates a fake (and smaller) version of the folder
#' needed for the PIP API either by using data from a specific path
#' (given by the user) or using the fixed fake data found in this package
#'
#' @param output_path where to create new folder
#' @param input_path file address to the PIP API data. Default is..
#'
#' @return folder
fk_pip <- function(output_path = NULL,
                   input_path = NULL) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Checks   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Checks output path exists

  if(is.null(output_path)){

    cli::cli_abort("Please specify the output_path",wrap = TRUE)
    #output_path <- getwd()
    #output_path <- "E:/PovcalNet/01.personal/wb535623/PIP/temp"
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Alert for output path --------

  cli::cli_alert_info("The fake PIP folder was created in {.path {output_path}}",wrap = TRUE)

  if(!is.null(input_path)){

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Create empty folders --------

    # List data directories under input_path

    # data_dirs  <- fs::dir_ls(input_path, type = "directory")
    # dirs_names <- basename(data_dirs)

    # vintage_pattern <-  pipapi:::create_vintage_pattern_call()
    # valid_dir <- pipapi:::id_valid_dirs(dirs_names      = dirs_names,
    #                            vintage_pattern = vintage_pattern$vintage_pattern)

    #valid_dir <- grepl("\\d{8}_\\d{4}_\\d{2}_\\d{2}_(PROD|TEST|INT)$", dirs_names)

    # data_dirs  <- data_dirs[valid_dir]
    # versions   <- dirs_names[valid_dir]

    # names(data_dirs) <- versions

    # new_folder <- file.path(versions[1],"survey_data")

    new_folders <- file.path(basename(input_path),
                            basename(fs::dir_ls(input_path, type = "directory")))

    fs::dir_create(path = output_path, new_folders)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Survey Data   ---------
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    svy_ls <- fs::dir_ls(fs::path(input_path,"survey_data"))

    svys <- sapply(svy_ls,
                   fk_svy_gen, output_path = output_path,
                   input_path = input_path,
                   n_obs = 400,
                   simplify = TRUE,
                   USE.NAMES = FALSE)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Return   ---------
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    return(svys)

  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Create empty folders --------

  new_folders <- file.path("20240627_2017_01_02_PROD",c("survey_data",
                                                       "estimations",
                                                       "_aux"))

  fs::dir_create(path = output_path, new_folders)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Survey Data   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  input_path <- "E:/PIP/pipapi_data/20240627_2017_01_02_PROD"

  svy_ls <- fs::dir_ls(fs::path(input_path,"survey_data"))

  svys <- sapply(svy_ls,
                 fk_svy_gen, output_path = output_path,
                                    input_path = input_path,
                                    n_obs = 400,
                 simplify = TRUE,
                 USE.NAMES = FALSE)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(svys)

}

#' Function to write new fake survey in `survey_data` folder
#'
#' @param svy_ls list of real surveys
#' @inheritParams fk_pip
#'
#' @return character fake name of survey
fk_svy_gen <- function(svy,
                       n_obs = 400,
                       output_path,
                       input_path) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Identify the info of svy---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # nm_svy <- tools::file_path_sans_ext(basename(svy_ls))

  # svy_inf <- setDT(as.data.frame(nm_svy))[
  #   , tstrsplit(nm_svy, "_", names = c("country_code", "year", "survey_name",
  #                                      "rep_level", "welfare_type", "distribution_type"))
  # ]
  #
  # collapse::add_vars(svy_inf) <- nm_svy

  # Note: This dataset treats all like microdata. We might need to filter for
  # each dist type and select those in svy_ls.

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Generate fake survey   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # fk_svy <- fk_micro_gen(svy_ls, n_obs = sample(500:1000,1))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create new data set   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #svy <- svy_ls[[1935]]

  svy_name <- basename(svy)

  svy_org <- load_files_pip(svy)

  if(all(is.na(svy_org))){

    fst::write_fst(svy_org,
                   path = fs::path(output_path,
                                   basename(input_path),
                                   "survey_data",
                                   paste0(svy_name)))
    print(svy_name)

    return(svy_name)
  }

  var_svy <- names(svy_org)

  svy_org <- svy_org[
    , name := svy_name
  ]

  fk_svy <- fk_uniq(svy_org, n_obs)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Household and Person ID   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  n_hh <- round(n_obs/2)
  n_id_hh <- round(stats::rpois(n_hh, 2))
  n_id_hh <- rep(n_id_hh[n_id_hh!=0],4)

  fk_svy <- fk_svy[
    , hhid := rep(1:n_hh,times = n_id_hh[1:n_hh])[1:n_obs]
  ][
    , pid := data.table::rowidv(fk_svy, cols = "hhid")
  ]

  n_hh <- collapse::fndistinct(fk_svy$hhid)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Gender and Area   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #Note: generate area according to new hhid

  fk_svy <- fk_svy[
    , c("gender") := sample(c("male","female"),nrow(fk_svy),
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

  w_vec <- svy_org$welfare[!is.na(svy_org$welfare)]
  w_vec <- unique(w_vec)
  min_svy <- min(w_vec)
  lw_vec <- log(w_vec + 1 + abs(min_svy))
  lw_vec_sc <- scale(lw_vec)
  lw_vec_smp <- sample(lw_vec_sc, n_hh, replace = TRUE)
  fk_w_vec <- exp(lw_vec_smp + 1 + abs(min_svy))

  fk_w_vec <- data.frame(hhid = c(1:n_hh),
                          welfare = fk_w_vec)

  fk_svy <- joyn::joyn(fk_svy, fk_w_vec,
                         by = "hhid",
                         match_type = "m:1",
                         reportvar = FALSE,
                         verbose = FALSE)

  fk_svy <- fk_svy[
    , weight := 1/n_obs
  ]

  fk_svy <-  fk_svy|>
    collapse::fselect(var_svy)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Print and Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  fst::write_fst(fk_svy,
                 path = fs::path(output_path,
                                 basename(input_path),
                                 "survey_data",
                                 paste0(svy_name)))

  return(svy_name)

}
