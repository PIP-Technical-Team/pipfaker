#' Load and merge data files from PIP drive
#'
#'
#' @param orig_file a vector of file addresses
#' (usually `orig` variable from `cache_inventory`)
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

#' Load and merge data files from cache
#'
#'
#' @param cache_file a vector of file addresses
#' (usually `cache_file` variable from `cache_inventory`)
#'
#' @return list
#'
load_files_cache <- function(cache_file) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # computations   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  dt <- lapply(cache_file, fst::read_fst)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Return   ---------
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return(dt)

}


ignore_unused_imports <- function() {
  dplyr::across
  rlang::.data
}
