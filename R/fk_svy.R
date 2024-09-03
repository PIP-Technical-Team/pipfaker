#' Micro survey data (raw)
#'
#' A fake dataset with raw micro survey data as found in
#' `//w1wbgencifs01/pip/PIP-Data_QA/`
#'
#' @format A data frame with 20 variables:
#' \describe{
#'   \item{country_code}{Three letter country code}
#'   \item{survey_year}{Year of the survey}
#'   \item{surveyid_year}{Year of the survey (already rounded)}
#'   \item{survey_acronym}{Acronym of the survey (varies by country)}
#'   \item{hhid}{Household ID}
#'   \item{pid}{Person ID (not always available)}
#'   \item{welfare}{Welfare (consumption/income)}
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
#' @source Fake data using characteristics of random surveys (see `fk_micro_gen`).
"fk_micro"

#' Micro survey data (cache)
#'
#' A fake dataset with raw micro survey data as found in cache from
#' `//w1wbgencifs01/pip/pip_ingestion_pipeline/`
#'
#' @format A data frame with 33 variables:
#' \describe{
#'   \item{country_code}{Three letter country code}
#'   \item{survey_year}{Year of the survey}
#'   \item{surveyid_year}{Year of the survey (already rounded)}
#'   \item{survey_acronym}{Acronym of the survey (varies by country)}
#'   \item{hhid}{Household ID}
#'   \item{pid}{Person ID (not always available)}
#'   \item{welfare}{Welfare (consumption/income)}
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
#'   \item{survey_id}{Survey ID}
#'   \item{vermast}{??}
#'   \item{veralt}{??}
#'   \item{collection}{??}
#'   \item{module}{??}
#'   \item{tool}{??}
#'   \item{source}{Source of the data: `GPWG`}
#'   \item{reporting_level}{Reporting level of the survey}
#'   \item{ppp}{Purchase Power Parity}
#'   \item{cpi}{Consumper Price Index}
#'   \item{welfare_lcu}{Welfare in Local Currency Units (Same as welfare)}
#'   \item{welfare_ppp}{Welfare in PPP}
#'   \item{cache_id}{ID for specific survey in cache}
#' }
#'
#' @source Fake data using characteristics of random surveys (see `fk_cache_micro_gen`).
"fk_cache_micro"

#' Imputed survey data (cache)
#'
#' A fake dataset with raw imputed survey data as found in cache from
#' `//w1wbgencifs01/pip/pip_ingestion_pipeline/`
#'
#' @format A data frame with 34 variables:
#' \describe{
#'   \item{country_code}{Three letter country code}
#'   \item{survey_year}{Year of the survey}
#'   \item{surveyid_year}{Year of the survey (already rounded)}
#'   \item{survey_acronym}{Acronym of the survey (varies by country)}
#'   \item{hhid}{Household ID}
#'   \item{pid}{Person ID (not always available)}
#'   \item{welfare}{Welfare (consumption/income)}
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
#'   \item{pop_fact}{??}
#'   \item{imputation_id}{Imputation ID}
#'   \item{survey_id}{Survey ID}
#'   \item{vermast}{??}
#'   \item{veralt}{??}
#'   \item{collection}{??}
#'   \item{module}{??}
#'   \item{tool}{??}
#'   \item{source}{Source of the data: `GPWG`}
#'   \item{reporting_level}{Reporting level of the survey}
#'   \item{ppp}{Purchase Power Parity}
#'   \item{cpi}{Consumper Price Index}
#'   \item{welfare_lcu}{Welfare in Local Currency Units (Same as welfare)}
#'   \item{welfare_ppp}{Welfare in PPP}
#'   \item{cache_id}{ID for specific survey in cache}
#' }
#'
#' @source Fake data using characteristics of random surveys (see `fk_cache_imputed_gen`).
"fk_cache_imputed"

#' Group data (cache)
#'
#' A fake dataset with raw group data generated using Datt (1998) data from
#' rural India 1983.
#'
#' @format A data frame with 33 variables:
#' \describe{
#'   \item{country_code}{Three letter country code}
#'   \item{survey_year}{Year of the survey}
#'   \item{surveyid_year}{Year of the survey (already rounded)}
#'   \item{survey_acronym}{Acronym of the survey (varies by country)}
#'   \item{hhid}{Household ID}
#'   \item{pid}{Person ID (not always available)}
#'   \item{welfare}{Welfare (consumption/income)}
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
#'   \item{survey_id}{Survey ID}
#'   \item{vermast}{??}
#'   \item{veralt}{??}
#'   \item{collection}{??}
#'   \item{module}{??}
#'   \item{tool}{??}
#'   \item{source}{Source of the data: `GROUP`}
#'   \item{reporting_level}{Reporting level of the survey}
#'   \item{ppp}{Purchase Power Parity}
#'   \item{cpi}{Consumper Price Index}
#'   \item{welfare_lcu}{Welfare in Local Currency Units (Same as welfare)}
#'   \item{welfare_ppp}{Welfare in PPP}
#'   \item{cache_id}{ID for specific survey in cache}
#' }
#'
#' @source Fake data using data from Datt paper (see `fk_cache_group_gen`).
"fk_cache_group"

#' Bin data (cache)
#'
#' A fake dataset with raw bin data as found in cache from
#' `//w1wbgencifs01/pip/pip_ingestion_pipeline/`
#'
#' @format A data frame with 33 variables:
#' \describe{
#'   \item{country_code}{Three letter country code}
#'   \item{survey_year}{Year of the survey}
#'   \item{surveyid_year}{Year of the survey (already rounded)}
#'   \item{survey_acronym}{Acronym of the survey (varies by country)}
#'   \item{hhid}{Household ID}
#'   \item{pid}{Person ID (not always available)}
#'   \item{welfare}{Welfare (consumption/income)}
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
#'   \item{survey_id}{Survey ID}
#'   \item{vermast}{??}
#'   \item{veralt}{??}
#'   \item{collection}{??}
#'   \item{module}{??}
#'   \item{tool}{??}
#'   \item{source}{Source of the data: `BIN`}
#'   \item{reporting_level}{Reporting level of the survey}
#'   \item{ppp}{Purchase Power Parity}
#'   \item{cpi}{Consumper Price Index}
#'   \item{welfare_lcu}{Welfare in Local Currency Units (Same as welfare)}
#'   \item{welfare_ppp}{Welfare in PPP}
#'   \item{cache_id}{ID for specific survey in cache}
#' }
#'
#' @source Fake data using a synthetic vector generated by random bin surveys
#' (see `fk_cache_bin_gen`).
"fk_cache_bin"

#' Group data from Datt (1998)
#'
#' @format A dataset with 7 variables:
#' \describe{
#'     \item{lwelfare}{Cumulative proportion of consumption}
#'     \item{welfare}{Mean monthly per capita consumption}
#'     \item{weight}{Cumulative proportion of population}
#'     \item{pop}{Percentage of persons}
#'     \item{country_code}{Country code for India}
#'     \item{reporting_level}{Reporting level: rural}
#'     \item{survey_year}{Year: 1983}
#'     }
#' @source Datt (1998) Computational tools for poverty measurement and analysis
"datt"
