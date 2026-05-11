#' Simulate a confounded EHR-like cohort with an embedded trial arm
#'
#' Generates a synthetic real-world dataset suitable for demonstrating
#' external control arm methodology. Treatment assignment is intentionally
#' confounded by baseline covariates so that naive comparisons are biased
#' and propensity score adjustment is required.
#'
#' The data-generating process mimics the structure of an oncology cohort:
#' patients enrolled in a single-arm investigational trial (treatment = 1)
#' tend to be younger, fitter (lower ECOG), with fewer prior lines of
#' therapy and more favorable biomarker values than the broader real-world
#' control population (treatment = 0). The true treatment effect on
#' overall survival is a hazard ratio of approximately 0.7.
#'
#' @param n_trial Integer. Number of patients in the (single-arm) trial cohort.
#' @param n_external Integer. Number of patients in the external (RWD) cohort.
#' @param seed Integer. RNG seed for reproducibility.
#'
#' @return A [tibble][tibble::tibble-package] with one row per patient and
#'   columns:
#'   \describe{
#'     \item{patient_id}{Character ID.}
#'     \item{age}{Age in years.}
#'     \item{sex}{Factor with levels F, M.}
#'     \item{ecog}{ECOG performance status, factor 0/1/2.}
#'     \item{biomarker}{Standardized continuous biomarker.}
#'     \item{prior_lines}{Number of prior lines of therapy.}
#'     \item{treatment}{1 = trial drug, 0 = real-world control.}
#'     \item{time_months}{Observed follow-up time in months.}
#'     \item{event}{1 = event observed, 0 = censored.}
#'   }
#'
#' @importFrom stats rnorm rbinom rpois rexp plogis
#' @export
#'
#' @examples
#' df <- simulate_rwd(n_trial = 60, n_external = 400, seed = 1)
#' table(df$treatment)
simulate_rwd <- function(n_trial = 80, n_external = 800, seed = 42) {
  stopifnot(n_trial > 0, n_external > 0)
  set.seed(seed)
  n <- n_trial + n_external

  age         <- stats::rnorm(n, mean = 65, sd = 10)
  sex         <- stats::rbinom(n, size = 1, prob = 0.45)
  ecog        <- sample(0:2, n, replace = TRUE, prob = c(0.40, 0.45, 0.15))
  biomarker   <- stats::rnorm(n, mean = 0, sd = 1)
  prior_lines <- stats::rpois(n, lambda = 1.2)

  # Latent eligibility score (younger, fitter, more biomarker-positive
  # patients are more likely to enter the trial). The top n_trial scores
  # are deterministically assigned to the trial arm to mimic eligibility
  # criteria.
  elig_score <- -0.04 * (age - 65) - 0.8 * ecog + 0.5 * biomarker -
    0.4 * prior_lines + stats::rnorm(n, sd = 0.5)
  ord <- order(elig_score, decreasing = TRUE)
  treatment <- integer(n)
  treatment[ord[seq_len(n_trial)]] <- 1L

  # Outcome model: true HR for treatment ~ 0.7 (log(0.7) ~ -0.357)
  log_hr_true <- log(0.7)
  lp <- 0.03 * (age - 65) + 0.45 * ecog - 0.30 * biomarker +
    0.20 * prior_lines + log_hr_true * treatment
  baseline_rate <- 0.04   # per month
  rate <- baseline_rate * exp(lp)
  event_time <- stats::rexp(n, rate = rate)
  cens_time  <- stats::rexp(n, rate = 0.015)
  admin_cens <- 36   # 3-year administrative cutoff
  obs_time   <- pmin(event_time, cens_time, admin_cens)
  event      <- as.integer(event_time <= pmin(cens_time, admin_cens))

  tibble::tibble(
    patient_id  = sprintf("P%05d", seq_len(n)),
    age         = round(age, 1),
    sex         = factor(sex, levels = 0:1, labels = c("F", "M")),
    ecog        = factor(ecog, levels = 0:2),
    biomarker   = round(biomarker, 3),
    prior_lines = prior_lines,
    treatment   = treatment,
    time_months = round(obs_time, 2),
    event       = event
  )
}
