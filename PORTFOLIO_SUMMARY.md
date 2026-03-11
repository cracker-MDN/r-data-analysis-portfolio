# Portfolio Summary — Key Numbers at a Glance

**MD Noornabi · Mayerfeld Data Analytics Certificate · March 2026**

---

## Project 01 — Birthweight

| Metric | Value |
|---|---|
| Sample | 42 babies (20 non-smoker, 22 smoker mothers) |
| Mean BW non-smokers | 3.510 kg |
| Mean BW smokers | 3.134 kg |
| Difference | −0.376 kg |
| Welch t-test | t=2.11, p=0.041 |
| Cohen's d | 0.65 (medium-to-large) |
| Point-biserial r (smoker vs BW) | r=−0.314, p=0.043 |
| Regression (length ~ mheight) | R²=0.235, p=0.001 |
| Normality | All variables normal (Shapiro-Wilk p>0.05) |

---

## Project 02 — Cholesterol

| Metric | Value |
|---|---|
| Sample | 18 participants, 3 timepoints |
| Before → 4 weeks | −0.566 mmol/L, t=15.44, p<0.001, d=3.64 |
| Before → 8 weeks | −0.629 mmol/L, t=14.95, p<0.001, d=3.52 |
| 4 weeks → 8 weeks | −0.063 mmol/L, t=3.78, p=0.001, d=0.89 |
| Speed of reduction | 90% in weeks 0–4, 10% in weeks 4–8 |
| Baseline vs reduction | r=0.556, p=0.017 |
| Margarine A vs B (8wks) | p=0.277 (not significant) |

---

## Project 03 — Crime

| Metric | Value |
|---|---|
| Sample | 47 US states, 27 variables, 2 timepoints |
| Top predictor | Log(Expenditure), r=+0.666, p<0.001 |
| Wage vs crime | r=+0.425, p=0.003 |
| Multiple regression R² | 0.629 (Adj. R²=0.574) |
| Predictors | LogExpenditure, Wage, StateSize, BelowWage |
| Southern vs non-Southern | p=0.691 (not significant) |
| Youth unemployment effect | p=0.062, d=0.60 (borderline) |
| 10-year crime persistence | r=0.997, p<0.001 |
| Overall 10-year change | mean=−0.74, p=0.640 (not significant) |

---

## Project 04 — Titanic

| Metric | Value |
|---|---|
| Sample | 1,309 passengers, 15 variables |
| Overall survival | 38.2% (500/1,309) |
| Gender effect | Female 72.7% vs Male 19.1% — OR=11.3x, p<0.001 |
| Class effect | 1st 61.9% → 2nd 43.0% → 3rd 25.5% — OR=4.74x, p<0.001 |
| Children 1st/2nd class | ~87% survived |
| Children 3rd class | 36.8% survived |
| 3rd class women | 49.1% — less than 1st class men (34.1%) |
| Family sweet spot | Size 3 = 69.8% · Size 7 = 0% |
| Family ANOVA | F=51.4, p<0.001 |
| British vs American | 31.8% vs 56.2% (explained by class composition) |
| Logistic regression | McFadden Pseudo-R²=0.32, n=1,037 complete cases |
| Age | p=0.077 — not significant (20% missing, non-random) |

---

## Methods Coverage Across Portfolio

`descriptive statistics` · `normality testing` · `Welch t-test` · `paired t-test` · `chi-square` · `Pearson correlation` · `point-biserial correlation` · `simple linear regression` · `multiple linear regression` · `binary logistic regression` · `one-way ANOVA` · `Cohen's d` · `odds ratios` · `McFadden pseudo-R²` · `log transformation` · `missing data analysis` · `confound identification` · `longitudinal analysis` · `ggplot2 visualisation` · `R Markdown reporting`
