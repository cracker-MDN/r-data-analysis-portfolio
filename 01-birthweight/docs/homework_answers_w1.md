# Week 1 Homework — Answers & Workings
## Mayerfeld Data Analytics | Birthweight Dataset

---

### Q1. Mean birth weight for babies of non-smoking mothers?

**Answer: 3.5095 kg**

```r
mean(non_smokers$Birthweight)
# [1] 3.5095
```

---

### Q2. Mean birth weight for babies of smoking mothers?

**Answer: 3.1341 kg**

```r
mean(smokers$Birthweight)
# [1] 3.1341
```

> 📌 Smoking mothers' babies had a mean birth weight ~0.38 kg lower than non-smokers.

---

### Q3. Mean head circumference for babies of non-smoking mothers?

**Answer: 35.05 cm**

```r
mean(non_smokers$Headcirc)
# [1] 35.05
```

---

### Q4. Mean gestational age for babies of smoking mothers?

**Answer: 38.9545 weeks**

```r
mean(smokers$Gestation)
# [1] 38.9545
```

---

### Q5. Maximum head circumference for babies of non-smoking mothers?

**Answer: 39 cm**

```r
max(non_smokers$Headcirc)
# [1] 39
```

---

### Q6. Minimum gestational age for babies of smoking mothers?

**Answer: 33 weeks**

```r
min(smokers$Gestation)
# [1] 33
```

---

### Q7. Which is the better bet: smoking OR non-smoking mothers have a shorter pregnancy?

**Answer: Pregnancy period in smoking mothers is shorter**

| Group | Mean Gestation |
|---|---|
| Non-Smokers | 39.45 weeks |
| Smokers | 38.95 weeks |

---

### Q8. Justify the above choice

Smoking mothers had a mean gestational age of 38.95 weeks compared to 39.45 weeks for non-smoking mothers — a difference of 0.50 weeks. While the difference is modest in this small sample, the data supports that smoking mothers tend to have slightly shorter pregnancies on average.

---

### Q9. Birth weight range for babies of smoking mothers?

**Answer: 2.65 kg**

```r
max(smokers$Birthweight) - min(smokers$Birthweight)
# Min: 1.92 kg | Max: 4.57 kg | Range: 2.65 kg
```

---

### Q10. What does the birth weight range tell us about smoking vs non-smoking mothers?

A range of 2.65 kg in smoking mothers indicates considerable variability in the birth weights of babies born to smoking mothers. This spread suggests that smoking does not uniformly suppress birth weight — some babies of smoking mothers are born at healthy weights, while others are significantly low. This high variability could reflect differences in the number of cigarettes smoked, timing during pregnancy, or individual biological factors. It underscores the importance of looking beyond means alone when comparing groups.

---

### Q11. Are head circumference data for babies of smoking mothers normally distributed?

**Answer: Yes**

The Shapiro-Wilk test (p = 0.3724 > 0.05) fails to reject the null hypothesis of normality. We conclude the data are consistent with a normal distribution.

---

### Q12. Shapiro-Wilk significance value for head circumference (smoking mothers)?

**Answer: p = 0.3724**

```r
shapiro.test(smokers$Headcirc)
# W = 0.9537, p-value = 0.3724
```

---

### Q13. Z-score for head circumference of 35.05 (non-smoking mothers)?

**Answer: Z = 0.0000**

```
Mean (μ) = 35.05 cm
SD (σ)   = 2.0894 cm
X        = 35.05

Z = (X - μ) / σ = (35.05 - 35.05) / 2.0894 = 0.0000
```

> 📌 X = 35.05 is exactly at the mean, so Z = 0.

---

### Q14. How are birth weight data of non-smoking mothers skewed?

**Answer: Positively skewed (right-skewed)**

```r
library(moments)
skewness(non_smokers$Birthweight)
# [1] 0.3610
```

A skewness of +0.36 indicates a slight positive (right) skew — the tail extends to the right, meaning there are a few relatively high birth weights pulling the mean up.

---

### Q15. Are birth weight data for babies of smoking mothers normally distributed?

**Answer: Yes**

The Shapiro-Wilk test (p = 0.9495 > 0.05) strongly fails to reject normality.

---

### Q16. Shapiro-Wilk significance value for birth weight (smoking mothers)?

**Answer: p = 0.9495**

```r
shapiro.test(smokers$Birthweight)
# W = 0.9824, p-value = 0.9495
```

---

### Q17. How confident can we be that birth weight will be +/- 1 SD from the mean?

**Answer: ~68% confident**

By the empirical rule (68-95-99.7 rule) for normally distributed data:
- ±1 SD contains approximately **68%** of values
- Mean birth weight (all babies): 3.35 kg | SD: 0.67 kg
- Range: [2.68 kg, 4.02 kg]

We can be approximately **68% confident** that a randomly selected baby's birth weight will fall within ±1 SD of the mean.

---

### Q18. Probability that birth weight of a baby of a smoking mother is less than 4.2 kg?

**Answer: 95.43%**

```
Mean (μ) = 3.1341 kg
SD (σ)   = 0.6312 kg
X        = 4.2 kg

Z = (4.2 - 3.1341) / 0.6312 = 1.6886
P(Z < 1.6886) = 0.9543 → 95.43%
```

---

### Q19. Are length data for babies of non-smoking mothers normally distributed?

**Answer: Yes**

The Shapiro-Wilk test (p = 0.0704 > 0.05) fails to reject normality, though it is close to the threshold.

---

### Q20. Shapiro-Wilk significance value for baby length (non-smoking mothers)?

**Answer: p = 0.0704**

```r
shapiro.test(non_smokers$Length)
# W = 0.9123, p-value = 0.0704
```

---

### Q21. Z-score for baby length of 48.5 cm (non-smoking mothers)?

**Answer: Z = -1.0141**

```
Mean (μ) = 51.80 cm
SD (σ)   = 3.2541 cm
X        = 48.5 cm

Z = (48.5 - 51.80) / 3.2541 = -1.0141
```

A length of 48.5 cm is approximately 1 standard deviation below the mean for non-smoking mothers.

---

### Q22. Probability that baby length for non-smoking mothers will be more than 55 cm?

**Answer: 16.27%**

```
Mean (μ) = 51.80 cm
SD (σ)   = 3.2541 cm
X        = 55 cm

Z = (55 - 51.80) / 3.2541 = 0.9834
P(Z > 0.9834) = 1 - P(Z < 0.9834) = 1 - 0.8373 = 0.1627 → 16.27%
```

---

*Analysis completed in R using `stats`, `moments`, and `ggplot2` packages.*
