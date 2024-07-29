#Libraries

library(dplyr)
library(data.table)

# Load pip_inventory (needs access to Y Drive)

pip_inventory <-
  pipload::pip_find_data(
    inv_file = "//w1wbgencifs01/pip/PIP-Data_QA/_inventory/inventory.fst",
    filter_to_pc = TRUE,
    maindir = "//w1wbgencifs01/pip/PIP-Data_QA/")

# Generate micro data

fk_micro <- fk_micro_gen(pip_inventory)

# Save data

#save(fk_micro, file = "data/fk_micro.csv")
usethis::use_data(fk_micro, overwrite = TRUE)
