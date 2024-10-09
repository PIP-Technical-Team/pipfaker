#' Fake PIP data for API
#'
#' This function recreates a fake (and smaller) version of the folder
#' needed for the PIP API either by using data from a specific path
#' (given by the user) or using the fixed fake data found in this package
#'
#' @param output_path where to create new folder
#' @param input_path file address to the PIP API data. Default is..
#' @param n_svy Number of surveys in the `survey_data` folder. Default is the 50.
#'
#' @return folder
fk_pip <- function(output_path = NULL,
                   input_path = NULL,
                   n_svy = 50) {

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

    svy_nm <- replicate(n_svy, fk_svy_gen(svy_ls, output_path, input_path))

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Return   ---------
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    return(svy_nm)

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

  svy_nm <- replicate(n_svy, fk_svy_gen(svy_ls, output_path, input_path))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(svy_nm)

}

#' Function to write new fake survey in `survey_data` folder
#'
#' @param svy_ls list of real surveys
#' @inheritParams fk_pip
#'
#' @return character fake name of survey
fk_svy_gen <- function(svy_ls,
                       output_path,
                       input_path) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Identify the info of svy---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  nm_svy <- tools::file_path_sans_ext(basename(svy_ls))

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

  fk_svy <- fk_micro_gen(svy_ls, n_obs = sample(500:1000,1))

  rnd_name <- sample(nm_svy, 1)

  fst::write_fst(fk_svy,path = fs::path(output_path,basename(input_path),
                                 "survey_data",paste0(rnd_name, ".fst")))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(rnd_name)

}
