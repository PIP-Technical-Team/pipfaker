#' Micro survey data
#'
#' A fake dataset with micro survey data as found in
#' `//w1wbgencifs01/pip/PIP-Data_QA/`
#'
#' @format A data frame with rows and 20 variables:
#' \describe{
#'   \item{country_code}{Three letter country code}
#'   \item{surveyid_year}{Year of the survey (already rounded)}
#'   \item{survey_acronym}{Acronym of the survey (varies by country)}
#'   \item{hhid}{Household ID}
#'   \item{pid}{Person ID (not always available)}
#'   \item{welfare}{Welfare (consumption/weight)}
#'   \item{weight}{Household weight (always?)}
#'   \item{gender}{Person gender (not always available)}
#'   \item{area}{Urban or rural area (not always available)}
#'   \item{welfare_type}{Type of welfare: consumption or income}
#'   \item{distribution_type}{micro}
#'   \item{cpi_data_level}{National, urban or rural data level used for CPI}
#'   \item{ppp_data_level}{National, urban or rural data level used for PPP}
#'   \item{pop_data_level}{National, urban or rural data level used for population}
#'   \item{gdp_data_level}{National, urban or rural data level used for GDP}
#'   \item{pce_data_level}{National, urban or rural data level used for PCE (?)}
#'   \item{gd_type}{??}
#'   \item{alt_welfare}{??}
#'   \item{imputation_id}{Imputation ID}
#' }
#'
#' @source Fake data using random characteristics of old and new surveys.
"fk_micro"
