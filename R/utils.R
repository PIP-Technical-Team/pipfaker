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

  if(!file.exists(orig_file)){

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
    dt <- qs::read(orig_file) |>
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

#' #' Load and merge data files from cache
#' #'
#' #'
#' #' @param cache_file a vector of file addresses
#' #' (usually `cache_file` variable from `cache_inventory`)
#' #'
#' #' @return list
#' #'
#' load_files_cache <- function(cache_file) {
#'
#'   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#'   # computations   ---------
#'   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#'   dt <- lapply(cache_file, fst::read_fst)
#'
#'   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#'   # Return   ---------
#'   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#'   return(dt)
#'
#' }


ignore_unused_imports <- function() {
  dplyr::across
  rlang::.data
}
