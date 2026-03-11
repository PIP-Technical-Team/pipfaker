test_that("synth_welfare_qmap preserves weighted mean per group", {
  set.seed(42)
  dt <- data.table::data.table(
    welfare = c(rlnorm(60, 4, 1), rlnorm(40, 3, 0.8)),
    weight  = rep(1 / 100, 100),
    area    = c(rep("urban", 60), rep("rural", 40))
  )

  result <- synth_welfare_qmap(dt, grp_col = "area", n_obs = 50)

  # Original weighted means per area
  orig_urban <- dt[area == "urban",
                   stats::weighted.mean(welfare, weight)]
  orig_rural <- dt[area == "rural",
                   stats::weighted.mean(welfare, weight)]

  synth_urban <- result[area == "urban",
                        stats::weighted.mean(welfare, weight)]
  synth_rural <- result[area == "rural",
                        stats::weighted.mean(welfare, weight)]

  expect_equal(synth_urban, orig_urban, tolerance = 1e-6)
  expect_equal(synth_rural, orig_rural, tolerance = 1e-6)
})

test_that("synth_welfare_qmap returns correct number of rows", {
  dt <- data.table::data.table(
    welfare = rlnorm(100, 4, 1),
    weight  = rep(1 / 100, 100),
    area    = sample(c("urban", "rural"), 100, replace = TRUE)
  )

  result <- synth_welfare_qmap(dt, grp_col = "area", n_obs = 30)

  # n_obs is split across groups by share; total should be close to n_obs

  expect_true(nrow(result) > 0)
  expect_true(nrow(result) <= 30)
})

test_that("synth_welfare_qmap handles all-NA group column", {
  dt <- data.table::data.table(
    welfare = rlnorm(50, 4, 1),
    weight  = rep(1 / 50, 50),
    area    = NA_character_
  )

  result <- synth_welfare_qmap(dt, grp_col = "area", n_obs = 20)

  expect_equal(nrow(result), 20)
  expect_true(all(is.na(result$area)))

  # Weighted mean should match
  orig_wmean  <- stats::weighted.mean(dt$welfare, dt$weight)
  synth_wmean <- stats::weighted.mean(result$welfare, result$weight)
  expect_equal(synth_wmean, orig_wmean, tolerance = 1e-6)
})

test_that("synth_welfare_qmap handles single group", {
  dt <- data.table::data.table(
    welfare = rlnorm(80, 4, 1),
    weight  = rep(1 / 80, 80),
    area    = rep("urban", 80)
  )

  result <- synth_welfare_qmap(dt, grp_col = "area", n_obs = 40)

  expect_equal(nrow(result), 40)
  expect_true(all(result$area == "urban"))

  orig_wmean  <- stats::weighted.mean(dt$welfare, dt$weight)
  synth_wmean <- stats::weighted.mean(result$welfare, result$weight)
  expect_equal(synth_wmean, orig_wmean, tolerance = 1e-6)
})

test_that("synth_welfare_qmap handles all-NA welfare", {
  dt <- data.table::data.table(
    welfare = rep(NA_real_, 30),
    weight  = rep(1 / 30, 30),
    area    = rep("urban", 30)
  )

  result <- synth_welfare_qmap(dt, grp_col = "area", n_obs = 10)

  expect_equal(nrow(result), 10)
  expect_true(all(is.na(result$welfare)))
})

test_that("synth_welfare_qmap output columns are correct", {
  dt <- data.table::data.table(
    welfare = rlnorm(50, 4, 1),
    weight  = rep(1 / 50, 50),
    area    = sample(c("urban", "rural"), 50, replace = TRUE)
  )

  result <- synth_welfare_qmap(dt, grp_col = "area", n_obs = 25)

  expect_true(all(c("welfare", "weight", "area") %in% names(result)))
  expect_equal(ncol(result), 3)
})
