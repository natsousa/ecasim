#' Fit a Cox proportional hazards model on the treatment effect
#'
#' Convenience wrapper around [survival::coxph()] that returns a tidy
#' tibble with the hazard ratio, 95% confidence interval and p-value for
#' the treatment indicator. If `weights` is supplied, a weighted Cox
#' model with a robust ("sandwich") variance estimator is used; this is
#' appropriate for IPTW analyses.
#'
#' @param data A data frame with columns `time_months`, `event`, `treatment`.
#' @param weights Optional numeric vector of patient weights (e.g., IPTW).
#' @param extra_covars Optional character vector of additional covariate
#'   names to include in the model (for doubly-robust adjustment).
#'
#' @return A [tibble][tibble::tibble-package] of tidied model coefficients
#'   on the hazard-ratio scale.
#'
#' @importFrom stats as.formula
#' @export
#'
#' @examples
#' d <- simulate_rwd(60, 400, seed = 1)
#' fit_cox(d)
fit_cox <- function(data, weights = NULL, extra_covars = NULL) {
  rhs <- c("treatment", extra_covars)
  form <- stats::as.formula(
    paste("survival::Surv(time_months, event) ~", paste(rhs, collapse = " + "))
  )
  fit <- if (is.null(weights)) {
    survival::coxph(form, data = data)
  } else {
    survival::coxph(form, data = data, weights = weights, robust = TRUE)
  }
  broom::tidy(fit, exponentiate = TRUE, conf.int = TRUE)
}
