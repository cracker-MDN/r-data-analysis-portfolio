# 🍼 Project 01 — Birthweight Analysis

## Does Maternal Smoking Affect Infant Outcomes?

Exploratory and inferential analysis of a neonatal dataset (n=42) examining the relationship between maternal smoking and infant birth weight, head circumference, gestational age, and body length. Extended in Week 2 to introduce correlation analysis and simple linear regression.

**Mayerfeld Data Analytics Certificate — Weeks 1 & 2**

---

## 📁 Files

```
01-birthweight/
├── data/
│   └── Birthweight.csv                      # 42 babies, 16 variables
├── R/
│   ├── birthweight_analysis.R               # W1: EDA, descriptive stats, normality, probability
│   ├── birthweight_correlation_regression.R # W2: Correlation & regression extension (HW Q1–Q30)
│   └── birthweight_report.Rmd              # Full HTML report (knit to render)
├── outputs/
│   └── plots/                               # 8+ ggplot2 charts (generated on run)
└── docs/
    ├── homework_answers_w1.md               # W1 answers: descriptive stats, z-scores, normality
    └── homework_answers_w2.md               # W2 answers: correlation, regression (Q1–Q30)
```

---

## 📊 Dataset

| Variable | Description | Type |
|---|---|---|
| `Birthweight` | Birth weight in kg — main outcome | Continuous |
| `Length` | Baby length (cm) | Continuous |
| `Headcirc` | Head circumference (cm) | Continuous |
| `Gestation` | Gestational age (weeks) | Continuous |
| `smoker` | Maternal smoking (0=No, 1=Yes) | Binary |
| `mnocig` | Cigarettes per day (mother) | Continuous |
| `lowbwt` | Low birth weight flag | Binary |
| `mheight`, `mppwt`, `mage` | Maternal characteristics | Continuous |
| `fheight`, `fage`, `fedyrs`, `fnocig` | Paternal characteristics | Continuous |

> Birth weights of smoking mothers' babies were slightly adjusted for educational purposes.

---

## 🔍 Key Findings

| Measure | Non-Smokers | Smokers | Difference |
|---|---|---|---|
| Mean birth weight | 3.510 kg | 3.134 kg | **−0.376 kg** |
| Mean gestational age | 39.45 wks | 38.95 wks | −0.50 wks |
| Mean head circumference | 35.05 cm | 33.95 cm | −1.10 cm |
| % Low birth weight | 5.0% | 36.4% | **+31.4 pp** |

**Dose-response:** Each additional cigarette/day ≈ −18g in birth weight (r = −0.30)

**Regression (W2):** Mother's height significantly predicts baby length (R² = 0.235, p = 0.001); predicted length for 170cm mother = 52.55cm

---

## 🛠️ Methods

| Week | Methods |
|---|---|
| W1 | Descriptive stats, Shapiro-Wilk, skewness/kurtosis, z-scores, pnorm(), Welch's t-test, Cohen's d, chi-square, OLS regression, ggplot2 |
| W2 | Pearson correlation, Point-Biserial correlation, simple linear regression, residual analysis, R² vs adjusted R² |

---

## 🚀 Run

```r
# Week 1 analysis
source("R/birthweight_analysis.R")

# Week 2 correlation & regression extension
source("R/birthweight_correlation_regression.R")

# Full HTML report
rmarkdown::render("R/birthweight_report.Rmd", output_dir="outputs/")
```
