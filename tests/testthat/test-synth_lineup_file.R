test_that("synth_lineup_file writes .fst with expected columns", {
  fixture <- test_path("fixtures", "ref_folder", "lineup_data",
                       "MNO_2020_TEST_lineup.fst")
  skip_if_not(file.exists(fixture), "Fixture file not found")

  tmp_out <- withr::local_tempdir()

  synth_lineup_file(file_path = fixture, output_dir = tmp_out, pct = 0.5)

  out_file <- file.path(tmp_out, "MNO_2020_TEST_lineup.fst")
  expect_true(file.exists(out_file))

  synth <- fst::read_fst(out_file, as.data.table = TRUE)

  expected_cols <- c("reporting_level", "welfare", "weight",
                     "cw", "cwy", "cwy2", "cwylog", "index")
  expect_true(all(expected_cols %in% names(synth)))
})

test_that("synth_lineup_file index starts from 0", {
  fixture <- test_path("fixtures", "ref_folder", "lineup_data",
                       "MNO_2020_TEST_lineup.fst")
  skip_if_not(file.exists(fixture), "Fixture file not found")

  tmp_out <- withr::local_tempdir()
  synth_lineup_file(file_path = fixture, output_dir = tmp_out, pct = 1)

  synth <- fst::read_fst(
    file.path(tmp_out, "MNO_2020_TEST_lineup.fst"),
    as.data.table = TRUE
  )

  # Check index starts from 0 within each reporting_level
  for (rl in unique(synth$reporting_level)) {
    idx <- synth[reporting_level == rl, index]
    expect_equal(min(idx), 0L,
                 label = paste("min index for reporting_level =", rl))
  }
})

test_that("synth_lineup_file derived columns are consistent", {
  fixture <- test_path("fixtures", "ref_folder", "lineup_data",
                       "MNO_2020_TEST_lineup.fst")
  skip_if_not(file.exists(fixture), "Fixture file not found")

  tmp_out <- withr::local_tempdir()
  synth_lineup_file(file_path = fixture, output_dir = tmp_out, pct = 1)

  synth <- fst::read_fst(
    file.path(tmp_out, "MNO_2020_TEST_lineup.fst"),
    as.data.table = TRUE
  )

  # cw = weight
  expect_equal(synth$cw, synth$weight, tolerance = 1e-10)
  # cwy = weight * welfare
  expect_equal(synth$cwy, synth$weight * synth$welfare, tolerance = 1e-10)
  # cwy2 = weight * welfare * welfare
  expect_equal(synth$cwy2, synth$weight * synth$welfare * synth$welfare,
               tolerance = 1e-10)
  # cwylog = log(pmax(welfare, 1e-10)) * weight
  expect_equal(synth$cwylog,
               log(pmax(synth$welfare, 1e-10)) * synth$weight,
               tolerance = 1e-10)
})

test_that("synth_lineup_file respects pct for row count", {
  fixture <- test_path("fixtures", "ref_folder", "lineup_data",
                       "MNO_2020_TEST_lineup.fst")
  skip_if_not(file.exists(fixture), "Fixture file not found")

  tmp_out <- withr::local_tempdir()
  orig <- fst::read_fst(fixture, as.data.table = TRUE)

  synth_lineup_file(file_path = fixture, output_dir = tmp_out, pct = 0.2)

  synth <- fst::read_fst(
    file.path(tmp_out, "MNO_2020_TEST_lineup.fst"),
    as.data.table = TRUE
  )

  expected_n <- ceiling(nrow(orig) * 0.2)
  expect_true(nrow(synth) > 0)
  expect_true(nrow(synth) <= expected_n)
})
