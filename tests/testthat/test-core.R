test_that("simulate_rwd returns a tibble of the requested size", {
  d <- simulate_rwd(n_trial = 50, n_external = 200, seed = 1)
  expect_s3_class(d, "tbl_df")
  expect_equal(nrow(d), 250)
  expect_equal(sum(d$treatment == 1), 50)
  expect_true(all(c("age", "sex", "ecog", "biomarker", "prior_lines",
                    "treatment", "time_months", "event") %in% names(d)))
})

test_that("simulate_rwd produces a confounded cohort (trial arm is younger)", {
  d <- simulate_rwd(n_trial = 100, n_external = 500, seed = 2)
  mean_age_trial <- mean(d$age[d$treatment == 1])
  mean_age_rwd   <- mean(d$age[d$treatment == 0])
  expect_lt(mean_age_trial, mean_age_rwd)
})

test_that("compute_iptw appends ps, iptw and siptw and they are positive", {
  d <- simulate_rwd(50, 200, seed = 3)
  w <- compute_iptw(d)
  expect_true(all(c("ps", "iptw", "siptw") %in% names(w)))
  expect_true(all(w$ps > 0 & w$ps < 1))
  expect_true(all(w$iptw > 0))
  expect_true(all(w$siptw > 0))
})

test_that("match_eca reduces baseline imbalance in age", {
  skip_if_not_installed("MatchIt")
  d <- simulate_rwd(80, 400, seed = 4)
  raw_diff <- mean(d$age[d$treatment == 1]) - mean(d$age[d$treatment == 0])
  m <- match_eca(d, ratio = 2)
  m_diff <- mean(m$age[m$treatment == 1]) - mean(m$age[m$treatment == 0])
  expect_lt(abs(m_diff), abs(raw_diff))
})

test_that("fit_cox returns a tidy HR tibble for the treatment term", {
  d <- simulate_rwd(80, 400, seed = 5)
  res <- fit_cox(d)
  expect_s3_class(res, "tbl_df")
  expect_true("treatment" %in% res$term)
  hr <- res$estimate[res$term == "treatment"]
  expect_true(hr > 0)
})
