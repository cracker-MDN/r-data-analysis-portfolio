# Week 2 Homework — Answers & Workings
## Mayerfeld Data Analytics | Birthweight & Cholesterol Datasets

---

## PART A — Correlation (Birthweight Dataset)

### Q1. Which test for birth weight vs father's age?
**Answer: Pearson product-moment correlation**

### Q2. Justify the choice
Both birth weight and father's age are continuous, scale variables. The Pearson test measures the strength and direction of a **linear relationship** between two normally distributed continuous variables — appropriate here.

### Q3. Direction of the relationship?
**Answer: Positive** (r = 0.1757) — older fathers very weakly associated with higher birth weight.

### Q4. Form of the relationship?
**Answer: Linear**

### Q5. Degree of the relationship?
**Answer: r = 0.1757, p = 0.2657** — weak positive correlation, **not statistically significant**.

---

### Q6. Test for smoking vs birth weight?
**Answer: Point-Biserial correlation**
Smoking is a **binary variable** (0/1); birth weight is continuous. Point-Biserial is the appropriate test when one variable is dichotomous.

### Q7. Results including direction/form/degree
- r = −0.3142, p = 0.0427
- **Direction:** Negative — smoking is associated with lower birth weight
- **Form:** Linear
- **Degree:** Moderate negative correlation, **statistically significant** (p < 0.05)

---

### Q8. Independent variable for length vs birth weight?
**Answer: Length of baby** (the variable doing the predicting = independent)

### Q9. Scatterplot
See `outputs/plots/05_length_vs_birthweight.png` — length on x-axis, birth weight on y-axis, with regression line.

### Q10. Is the relationship linear?
**Answer: Yes**

### Q11. Justification
r = 0.7268 — strong positive Pearson correlation. The scatterplot shows points clustering around a straight line with no obvious curve.

---

### Q12. Are birth weight, length, and head circumference related?
**Answer: Yes**

### Q13. Justification
All three Pearson correlations are positive and strong:
- BW × Length: r = 0.7268
- BW × Head circumference: r = 0.6846
- Length × Head circumference: r = 0.5632

### Q14. Description
Larger babies tend to be heavier, longer, and have larger heads simultaneously. This makes intuitive sense — overall fetal size affects all three measures together.

---

### Q15. What is a residual?
A residual is the **difference between the observed value and the value predicted by the regression model**: `residual = y_observed − y_predicted`. It represents how far each data point falls from the regression line.

### Q16. Residual pattern — linear better for lower or higher values?
If residuals are small and random at lower values but fan out at higher values, the model is **better approximated at lower values** of the independent variable (where variance is smaller and the linear fit is tighter).

### Q17. Difference between R² and adjusted R²?
- **R²** = proportion of variance in the dependent variable explained by the model
- **Adjusted R²** = R² penalised for the number of predictors added; prevents artificially inflating R² by adding irrelevant variables. More meaningful in multiple regression.

---

### Q18. Independence of observations — mother's height predicting baby length?
**Answer: Yes**

### Q19. Justification
Each row represents a **different mother-baby pair** — no repeated measures or nested data. Observations are independent.

### Q20. Do residuals show homoscedasticity?
**Answer: Yes** (approximately)

### Q21. Justification
The residual plot shows roughly even spread of residuals across fitted values — no clear funnelling or patterned spread, suggesting constant variance (homoscedasticity).

---

### Q22. R² value and meaning?
**R² = 0.2352**
Mother's height explains approximately **23.5% of the variance** in baby length. The remaining 76.5% is attributable to other factors not in the model.

### Q23. Is this a statistically significant linear relationship?
**Yes** — p = 0.0011 (< 0.05). We can conclude there is a significant positive linear relationship between mother's height and baby length.

### Q24. ANOVA null and alternative hypothesis
- **H₀:** The regression model does not explain a significant amount of variance in baby length (β₁ = 0)
- **H₁:** The regression model explains a significant amount of variance (β₁ ≠ 0)

### Q25. What is b₁?
b₁ is the **slope** of the regression line — the amount the dependent variable (baby length) changes for every 1-unit increase in the independent variable (mother's height).

### Q26. What does b₁ = 0.2189 tell us?
For every **1 cm increase in mother's height**, baby length is predicted to increase by **0.2189 cm**, holding all else constant.

### Q27. Can we claim the same for mother's height 140–145cm?
**No.** There are no data points in the 140–145cm range in this dataset. Extrapolating the model beyond the observed data range is unreliable — the relationship may not hold at those values.

### Q28. Predicted baby length for mother's height = 170cm?
```
Length = 15.3342 + (0.2189 × 170) = 52.55 cm
```
**Answer: 52.55 cm**

### Q29. Report on findings
Mother's height is a statistically significant predictor of baby length (b₁ = 0.219, p = 0.001, R² = 0.235). The model predicts that for every additional centimetre in mother's height, baby length increases by approximately 0.22cm. The model explains 23.5% of variance — meaningful but indicating other factors also influence baby length.

### Q30. Can father's age predict baby length?
**No.** r = 0.137, p = 0.387 — the relationship is not statistically significant. Father's age is not a reliable predictor of baby length in this dataset.

---

## PART B — Cholesterol Dataset (Paired t-Tests)

| Comparison | t | p | Cohen's d |
|---|---|---|---|
| Before vs After 4 weeks | 15.44 | < 0.001 | 3.64 |
| Before vs After 8 weeks | 14.95 | < 0.001 | 3.52 |
| After 4 vs After 8 weeks | 3.78 | 0.0015 | 0.92 |
| Margarine A vs B (8 wks) | −1.13 | 0.277 | n/a |

- Diet significantly reduced cholesterol at both time points
- Cholesterol continued to fall from week 4 to week 8
- No significant difference between margarine types
