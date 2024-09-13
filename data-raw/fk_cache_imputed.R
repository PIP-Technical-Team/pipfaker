#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load Libraries   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

library(collapse)
library(data.table)
library(wbpip)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Load inventory (needs access to Y Drive)   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cache_inventory <- pipload::pip_load_cache_inventory(version = "20240326_2017_01_02_PROD")
cache_inventory$source <- stringr::str_split(cache_inventory$cache_id, "_", simplify = TRUE)[,6]
cache_inventory$DV <- stringr::str_split(cache_inventory$cache_id, "_", simplify = TRUE)[,4]

### Choose only micro data

#Note: dta is an internal file with a list of distribution_type

d_type = "D2" # It can be "D1" or "D2"

pip_files <- cache_inventory|>
  joyn::joyn(dta, by = "cache_id", match_type = "1:m",
             y_vars_to_keep = "distribution_type",
             keep = "left",
             reportvar = FALSE,
             verbose = FALSE)|>
  collapse::fsubset(distribution_type == "imputed" & DV == d_type)|>
  collapse::fselect(cache_file)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Generate micro data   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

fk_cache_imputed <- fk_cache_imputed_gen(pip_files$cache_file,
                                         n_obs = 1500, n_sim = 10)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Save data   ---------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#save(fk_micro, file = "data/fk_cache_imputed")
usethis::use_data(fk_cache_imputed, overwrite = TRUE)
