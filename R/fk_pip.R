#' Fake PIP data for API
#'
#' This function recreates a fake (and smaller) version of the folder
#' needed for the PIP API either by using data from a specific path
#' (given by the user) or using the fixed fake data found in this package
#'
#' @param output_path where to create new folder
#' @param input_path file address to the PIP API data. Default is..
#' @param n_obs observations for micro surveys. Default is 400.
#'
#' @return folder
fk_pip <- function(output_path = NULL,
                   input_path = NULL,
                   n_obs = 400) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Checks   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Checks output path exists --------

  # output_path <- "E:/PovcalNet/01.personal/wb535623/PIP/temp"

  if(is.null(output_path)){

    cli::cli_abort("Please specify the output_path",wrap = TRUE)

  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Alert for output path --------

  cli::cli_alert_info("The fake PIP folder was created in {.path {output_path}}",wrap = TRUE)

  if(!is.null(input_path)){

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Create empty folders   ---------
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    new_folders <- file.path(basename(input_path),
                            basename(fs::dir_ls(input_path,
                                                type = "directory")))

    fs::dir_create(path = output_path, new_folders)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Add Survey Data   ---------
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    svy_ls <- fs::dir_ls(fs::path(input_path,"survey_data"))

    svys <- sapply(svy_ls,
                   fk_svy_gen,
                   output_path = output_path,
                   input_path = input_path,
                   n_obs = n_obs,
                   simplify = TRUE,
                   USE.NAMES = FALSE)

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Add Aux Files and Estimations  ---------
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    dirs <- list("_aux","estimations") # Make it soft coded

    lapply(dirs, copy_dirs,
           input_path = input_path,
           output_path = output_path)

  }else{

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    ## Create empty folders --------

    new_folders <- file.path("20240627_2017_01_02_PROD",c("survey_data",
                                                          "estimations",
                                                          "_aux"))

    fs::dir_create(path = output_path, new_folders)

    # input_path <- "E:/PIP/pipapi_data/20240627_2017_01_02_PROD"

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # Add Survey Data   ---------
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # Steps
    # 1. Use list of surveys from the cache_inventory (20 surveys: 10 micro, 4 group, 6 bin).

    svy_ls <- fk_svy_ls

    # 2. Create fake surveys with previous surveys names and fk
    # survey in the package.

    svys <- sapply(svy_ls,
                   fk_svy_gen,
                   output_path = output_path,
                   n_obs = n_obs,
                   simplify = TRUE,
                   USE.NAMES = FALSE)


    # 3. Add aux and estimations from package (Size is 5MB and 8MB)


  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(invisible(TRUE))

}

#' Function to write new fake survey in `survey_data` folder
#'
#' @param svy Input surveys.
#' @param n_obs Observations for fake survey
#' @inheritParams fk_pip
#'
#' @return character name of survey
fk_svy_gen <- function(svy,
                       n_obs = 400,
                       output_path,
                       input_path = NULL) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Identify survey type and load ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # svy <- svy_ls[[2]]

  svy_name <- basename(svy)

  nm_svy <- tools::file_path_sans_ext(svy_name)

  svy_inf <- data.table::setDT(as.data.frame(nm_svy))[
    , data.table::tstrsplit(nm_svy, "_",
                names = c("country_code",
                          "year",
                          "survey_name",
                          "rep_level",
                          "welfare_type",
                          "survey_type"))
  ]

  if(!fs::file_exists(svy)){

    output_path <- fs::path(output_path,
             "20240627_2017_01_02_PROD")

    if(svy_inf$survey_type %in% c("GROUP", "BIN")){

      if(svy_inf$survey_type %in% c("BIN")){

        svy_org <- fk_cache_bin[, c("welfare","weight","area")]

        lw_vec <- wbpip::md_compute_lorenz(svy_org$welfare)

        w_vec <- wbpip:::sd_create_synth_vector(lw_vec$lorenz_welfare,
                                                lw_vec$lorenz_weight,
                                                mean = collapse::fmean(svy_org$welfare))$welfare

        fake_svy <- data.table(
          welfare = wbpip::md_compute_quantiles(w_vec, n_quantile = 400),
          weight = svy_org$weight,
          area = svy_org$area)

      }else{

        fake_svy <- fk_cache_group_gen()

      }

      fst::write_fst(fake_svy,
                     path = fs::path(output_path,
                                     "survey_data",
                                     paste0(svy_name,".fst")))

      return(nm_svy)
    }

    svy_org <- fk_micro[, c("welfare","weight","area")]

  }else{

    output_path <- fs::path(output_path,
                            basename(input_path))

    svy_org <- load_files_pip(svy)

  if(svy_inf$survey_type %in% c("GROUP","BIN")){

    fst::write_fst(svy_org,
                   path = fs::path(output_path,
                                   "survey_data",
                                   paste0(svy_name,".fst")))

    return(nm_svy)
  }

  }


  if(all(is.na(svy_org))){

    fst::write_fst(svy_org,
                   path = fs::path(output_path,
                                   "survey_data",
                                   paste0(svy_name,".fst")))

    cli::cli_alert_warning("The survey called {.val {svy_name}}
                           from {.path {input_path}} has only NA values.")

    return(nm_svy)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Generate fake survey   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  var_svy <- names(data.table::copy(svy_org))

  svy_org <- svy_org[
    , name := nm_svy
  ]

  fk_svy <- fk_uniq(svy_org, n_obs)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Gender and Area   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #Note: generate area according to percentage

  if(!any(names(fk_svy) %in% c("area"))){

    area_tb <- prop.table(table(svy_org$area, useNA = "ifany"))

    area_cat <- names(area_tb)

    fk_svy <- fk_svy[
        , c("area") := sample(area_cat,
                               n_obs,
                               replace = TRUE,
                              prob =  as.numeric(area_tb))
      ]
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Welfare and Weight   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  svy_org_nm <- svy_org[!is.na(svy_org$welfare),]

  w_vec <- svy_org_nm$welfare*svy_org_nm$weight

  fk_svy <- gen_welf(fk_svy,
                     w_vec,
                     n_obs)

  ### Weight (subject to change) ---------

  if(!any(names(fk_svy) %in% c("weight"))){

    fk_svy <- fk_svy[
      , weight := 1/sum(svy_org$weight)
      , by = area
    ]

  }

  fk_svy <- fk_svy|>
    collapse::fselect(var_svy)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Print and Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  fst::write_fst(fk_svy,
                 path = fs::path(output_path,
                                 "survey_data",
                                 paste0(svy_name,".fst")))

  return(nm_svy)

}

#' Copy files from a folder
#'
#' This function copy files using `fs::dir_copy` from and input folder to an
#' output folder and eliminates the `_vintage` folder (made explicitly to copy
#' `_aux` and `estimations` folders)
#'
#' @param dirs Name of the directory to be copy
#' @inheritParams fk_pip
#'
#' @return TRUE
copy_dirs <- function(dirs,
                      output_path,
                      input_path) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # computations   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  fs::dir_copy(path = fs::path(input_path,dirs),
               new_path = fs::path(output_path,
                                   basename(input_path),
                                   dirs),
               overwrite = TRUE)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Remove _vintage folder --------

  vintage_path <- fs::path(output_path,
                           basename(input_path),
                           dirs,"_vintage")

  if(fs::dir_exists(vintage_path)){

    fs::dir_delete(vintage_path)

  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ## Keep only qs and fst --------

  # if(dirs == "_aux"){
  #
  #   aux_ls <- fs::dir_ls(fs::path(output_path,
  #                                 basename(input_path),
  #                                 dirs))
  #
  #   lapply(aux_ls, del_files, ext_keep = "fst") #Change from qs
  #
  # } else if (dirs == "estimations"){
  #
  #   est_ls <- fs::dir_ls(fs::path(output_path,
  #                                 basename(input_path),
  #                                 dirs))
  #
  #   lapply(est_ls, del_files, ext_keep = "fst")
  #
  # }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(TRUE)

}

#
# gen_hh_pid <- function(fk_svy,
#                        n_obs,
#                        n_hh = round(n_obs/2)) {
#
#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   # computations   ---------
#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   # Runs a poison distribution with number of individuals per hh
#
#   #n_hh <- round(n_obs/2)
#   n_id_hh <- round(stats::rpois(n_hh, n_obs/n_hh))
#   n_id_hh <- rep(n_id_hh[n_id_hh!=0],4)
#
#   fk_svy <- fk_svy[
#     , hhid := rep(1:n_hh,times = n_id_hh[1:n_hh])[1:n_obs]
#   ][
#     , pid := data.table::rowidv(fk_svy, cols = "hhid")
#   ]
#
#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   # Return   ---------
#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   return(fk_svy)
#
# }

#' Function to generate a fake welfare vector
#'
#' @param fk_svy fake survey to attach the new vector
#' @param w_vec weighted welfare vector
#' @param n_obs number of observations of new vector
#'
#' @return data.base
gen_welf <- function(fk_svy,
                        w_vec,
                        n_obs) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # computations   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  w_vec <- unique(w_vec)
  min_svy <- min(w_vec)
  lw_vec <- log(w_vec + 1 + abs(min_svy))
  lw_vec_sc <- scale(lw_vec)
  lw_vec_smp <- sample(lw_vec_sc, n_obs, replace = TRUE)
  fk_w_vec <- exp(lw_vec_smp + 1 + abs(min_svy))
  fk_w_vec <- data.frame(welfare = fk_w_vec)

  fk_svy <- collapse::add_vars(fk_svy, fk_w_vec)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(fk_svy)

}
