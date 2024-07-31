
#' Load and merge data files from PIP drive
#'
#'
#' @param orig_file a vector of file addresses
#' (usually `orig` variable from `pip_inventory`)
#'
#' @return list
#'
load_files_pip <- function(orig_file) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # computations   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  dt <- lapply(orig_file, haven::read_dta)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(dt)

}


ignore_unused_imports <- function() {
  dplyr::across
}
