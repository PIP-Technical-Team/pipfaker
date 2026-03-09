# make_fixtures.R
# Run this script to generate minimal fixture .fst files for testing.
# Usage: source("tests/testthat/fixtures/make_fixtures.R")

library(data.table)
library(fst)

fixture_dir <- "tests/testthat/fixtures/ref_folder"

# ---- Create folder structure ----
dirs <- c(

  file.path(fixture_dir, "_aux"),
  file.path(fixture_dir, "_aux", "sub_aux"),
  file.path(fixture_dir, "estimations"),
  file.path(fixture_dir, "survey_data"),
  file.path(fixture_dir, "lineup_data")
)
for (d in dirs) dir.create(d, recursive = TRUE, showWarnings = FALSE)

# ---- Root files ----
writeLines("root content", file.path(fixture_dir, "metadata.txt"))
writeLines("duckdb placeholder", file.path(fixture_dir, "cache.duckdb"))

# ---- _aux files ----
writeLines("aux content", file.path(fixture_dir, "_aux", "aux_data.txt"))
writeLines("sub aux content",
           file.path(fixture_dir, "_aux", "sub_aux", "nested.txt"))

# ---- estimations files ----
writeLines("est content",
           file.path(fixture_dir, "estimations", "est_data.txt"))

# ---- survey_data: micro file ----
set.seed(42)
n <- 200
svy_micro <- data.table(
  welfare = rlnorm(n, meanlog = 4, sdlog = 1),
  weight  = rep(1 / n, n),
  area    = sample(c("urban", "rural"), n, replace = TRUE, prob = c(0.4, 0.6))
)
write_fst(svy_micro,
          file.path(fixture_dir, "survey_data", "ABC_2020_TEST_D2_INC_GPWG.fst"))

# ---- survey_data: GROUP file (copy-only) ----
svy_group <- data.table(
  welfare = rlnorm(50, meanlog = 3, sdlog = 0.5),
  weight  = rep(1 / 50, 50),
  area    = NA_character_
)
write_fst(svy_group,
          file.path(fixture_dir, "survey_data", "DEF_2019_TEST_N_CON_GROUP.fst"))

# ---- survey_data: BIN file (copy-only) ----
svy_bin <- data.table(
  welfare = rlnorm(400, meanlog = 3.5, sdlog = 0.8),
  weight  = rep(1 / 400, 400),
  area    = NA_character_
)
write_fst(svy_bin,
          file.path(fixture_dir, "survey_data", "GHI_2018_TEST_N_CON_BIN.fst"))

# ---- survey_data: micro with all-NA area ----
svy_na_area <- data.table(
  welfare = rlnorm(100, meanlog = 4, sdlog = 1),
  weight  = rep(1 / 100, 100),
  area    = NA_character_
)
write_fst(svy_na_area,
          file.path(fixture_dir, "survey_data", "JKL_2021_TEST_N_INC_GPWG.fst"))

# ---- lineup_data ----
set.seed(123)
n_lu <- 300
lu <- data.table(
  reporting_level = sample(c("national", "urban", "rural"), n_lu,
                           replace = TRUE, prob = c(0.5, 0.25, 0.25)),
  welfare = rlnorm(n_lu, meanlog = 5, sdlog = 1.2),
  weight  = rep(1 / n_lu, n_lu)
)
setorderv(lu, c("reporting_level", "welfare"))
lu[, `:=`(
  cw     = weight,
  cwy    = weight * welfare,
  cwy2   = weight * welfare * welfare,
  cwylog = log(pmax(welfare, 1e-10)) * weight,
  index  = seq_len(.N) - 1L
), by = reporting_level]
write_fst(lu,
          file.path(fixture_dir, "lineup_data", "MNO_2020_TEST_lineup.fst"))

cat("Fixtures created in:", normalizePath(fixture_dir), "\n")
