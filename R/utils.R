#' Load data from files in PIP drive
#'
#'
#' @param orig_file a file address
#' (usually `orig` or `cache_file` variable from `cache_inventory`)
#'
#' @return list
#'
load_files_pip <- function(orig_file) {

  # Warning:

  if(file.exists(orig_file) == FALSE){

    cli::cli_abort(c("Make sure you have access to PIP \\Y: Drive.",
                     "If you do not have have access you won't be able to",
                     "load cache PIP files and generate your own fake files.",
                     "You can use the fake data already provided by this package."))
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # computations   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ext <- orig_file |>
    fs::path_ext()

  if (ext == "qs") {
    dt <- qs::qread(orig_file) |>
      collapse::qDT()
  }
  if (ext == "fst") {
    dt <- fst::read_fst(orig_file, as.data.table = TRUE)
  }
  if (ext == "dta") {
    dt <- haven::read_dta(orig_file) |>
      collapse::qDT()
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(dt)

}

#' Load random surveys
#'
#' @inheritParams fk_cache_micro_gen
#'
#' @return data.table
load_svys <- function(pip_files,
                    seed_svy,
                    svy_sample) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # computations   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ls_smp <- pip_files[withr::with_seed(seed_svy,
                                       sample(1:length(pip_files),
                                              svy_sample,
                                              replace=FALSE))]

  svy_tst <- lapply(ls_smp, load_files_pip)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(svy_tst)

}

#' Fake data.table with unique values from specific survey
#'
#'
#' @param svy Selected survey
#' @param n_obs Number of observations, bins or quantiles
#'
#' @return list of variables
fk_uniq <- function(svy,
                    n_obs) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # computations   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  var_dist <- collapse::fndistinct(svy, na.rm = FALSE)
  uniq     <- var_dist[var_dist==1]
  var_uniq <- collapse::funique(svy|>
                                  collapse::fselect(names(uniq)))

  fake_svy <- var_uniq[rep(1,each=n_obs),]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(fake_svy)

}

ignore_unused_imports <- function() {
  dplyr::across
  rlang::.data
}

#' Delete files that do not have an specific extension
#'
#' @param orig_file File location
#' @param ext_keep extension to be kept in the folder
#'
#' @return none
del_files <- function(orig_file,
                      ext_keep) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # computations   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ext <- orig_file |>
    fs::path_ext()

  if (ext != ext_keep) {
    fs::file_delete(orig_file)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(invisible(TRUE))

}


#' Test if specific branch is installed
#'
#' @param package_name Name of the package you want to test
#' @param remote_ref Name of the branch you want to verify if it is installed
#'
#' @return alert
#' @export
is_remote_installed <- function(package_name,
                                remote_ref) {

  if (package_name %in% utils::installed.packages()[, "Package"]) {

    package_info <- utils::packageDescription(package_name)

    return(remote_ref == package_info$RemoteRef)

  } else {

    cli::cli_abort("Make sure to install {.pkg {package_name}}")

  }

}
