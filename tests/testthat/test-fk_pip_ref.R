test_that("fk_pip_ref creates correct folder structure", {
  ref_dir <- test_path("fixtures", "ref_folder")
  skip_if_not(dir.exists(ref_dir), "Fixture ref_folder not found")

  tmp_out <- withr::local_tempdir()

  fk_pip_ref(input_path = ref_dir, output_path = tmp_out, pct = 0.5)

  # _aux and estimations copied

  expect_true(dir.exists(file.path(tmp_out, "_aux")))
  expect_true(dir.exists(file.path(tmp_out, "estimations")))
  expect_true(file.exists(file.path(tmp_out, "_aux", "aux_data.txt")))
  expect_true(file.exists(file.path(tmp_out, "_aux", "sub_aux", "nested.txt")))
  expect_true(file.exists(file.path(tmp_out, "estimations", "est_data.txt")))

  # survey_data and lineup_data dirs exist
  expect_true(dir.exists(file.path(tmp_out, "survey_data")))
  expect_true(dir.exists(file.path(tmp_out, "lineup_data")))
})

test_that("fk_pip_ref copies root files but excludes cache.duckdb", {
  ref_dir <- test_path("fixtures", "ref_folder")
  skip_if_not(dir.exists(ref_dir), "Fixture ref_folder not found")

  tmp_out <- withr::local_tempdir()

  fk_pip_ref(input_path = ref_dir, output_path = tmp_out, pct = 0.5)

  expect_true(file.exists(file.path(tmp_out, "metadata.txt")))
  expect_false(file.exists(file.path(tmp_out, "cache.duckdb")))
})

test_that("fk_pip_ref copies GROUP and BIN files directly", {
  ref_dir <- test_path("fixtures", "ref_folder")
  skip_if_not(dir.exists(ref_dir), "Fixture ref_folder not found")

  tmp_out <- withr::local_tempdir()

  fk_pip_ref(input_path = ref_dir, output_path = tmp_out, pct = 0.5)

  # GROUP and BIN should be identical copies
  group_orig <- fst::read_fst(
    file.path(ref_dir, "survey_data", "DEF_2019_TEST_N_CON_GROUP.fst"),
    as.data.table = TRUE
  )
  group_copy <- fst::read_fst(
    file.path(tmp_out, "survey_data", "DEF_2019_TEST_N_CON_GROUP.fst"),
    as.data.table = TRUE
  )
  expect_equal(group_copy, group_orig)

  bin_orig <- fst::read_fst(
    file.path(ref_dir, "survey_data", "GHI_2018_TEST_N_CON_BIN.fst"),
    as.data.table = TRUE
  )
  bin_copy <- fst::read_fst(
    file.path(tmp_out, "survey_data", "GHI_2018_TEST_N_CON_BIN.fst"),
    as.data.table = TRUE
  )
  expect_equal(bin_copy, bin_orig)
})

test_that("fk_pip_ref synthesises micro survey files", {
  ref_dir <- test_path("fixtures", "ref_folder")
  skip_if_not(dir.exists(ref_dir), "Fixture ref_folder not found")

  tmp_out <- withr::local_tempdir()

  fk_pip_ref(input_path = ref_dir, output_path = tmp_out, pct = 0.5)

  out_file <- file.path(tmp_out, "survey_data",
                        "ABC_2020_TEST_D2_INC_GPWG.fst")
  expect_true(file.exists(out_file))

  orig  <- fst::read_fst(
    file.path(ref_dir, "survey_data", "ABC_2020_TEST_D2_INC_GPWG.fst"),
    as.data.table = TRUE
  )
  synth <- fst::read_fst(out_file, as.data.table = TRUE)

  # Fewer rows (synthesised at 50%)
  expect_true(nrow(synth) < nrow(orig))
  # Same column names
  expect_equal(names(synth), names(orig))
})

test_that("fk_pip_ref synthesises lineup files", {
  ref_dir <- test_path("fixtures", "ref_folder")
  skip_if_not(dir.exists(ref_dir), "Fixture ref_folder not found")

  tmp_out <- withr::local_tempdir()

  fk_pip_ref(input_path = ref_dir, output_path = tmp_out, pct = 0.5)

  out_file <- file.path(tmp_out, "lineup_data",
                        "MNO_2020_TEST_lineup.fst")
  expect_true(file.exists(out_file))

  synth <- fst::read_fst(out_file, as.data.table = TRUE)
  expect_true(nrow(synth) > 0)
  expect_true("welfare" %in% names(synth))
})

test_that("fk_pip_ref rejects invalid pct values", {
  ref_dir <- test_path("fixtures", "ref_folder")
  skip_if_not(dir.exists(ref_dir), "Fixture ref_folder not found")

  tmp_out <- withr::local_tempdir()

  expect_error(fk_pip_ref(ref_dir, tmp_out, pct = 0),   "pct")
  expect_error(fk_pip_ref(ref_dir, tmp_out, pct = -1),  "pct")
  expect_error(fk_pip_ref(ref_dir, tmp_out, pct = 2),   "pct")
  expect_error(fk_pip_ref(ref_dir, tmp_out, pct = "a"), "pct")
})

test_that("fk_pip_ref aborts on nonexistent input_path", {
  tmp_out <- withr::local_tempdir()
  expect_error(
    fk_pip_ref(input_path = "/nonexistent/path", output_path = tmp_out),
    "does not exist"
  )
})

test_that("fk_pip_ref overwrites existing output folder", {
  ref_dir <- test_path("fixtures", "ref_folder")
  skip_if_not(dir.exists(ref_dir), "Fixture ref_folder not found")

  tmp_out <- withr::local_tempdir()

  # Run twice — second run should succeed (overwrite)
  fk_pip_ref(input_path = ref_dir, output_path = tmp_out, pct = 0.5)
  expect_no_error(
    fk_pip_ref(input_path = ref_dir, output_path = tmp_out, pct = 0.5)
  )
})

test_that("fk_pip_ref rejects invalid parallel argument", {
  ref_dir <- test_path("fixtures", "ref_folder")
  skip_if_not(dir.exists(ref_dir), "Fixture ref_folder not found")

  tmp_out <- withr::local_tempdir()
  expect_error(fk_pip_ref(ref_dir, tmp_out, parallel = "yes"), "parallel")
  expect_error(fk_pip_ref(ref_dir, tmp_out, parallel = 1),     "parallel")
})
