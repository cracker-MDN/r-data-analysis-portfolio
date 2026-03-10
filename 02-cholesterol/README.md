# 💊 Project 02 — Cholesterol Reduction Study

## Does a Margarine Diet Reduce Cholesterol — And For Whom Does It Work Best?

Repeated-measures analysis of a clinical nutrition study. 18 participants followed a low-fat diet incorporating margarine (Type A or B) containing 2.31g of stanol ester per day. Cholesterol measured at baseline, 4 weeks, and 8 weeks.

**Mayerfeld Data Analytics Certificate — Week 2**

---

## 📁 Files

```
02-cholesterol/
├── data/
│   └── Cholesterol.csv                # 18 participants, 5 variables
├── R/
│   ├── cholesterol_analysis.R         # Full analysis script
│   └── cholesterol_report.Rmd        # HTML report (knit to render)
├── outputs/
│   └── plots/                         # 8 ggplot2 charts (generated on run)
└── docs/
    └── homework_answers_w2.md         # W2 homework answers (paired t-tests section)
```

---

## 📊 Dataset

| Variable | Description | Type |
|---|---|---|
| `Before` | Cholesterol before diet (mmol/L) | Continuous |
| `After4weeks` | Cholesterol after 4 weeks (mmol/L) | Continuous |
| `After8weeks` | Cholesterol after 8 weeks (mmol/L) | Continuous |
| `Margarine` | Type A or B | Binary |

n = 18 · 9 Margarine A · 9 Margarine B

---

## 🔍 Key Findings

| Comparison | Mean Reduction | p-value | Cohen's d | Effect |
|---|---|---|---|---|
| Before → 4 Weeks | −0.566 mmol/L | < 0.001 | 3.64 | Very large |
| Before → 8 Weeks | −0.629 mmol/L | < 0.001 | 3.52 | Very large |
| 4 Weeks → 8 Weeks | −0.063 mmol/L | 0.0015 | 0.92 | Large |
| Margarine A vs B | — | 0.277 | — | Not significant |

**Rate:** 90% of total reduction occurs in weeks 0–4; effect continues but plateaus
**% Reduction:** Mean 9.84% at 8 weeks (range 5.9%–13.5%)
**Key insight:** Baseline cholesterol predicts reduction achieved (r = 0.56, p = 0.017) — higher-risk individuals benefit most

---

## 🛠️ Methods

Paired t-test · Shapiro-Wilk normality test · Cohen's d · Welch's t-test · Pearson correlation · Simple linear regression · ggplot2

---

## 🚀 Run

```r
source("R/cholesterol_analysis.R")
# or
rmarkdown::render("R/cholesterol_report.Rmd", output_dir="outputs/")
```
