test_that("synth_svy_file writes .fst with correct columns and types", {
  fixture <- test_path("fixtures", "ref_folder", "survey_data",
                       "ABC_2020_TEST_D2_INC_GPWG.fst")
  skip_if_not(file.exists(fixture), "Fixture file not found")

  tmp_out <- withr::local_tempdir()

  synth_svy_file(file_path = fixture, output_dir = tmp_out, pct = 0.5)

  out_file <- file.path(tmp_out, "ABC_2020_TEST_D2_INC_GPWG.fst")
  expect_true(file.exists(out_file))

  orig <- fst::read_fst(fixture, as.data.table = TRUE)
  synth <- fst::read_fst(out_file, as.data.table = TRUE)

  # Same column names

  expect_equal(names(synth), names(orig))

  # Column types match
  expect_equal(vapply(synth, class, character(1)),
               vapply(orig, class, character(1)))
})

test_that("synth_svy_file respects pct for row count", {
  fixture <- test_path("fixtures", "ref_folder", "survey_data",
                       "ABC_2020_TEST_D2_INC_GPWG.fst")
  skip_if_not(file.exists(fixture), "Fixture file not found")

  tmp_out <- withr::local_tempdir()
  orig <- fst::read_fst(fixture, as.data.table = TRUE)

  synth_svy_file(file_path = fixture, output_dir = tmp_out, pct = 0.1)

  out_file <- file.path(tmp_out, "ABC_2020_TEST_D2_INC_GPWG.fst")
  synth <- fst::read_fst(out_file, as.data.table = TRUE)

  expected_n <- ceiling(nrow(orig) * 0.1)
  # Row count should be close (group floor rounding may lose a few rows)
  expect_true(nrow(synth) > 0)
  expect_true(nrow(synth) <= expected_n)
})

test_that("synth_svy_file preserves weighted mean of welfare", {
  fixture <- test_path("fixtures", "ref_folder", "survey_data",
                       "ABC_2020_TEST_D2_INC_GPWG.fst")
  skip_if_not(file.exists(fixture), "Fixture file not found")

  tmp_out <- withr::local_tempdir()

  synth_svy_file(file_path = fixture, output_dir = tmp_out, pct = 1)

  orig  <- fst::read_fst(fixture, as.data.table = TRUE)
  synth <- fst::read_fst(
    file.path(tmp_out, "ABC_2020_TEST_D2_INC_GPWG.fst"),
    as.data.table = TRUE
  )

  # Check per-area weighted mean preservation
  for (a in unique(orig$area[!is.na(orig$area)])) {
    orig_wm  <- orig[area == a, stats::weighted.mean(welfare, weight)]
    synth_wm <- synth[area == a, stats::weighted.mean(welfare, weight)]
    expect_equal(synth_wm, orig_wm, tolerance = 1e-4,
                 label = paste("weighted mean for area =", a))
  }
})

test_that("synth_svy_file handles all-NA area", {
  fixture <- test_path("fixtures", "ref_folder", "survey_data",
                       "JKL_2021_TEST_N_INC_GPWG.fst")
  skip_if_not(file.exists(fixture), "Fixture file not found")

  tmp_out <- withr::local_tempdir()

  synth_svy_file(file_path = fixture, output_dir = tmp_out, pct = 0.5)

  out_file <- file.path(tmp_out, "JKL_2021_TEST_N_INC_GPWG.fst")
  expect_true(file.exists(out_file))

  synth <- fst::read_fst(out_file, as.data.table = TRUE)
  expect_true(all(is.na(synth$area)))
})
