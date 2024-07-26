# Load pip_invetory
pip_inventory <-
  pipload::pip_find_data(
    inv_file = "//w1wbgencifs01/pip/PIP-Data_QA/_inventory/inventory.fst",
    filter_to_pc = TRUE,
    maindir = "//w1wbgencifs01/pip/PIP-Data_QA/")

library(dplyr)
library(data.table)

fk_micro <- fk_micro_gen(pip_inventory)

#save(fk_micro, file = "data/fk_micro.rda")
usethis::use_data(fk_micro, internal = TRUE, overwrite = TRUE)
