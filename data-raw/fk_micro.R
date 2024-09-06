#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Libraries   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(collapse)
library(data.table)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Load inventory (needs access to Y Drive)   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cache_inventory <- pipload::pip_load_cache_inventory(version = "20240326_2017_01_02_PROD")

cache_inventory$source <- stringr::str_split(cache_inventory$cache_id, "_", simplify = TRUE)[,6]

#Note: dta is an internal file with a list of distribution_type

pip_micro_files <- cache_inventory |>
  joyn::joyn(dta, by = "cache_id", match_type = "1:m",
             y_vars_to_keep = "distribution_type",
             keep = "left",
             reportvar = FALSE,
             verbose = FALSE)|>
  collapse::fsubset(distribution_type == "micro")|>
  collapse::fselect(orig)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate micro data   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fk_micro <- fk_micro_gen(pip_micro_files)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Save data   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#save(fk_micro, file = "data/fk_micro.csv")
usethis::use_data(fk_micro, overwrite = TRUE)
