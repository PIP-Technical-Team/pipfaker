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
#'
#' @examples
fk_pip <- function(input_path = NULL,
                   output_path = NULL) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Checks   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # Checks on path existence

  if(is.null(output_path)){
    output_path <- getwd()
  }{

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

    new_folder <- file.path(basename(input_path),"survey_data")

    fs::dir_create(new_folder)


  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Create empty folders --------

  new_folder <- file.path("20240627_2017_01_02_PROD","survey_data")

  fs::dir_create(new_folder)




  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(TRUE)

}
