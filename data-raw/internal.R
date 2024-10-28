# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Objective:     This file includes the location of some raw data for the package
# Version:       281024
# Author:        Diana C. Garcia Rojas
# Dependencies:  The World Bank
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Distribution_type of the PIP surveys   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load data  ---------

# Need to fix and include the function that creates this file.

load("E:/PovcalNet/01.personal/wb535623/Personal/Useful_Functions/PIP_source_dist_260324_PROD.RData")

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Save internal data ---------

usethis::use_data(dta, overwrite = TRUE, internal = TRUE)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# List of 20 surveys for fk_pip when input_path is NULL ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cache_inventory <- pipload::pip_load_cache_inventory(version = "20240326_2017_01_02_PROD")

nm_svy <- tools::file_path_sans_ext(basename(cache_inventory$cache_file))

svy_inf <- data.table::setDT(as.data.frame(cache_inventory$cache_id))[
  , data.table::tstrsplit(cache_inventory$cache_id, "_",
                          names = c("country_code",
                                    "year",
                                    "survey_name",
                                    "rep_level",
                                    "welfare_type",
                                    "survey_type"))
]

fk_svy_ls <- withr::with_seed(61089,
                              sample(nm_svy[svy_inf$survey_type %in% c("GROUP","BIN")],10))


fk_svy_ls <- c(fk_svy_ls, withr::with_seed(61089,
                                     sample(nm_svy[svy_inf$survey_type %in% c("GPWG")],10)))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Save internal data ---------

usethis::use_data(fk_svy_ls, overwrite = TRUE, internal = TRUE)


