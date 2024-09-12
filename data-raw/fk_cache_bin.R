#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Libraries   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(data.table)
library(wbpip)
library(MASS)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load inventory (needs access to Y Drive)   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cache_inventory <- pipload::pip_load_cache_inventory(version = "20240326_2017_01_02_PROD")
cache_inventory$source <- stringr::str_split(cache_inventory$cache_id, "_", simplify = TRUE)[,6]

### Choose only micro data

#Note: dta is an internal file with a list of distribution_type

pip_bin_files <- cache_inventory |>
  joyn::joyn(dta, by = "cache_id", match_type = "1:m",
             y_vars_to_keep = "distribution_type",
             keep = "left",
             reportvar = FALSE,
             verbose = FALSE)|>
  collapse::fsubset(distribution_type == "micro" & source == "BIN")|>
  collapse::fselect(cache_file)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate bin data   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fk_cache_bin <- fk_cache_bin_gen(pip_bin_files$cache_file)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Save data   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#save(fk_micro, file = "data/fk_cache_bin.csv")
usethis::use_data(fk_cache_bin, overwrite = TRUE)
