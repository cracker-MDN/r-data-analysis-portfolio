# 🔍 Project 03 — US State Crime Rate Analysis

## What Predicts Crime? A Socioeconomic Analysis Across 47 US States

Multi-variable regression and longitudinal analysis of crime rates across 47 US states at two timepoints (Year 0 and Year 10). The analysis goes beyond identifying predictors to interpreting three counterintuitive paradoxes — and uncovers one of the most striking findings in the portfolio: crime rates are structurally persistent to a near-perfect degree (r = 0.997 across 10 years).

**Mayerfeld Data Analytics Certificate — Week 3**

---

## 📁 Files

```
03-crime/
├── data/
│   └── Crime.csv                   # 47 US states, 27 variables, 2 timepoints
├── R/
│   ├── crime_analysis.R            # Full analysis script
│   └── crime_report.Rmd           # HTML report (knit to render)
├── outputs/
│   └── plots/                      # 13 ggplot2 charts (auto-generated)
└── docs/
    └── analysis_notes.md           # Key findings, paradoxes, interpretation guide
```

---

## 📊 Dataset

| Variable | Description | Type |
|---|---|---|
| `CrimeRate` / `CrimeRate10` | Offences per million population | Continuous |
| `ExpenditureYear0` / `10` | Per capita police expenditure *(skewed)* | Continuous |
| `Wage` / `Wage10` | Median weekly wage | Continuous |
| `Education` / `10` | Mean years of schooling (to age 25) | Discrete |
| `Southern` | Southern state (1=yes) | Binary |
| `BelowWage` / `10` | Families below half-wage per 1000 | Discrete |
| `Youth` / `10` | Males aged 18–24 per 1000 | Discrete |
| `YouthUnemployment` / `10` | Unemployed males 18–24 per 1000 *(skewed)* | Discrete |
| `HighYouthUnemploy` | High youth unemployment flag | Binary |
| `StateSize` / `10` | State size (hundred thousands) | Discrete |

n = 47 states · 13 variables at Year 0 · same variables repeated at Year 10

---

## 🔍 The Three Paradoxes

This analysis is structured around three counterintuitive findings that require interpretation beyond mechanical correlation reporting:

**Paradox 1 — Police Expenditure (r = +0.65)**
More police spending → more crime? The obvious challenge is reverse causation. But Year 0 expenditure predicts Year 10 crime just as strongly (r = +0.644) — ruling out pure reverse causation. The relationship is structural and bidirectional.

**Paradox 2 — Wage (r = +0.42)**
Higher wages → more crime? Wage is a proxy for urbanisation. High-wage states are more urban — and urban areas have higher crime rates AND greater prosperity (fewer families below poverty). Wage is a confounding variable, not a causal driver.

**Paradox 3 — Education (r = +0.16, ns)**
More education doesn't reduce crime? Same urbanisation confound. More educated states are more urban, masking education's direct protective effect.

---

## 🔑 Key Findings

| Finding | Value | Significance |
|---|---|---|
| Top predictor | Log(Expenditure), r = +0.666 | p < 0.001 |
| Wage vs crime | r = +0.425 | p = 0.003 |
| State size vs crime | r = +0.308 | p = 0.035 |
| Multiple regression R² | 0.629 (adj. 0.574) | 4 predictors |
| Southern vs non-Southern crime | p = 0.691 | Not significant |
| Youth unemployment (high vs low) | p = 0.062, d = 0.60 | Borderline — power limited |
| **Crime persistence (r, t0 vs t10)** | **r = 0.997** | **p < 0.001** |
| Overall crime change over 10 yrs | Mean = −0.74 | p = 0.640 (ns) |

---

## 🛠️ Methods

| Method | Purpose |
|---|---|
| Descriptive statistics | Overview of crime rate at both timepoints |
| Log transformation | Correct positive skew in Expenditure (0.92 → 0.28) |
| Pearson correlation | Identify continuous predictors |
| Shapiro-Wilk | Check normality assumptions |
| Welch's t-test + Cohen's d | Southern vs non-Southern, High vs Low youth unemployment |
| Multiple linear regression | Predictive model — 4 variables, R² = 0.629 |
| Standardised coefficients (β) | Compare predictor importance on same scale |
| Residual analysis | Validate regression assumptions |
| Paired t-test | Test overall crime rate change over 10 years |
| Persistence correlation | Structural stability analysis (r = 0.997) |

---

## 🚀 Run

```r
setwd("path/to/03-crime")
source("R/crime_analysis.R")
# or
rmarkdown::render("R/crime_report.Rmd", output_dir="outputs/")
```

Required packages: `tidyverse`, `ggplot2`, `ggcorrplot`, `gridExtra`, `moments`, `reshape2`, `scales`
