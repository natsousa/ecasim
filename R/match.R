#' Build an external control arm via propensity score matching
#'
#' Wraps [MatchIt::matchit()] to produce a matched dataset suitable for
#' subsequent outcome analysis. Defaults to nearest-neighbor matching on
#' the logit of the propensity score with a caliper.
#'
#' @param data A data frame produced by [simulate_rwd()] (or compatible).
#' @param ratio Integer. Number of controls to match per treated patient.
#' @param caliper Numeric. Caliper width on the logit-PS scale (in pooled SDs).
#' @param method Character. Matching method passed to `MatchIt::matchit`.
#'
#' @return A data frame with the matched cohort. The column `weights`
#'   (matching weights) is appended by `MatchIt::match.data()`.
#' @export
#'
#' @examples
#' d <- simulate_rwd(60, 400, seed = 1)
#' m <- match_eca(d, ratio = 2)
#' table(m$treatment)
match_eca <- function(data, ratio = 3, caliper = 0.2, method = "nearest") {
  stopifnot(all(c("treatment", "age", "sex", "ecog", "biomarker",
                  "prior_lines") %in% names(data)))
  m <- MatchIt::matchit(
    treatment ~ age + sex + ecog + biomarker + prior_lines,
    data    = data,
    method  = method,
    ratio   = ratio,
    caliper = caliper,
    distance = "glm"
  )
  MatchIt::match.data(m)
}
