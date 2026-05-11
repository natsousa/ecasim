# ecasim — External Control Arm with Propensity Score Methods

> A teaching-grade, fully reproducible Real-World Evidence (RWE) project.
> Builds an **external control arm (ECA)** for a single-arm Phase II trial
> from a synthetic EHR-like cohort and estimates the treatment effect on
> overall survival using **propensity score matching** and **IPTW**.

[![render-report](https://github.com/your-org/ecasim/actions/workflows/render.yml/badge.svg)](https://github.com/your-org/ecasim/actions/workflows/render.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE.md)

---

## Why this project exists

In early oncology drug development, single-arm Phase I/II trials are common
because randomization is often impractical. To interpret outcomes, sponsors
increasingly contextualize the trial arm against a **real-world external
control arm** (ECA) drawn from EHRs, claims, or registries. Both **FDA**
and **EMA** have published guidance on the rigorous use of RWD for
regulatory decision-making.

This repository walks through, end to end, how an RWE statistician would:

1. Simulate (or load) a confounded RWD cohort.
2. Estimate a **propensity score** model.
3. Build an ECA via **nearest-neighbor PS matching**.
4. Reweight using **stabilized IPTW**.
5. Compare survival with **Cox proportional hazards** under both adjustments.
6. Render a regulator-style **Quarto report**.

Every step lives inside an installable R package (`ecasim`) so the helper
functions are unit-tested and reusable across studies — a pattern aligned
with **Methodological Excellence: reproducible, statistically rigorous,
scalable analytical frameworks**.

---

## Repository layout

```
ecasim/
├── .devcontainer/devcontainer.json   # one-click reproducible env
├── .github/workflows/render.yml      # CI: tests + renders the report
├── DESCRIPTION                       # R package metadata
├── NAMESPACE                         # exported functions
├── R/                                # package source
│   ├── ecasim-package.R
│   ├── simulate.R                    # simulate_rwd()
│   ├── match.R                       # match_eca()
│   ├── iptw.R                        # compute_iptw()
│   └── analyze.R                     # fit_cox()
├── man/                              # roxygen-generated help pages
├── tests/testthat/                   # unit tests (testthat 3e)
├── analysis/
│   ├── report.qmd                    # the Quarto walkthrough
│   ├── references.bib                # literature references
│   └── _quarto.yml
├── Makefile                          # `make install | test | render`
├── LICENSE / LICENSE.md              # MIT
└── README.md
```

---

## Quick start

### Option A — VS Code Dev Container (recommended)

1. Install [Docker](https://www.docker.com/) and the
   [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
   VS Code extension.
2. Open this folder in VS Code.
3. `F1` → **Dev Containers: Reopen in Container**.
4. Wait for the container to build (it will install R 4.4 + Quarto +
   all required R packages from the [Posit Public Package Manager](https://packagemanager.posit.co/) mirror).
5. From the integrated terminal:

   ```bash
   make test     # run unit tests
   make render   # render analysis/report.qmd → analysis/report.html
   ```

### Option B — local R install

You will need R ≥ 4.3 and Quarto ≥ 1.4.

```r
install.packages(c(
  "devtools", "MatchIt", "survival", "survminer", "broom",
  "gtsummary", "tibble", "dplyr", "ggplot2", "knitr"
))
devtools::install(".")
```

```bash
quarto render analysis/report.qmd
open analysis/report.html
```

---

## What you will learn

- Why **selection bias** between trial and RWD cohorts produces a biased
  HR if ignored.
- How to estimate, diagnose, and use a **propensity score**.
- The trade-offs between **matching** and **IPTW**.
- How to interpret a Cox **hazard ratio** with a robust variance estimator.
- How to package a study as an installable R package + Quarto report so
  the analysis is **reproducible** and **auditable**.

---

## Reproducibility

- **Pinned R version** via the rocker-org dev-container image
  (`tidyverse:4.4`).
- **Pinned package set** declared in `DESCRIPTION` (and resolvable via
  `renv::init()` if you want lockfile-grade reproducibility).
- **Deterministic seeds** in `simulate_rwd()` and the report.
- **CI** renders the report on every push to `main`, so reviewers can see
  exactly what the maintainer saw.

---

## Extending this project

Reasonable next steps for a learner:

- Replace `simulate_rwd()` with a real (de-identified) EHR extract.
- Add **doubly-robust** estimators (e.g., AIPW via `WeightIt` + outcome model).
- Add a **negative control outcome** analysis to detect residual confounding.
- Add **E-value** sensitivity analysis (`EValue::evalues.HR`).
- Pre-register the analysis plan and lock the codebase with `renv::snapshot()`.

---

## License

MIT — see [LICENSE.md](LICENSE.md).

## Disclaimer

This project is **for education only**. The synthetic data and analyses
do not constitute clinical or regulatory advice.
