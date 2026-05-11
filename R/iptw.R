#' Compute Inverse Probability of Treatment Weights (IPTW)
#'
#' Fits a logistic propensity score model and returns the input data with
#' three additional columns: the estimated propensity score `ps`, the
#' unstabilized IPT weight `iptw`, and the stabilized IPT weight `siptw`.
#'
#' Stabilized weights are generally preferred to reduce variance,
#' especially when extreme propensity scores are present.
#'
#' @param data A data frame containing `treatment` and the baseline
#'   covariates `age`, `sex`, `ecog`, `biomarker`, `prior_lines`.
#'
#' @return The input tibble with columns `ps`, `iptw`, `siptw` appended.
#' @importFrom stats glm binomial predict
#' @export
#'
#' @examples
#' d <- simulate_rwd(60, 400, seed = 1)
#' w <- compute_iptw(d)
#' summary(w$siptw)
compute_iptw <- function(data) {
  ps_fit <- stats::glm(
    treatment ~ age + sex + ecog + biomarker + prior_lines,
    data   = data,
    family = stats::binomial()
  )
  ps <- stats::predict(ps_fit, type = "response")
  p_treat <- mean(data$treatment)

  iptw  <- ifelse(data$treatment == 1, 1 / ps, 1 / (1 - ps))
  siptw <- ifelse(data$treatment == 1, p_treat / ps,
                  (1 - p_treat) / (1 - ps))

  dplyr::mutate(
    data,
    ps    = ps,
    iptw  = iptw,
    siptw = siptw
  )
}
