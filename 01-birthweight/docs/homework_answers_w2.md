# Week 2 Homework — Answers & Workings
## Mayerfeld Data Analytics | Birthweight Dataset — Correlation & Regression

---

## PART A — Selecting the Right Correlation Test

### Q1. Which test for birth weight vs father's age?
**Answer: Pearson product-moment correlation**

### Q2. Justify the choice
Both birth weight and father's age are **continuous, scale variables**. The Pearson test measures the strength and direction of a linear relationship between two normally distributed continuous variables — appropriate here.

### Q3. Direction of the relationship?
**Answer: Positive** — r = 0.1757. Older fathers very slightly associated with higher birth weight.

### Q4. Form of the relationship?
**Answer: Linear**

### Q5. Degree of the relationship?
**r = 0.1757, p = 0.2657** — weak positive correlation, **not statistically significant**. Father's age has little practical relationship with birth weight in this sample.

---

### Q6. Which test for smoking vs birth weight?
**Answer: Point-Biserial correlation**

Smoking is a **binary variable** (0/1); birth weight is continuous. Point-Biserial is the appropriate test when one variable is dichotomous and the other is continuous.

### Q7. Results — direction, form, degree
- **r = −0.3142, p = 0.0427**
- **Direction:** Negative — smoking is associated with lower birth weight
- **Form:** Linear
- **Degree:** Moderate negative correlation
- **Significance:** Yes — p < 0.05

---

## PART B — Scatterplot & Linearity

### Q8. Independent variable for length vs birth weight?
**Answer: Length of baby**
The variable doing the predicting is the independent variable. We're asking: does length predict birth weight?

### Q9. Scatterplot
See `outputs/plots/09_length_vs_birthweight.png` — length on x-axis, birth weight on y-axis, with OLS regression line.

### Q10. Is the relationship linear?
**Answer: Yes**

### Q11. Justification
r = 0.7268 — strong positive Pearson correlation. The scatterplot shows points clustering around a straight diagonal line with no visible curve or bend.

---

## PART C — Multivariate Correlation

### Q12. Are birth weight, length, and head circumference related?
**Answer: Yes**

### Q13. Justification
All three Pearson correlations are positive and statistically meaningful:
- Birth weight × Length: **r = 0.7268**
- Birth weight × Head circumference: **r = 0.6846**
- Length × Head circumference: **r = 0.5632**

### Q14. Description in own words
Larger babies tend to be heavier, longer, and have bigger heads — all at once. This reflects overall fetal size, which drives all three measures together. A baby that grows bigger in one dimension tends to grow bigger across all dimensions.

---

## PART D — Regression Concepts

### Q15. What is a residual?
A residual is the **difference between an observed value and the value predicted by the regression model**: `residual = y_observed − y_predicted`. It represents how far each individual data point falls from the fitted regression line. Small residuals = good fit; large residuals = poor fit.

### Q16. Residual pattern — linear better for lower or higher values?
If residuals are small and randomly scattered at lower values of the independent variable but fan out (increase in spread) at higher values, the linear model is a **better approximation at lower values**, where variance is smaller and the fit is tighter.

### Q17. Difference between R² and adjusted R²?
- **R²** = the proportion of variance in the dependent variable explained by the model. Always increases when you add more predictors, even irrelevant ones
- **Adjusted R²** = R² penalised for the number of predictors. Decreases if a new predictor doesn't improve the model enough to justify its inclusion. More appropriate for comparing models with different numbers of predictors

---

## PART E — Regression: Baby Length ~ Mother's Height

### Q18. Independence of observations?
**Answer: Yes**

### Q19. Justification
Each row in the dataset represents a **different, unrelated mother-baby pair**. There are no repeated measurements of the same person — observations are independent.

### Q20. Do residuals show homoscedasticity?
**Answer: Yes** (approximately)

### Q21. Justification
The residual plot shows roughly even spread of residuals across the range of fitted values — no clear funnelling, cone shape, or systematic pattern. Constant variance (homoscedasticity) appears to be satisfied.

### Q22. R² value and meaning?
**R² = 0.2352**
Mother's height explains approximately **23.5% of the variance** in baby length. The remaining 76.5% is attributable to other factors not captured by this single-predictor model.

### Q23. Is this a statistically significant linear relationship?
**Yes** — p = 0.0011 (well below 0.05). There is sufficient evidence to conclude a significant positive linear relationship between mother's height and baby length.

### Q24. ANOVA null and alternative hypothesis
- **H₀:** β₁ = 0 — the regression model does not explain a significant amount of variance in baby length (mother's height has no linear effect)
- **H₁:** β₁ ≠ 0 — the regression model explains a significant amount of variance (mother's height does have a linear effect)

### Q25. What is b₁?
b₁ is the **slope** of the regression line — the predicted change in the dependent variable (baby length) for every 1-unit increase in the independent variable (mother's height), holding all else constant.

### Q26. What does b₁ = 0.2189 tell us practically?
For every **1 cm increase in mother's height**, baby length is predicted to increase by **0.2189 cm** on average.

### Q27. Can we claim the same for mother's height 140–145cm?
**No.** There are no data points in the 140–145cm range in this dataset. **Extrapolating the model beyond the observed range of the data is unreliable** — the linear relationship may not hold at those values, and we have no empirical basis to trust the prediction there.

### Q28. Predicted baby length for mother's height = 170cm?
```
Length = 15.3342 + (0.2189 × 170) = 52.55 cm
```
**Answer: 52.55 cm**

### Q29. Report on findings
Mother's height is a statistically significant predictor of baby length (b₁ = 0.219 cm/cm, p = 0.001, R² = 0.235). The model predicts that for every additional centimetre in mother's height, baby length increases by approximately 0.22 cm. While the relationship is significant, R² = 0.235 indicates the model explains only about a quarter of the variance — other biological and environmental factors also play important roles.

### Q30. Can father's age predict baby length?
**No.**
- r = 0.137, p = 0.387 — not statistically significant
- The correlation is very weak and could easily be due to chance
- Father's age is not a reliable predictor of baby length in this dataset
