# R Data Analysis Portfolio

**MD Noornabi** · Mayerfeld Data Analytics Certificate · March 2026

A portfolio of four end-to-end data analysis projects completed as part of the Mayerfeld Data Analytics Certificate. Each project follows a full analytical workflow: exploratory data analysis, statistical testing, visualisation, and written interpretation — all in R.

---

## Projects

### [Project 01 — Birthweight: Does Maternal Smoking Affect Infant Outcomes?](./01-birthweight/)
> *42 babies · 16 variables · Weeks 1 & 2*

Investigated whether maternal smoking is associated with lower birth weight, head circumference, gestational age and length. Key finding: babies born to smoking mothers weighed 376g less on average (p=0.041, Cohen's d=0.65).

**Methods:** descriptive statistics · Shapiro-Wilk · Welch t-test · chi-square · correlation · simple linear regression

---

### [Project 02 — Cholesterol: Does Margarine Reduce Cholesterol?](./02-cholesterol/)
> *18 participants · 3 timepoints · Week 2*

Examined whether a cholesterol-lowering margarine produced significant reductions over 8 weeks. 90% of reduction occurred in the first 4 weeks. Baseline cholesterol predicted magnitude of reduction (r=0.556, p=0.017).

**Methods:** paired t-tests · Cohen's d · Pearson correlation · repeated-measures design

---

### [Project 03 — Crime: What Predicts US State Crime Rates?](./03-crime/)
> *47 US states · 27 variables · 2 timepoints · Week 3*

Identified socioeconomic predictors of state crime rates and tested 10-year persistence. Expenditure was the strongest predictor (r=+0.666) — a paradox explained by reverse causation. Multiple regression R²=0.629. Crime patterns showed near-perfect persistence over a decade (r=0.997).

**Methods:** EDA · log transformation · correlation · heatmap · multiple regression · group comparisons · longitudinal analysis

---

### [Project 04 — Titanic: Who Survived — and Why?](./04-titanic/)
> *1,309 passengers · 15 variables · Week 4*

The most comprehensive project in the portfolio. Survival was almost entirely structured by social position. Gender OR=11.3x · Class OR=4.74x · "Women and children first" only held in 1st/2nd class · Family size sweet spot at 3 · British vs American gap explained by class confounding.

**Methods:** chi-square · t-tests · ANOVA · odds ratios · binary logistic regression · McFadden pseudo-R² · confound analysis · predicted probability archetypes · missing data audit

---

## Skills Matrix

| Skill | P01 | P02 | P03 | P04 |
|---|:---:|:---:|:---:|:---:|
| Exploratory data analysis | ✓ | ✓ | ✓ | ✓ |
| Normality testing | ✓ | ✓ | ✓ | — |
| Independent samples t-test | ✓ | — | ✓ | ✓ |
| Paired t-test | — | ✓ | — | — |
| Chi-square test | ✓ | — | ✓ | ✓ |
| Pearson correlation | ✓ | ✓ | ✓ | — |
| Simple linear regression | ✓ | — | ✓ | — |
| Multiple linear regression | — | — | ✓ | — |
| Binary logistic regression | — | — | — | ✓ |
| Odds ratios | — | — | — | ✓ |
| Cohen's d effect size | ✓ | ✓ | ✓ | — |
| One-way ANOVA | — | — | — | ✓ |
| Log transformation | — | — | ✓ | ✓ |
| Missing data analysis | — | — | — | ✓ |
| Confound identification | — | — | ✓ | ✓ |
| Longitudinal analysis | — | — | ✓ | — |
| R Markdown reports | ✓ | ✓ | ✓ | ✓ |
| ggplot2 visualisation | ✓ | ✓ | ✓ | ✓ |

---

## Repo Structure

```
r-data-analysis-portfolio/
├── README.md
├── PORTFOLIO_SUMMARY.md
├── 01-birthweight/
├── 02-cholesterol/
├── 03-crime/
└── 04-titanic/
    ├── data/        ← raw CSV
    ├── R/           ← analysis.R + report.Rmd
    ├── outputs/     ← HTML report + plots/
    └── docs/        ← notes
```

---

## Tools

**Language:** R 4.5 · **IDE:** RStudio · **Version control:** GitHub Desktop  
**Packages:** tidyverse · ggplot2 · rmarkdown · knitr · gridExtra · scales · moments

---

📧 [LinkedIn](https://www.linkedin.com/in/md-noornabi) · 🐙 [GitHub](https://github.com/MDNoornabi)
