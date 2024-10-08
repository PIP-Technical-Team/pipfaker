#' Fake PIP data for API
#'
#' This function recreates a fake (and smaller) version of the folder
#' needed for the PIP API either by using data from a specific path
#' (given by the user) or using the fixed fake data found in this package
#'
#' @param input_path file address to the PIP API data
#' @param output_path where to create new folder
#'
#' @return folder
fk_pip <- function(input_path = NULL,
                   output_path = NULL) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Checks   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Checks on path existence

  if(is.null(output_path)){
    output_path <- getwd()
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





    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Randomized data --------

    svy_ls <- fs::dir_ls(fs::path(input_path,"survey_data"))


    fk_svy_gen(svy_ls, nm_svy) # Any output needed?












  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Create empty folders --------

  input_path <- "E:/PIP/pipapi_data/20240627_2017_01_02_PROD"

  new_folders <- file.path("20240627_2017_01_02_PROD",c("survey_data",
                                                       "estimations",
                                                       "_aux"))

  fs::dir_create(path = output_path, new_folders)











  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(TRUE)

}

fk_svy_gen <- function(svy_ls,
                       n_svy = 100) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Separate by distribution type (maybe create func for this)   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  nm_svy <- tools::file_path_sans_ext(basename(svy_ls))

  svy_inf <- setDT(as.data.frame(nm_svy))[
    , tstrsplit(nm_svy, "_", names = c("country_code", "year", "survey_name",
                                       "rep_level", "welfare_type", "distribution_type"))
  ]

  collapse::add_vars(svy_inf) <- nm_svy

  # filter for each dist type and select those in svy_ls

  fk_svy <- fk_micro_gen(svy_ls)

  fst::write_fst(fk_svy, path = fs::path(output_path,new_folders[2],"svy_1.fst"))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(TRUE)

}
