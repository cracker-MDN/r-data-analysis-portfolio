# Project 04 — Titanic Survival Analysis

> *"Who survived the Titanic — and why? Unpacking the role of class, gender, age, family size and nationality across 1,309 passengers."*

---

## The Question

The Titanic sank on April 14–15, 1912. Of 1,309 recorded passengers, only 500 survived (38.2%). This analysis investigates what determined survival — and finds that it was almost entirely structured by social position, not chance.

---

## Key Findings

| Finding | Result |
|---|---|
| Gender effect | Female 72.7% vs Male 19.1% — **OR = 11.3x** |
| Class effect | 1st 61.9% → 2nd 43.0% → 3rd 25.5% — **OR = 4.74x** |
| "Women & children first" | Only held in 1st and 2nd class |
| 3rd class children | 36.8% survived — same as adults overall |
| 3rd class women vs 1st class men | 49.1% vs 34.1% — **class overrode gender** |
| Family size sweet spot | Size 3 = 69.8% · Size 7+ = 0% |
| British vs American gap | Explained by class composition, not cultural "queuing" |
| Logistic regression | McFadden Pseudo-R² = 0.32 · Gender + class dominate |

---

## Analysis Structure

| Section | Focus | Methods |
|---|---|---|
| 1 | EDA & Missing Data Audit | Descriptive stats, missingness analysis |
| 2 | "Women and Children First" | Chi-square, odds ratios, children by class |
| 3 | Class: The Dominant Factor | Chi-square, fare t-test, class × gender heatmap |
| 4 | Family Size Sweet Spot | One-way ANOVA, granular 0–7 breakdown |
| 5 | British vs American | Chi-square, class composition confound analysis |
| 6 | Logistic Regression | Binary logistic regression, odds ratios, pseudo-R² |
| 7 | Survival Archetypes | Predicted probabilities for 6 passenger profiles |

---

## Files

```
04-titanic/
├── data/
│   └── Titanic.csv                  ← 1,309 passengers, 15 variables
├── R/
│   ├── titanic_analysis.R           ← full analysis script
│   └── titanic_report.Rmd           ← R Markdown report
├── outputs/
│   ├── titanic_report.html          ← rendered report
│   └── plots/                       ← 13 publication-quality plots
│       ├── 01_survival_overview.png
│       ├── 02_missing_data.png
│       ├── 03_gender_survival.png
│       ├── 04_women_children_first.png
│       ├── 05_children_by_class.png
│       ├── 06_class_survival.png
│       ├── 07_class_gender_heatmap.png
│       ├── 08_fare_survival.png
│       ├── 09_family_size.png
│       ├── 10_british_vs_american.png
│       ├── 11_nationality_class_confound.png
│       ├── 12_odds_ratios.png
│       └── 13_survival_archetypes.png
└── docs/
    └── analysis_notes.md
```

---

## How to Run

```r
# Set working directory to project root
setwd("path/to/04-titanic")

# Run full analysis (generates all 13 plots)
source("R/titanic_analysis.R")

# Render the report
rmarkdown::render("R/titanic_report.Rmd", output_dir="outputs/")
```

---

## Dataset

- **Source:** Mayerfeld Data Analytics Certificate — Week 4
- **n:** 1,309 passengers
- **Variables:** 15 (class, survival, gender, age, fare, family composition, nationality, embarkation)
- **Missing data:** Age 20.1% (non-random), Cabin 77.5% (by design)

---

## Methods Used

`descriptive statistics` · `chi-square tests` · `independent samples t-test` · `one-way ANOVA` · `odds ratios` · `binary logistic regression` · `McFadden pseudo-R²` · `missing data analysis` · `confound identification`
