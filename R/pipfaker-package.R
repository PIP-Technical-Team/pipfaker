#' @keywords internal
"_PACKAGE"

## usethis namespace: start
#' @importFrom data.table .BY
#' @importFrom data.table .EACHI
#' @importFrom data.table .GRP
#' @importFrom data.table .I
#' @importFrom data.table .N
#' @importFrom data.table .NGRP
#' @importFrom data.table .SD
#' @importFrom data.table :=
#' @importFrom data.table data.table
## usethis namespace: end
NULL

# Make sure data.table knows we know we're using it
#' @noRd
.datatable.aware = TRUE

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")
  utils::globalVariables(c(".",
                           'distribution_type',
                           'cpi',
                           'ppp',
                           'welfare',
                           'welfare_lcu',
                           'welfare_ppp',
                           'cache_id',
                           'DV',
                           'reporting_level',
                           'weight',
                           'datt',
                           'hhid',
                           'pid'))
