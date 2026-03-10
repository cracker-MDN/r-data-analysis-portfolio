# =============================================================================
# Birthweight — Correlation & Regression Extension
# Mayerfeld Data Analytics Course | Week 2 (HW Q1–Q30)
# Author: [MD Noornabi]
# Date: March 2026
#
# Description:
#   Extension of the Week 1 birthweight EDA. Introduces correlation analysis
#   (Pearson, Point-Biserial) and simple linear regression to explore
#   relationships between infant and parental variables.
# =============================================================================

library(tidyverse)
library(ggplot2)

bw <- read.csv("data/Birthweight.csv")
bw$smoker_label <- factor(bw$smoker, levels=c(0,1), labels=c("Non-Smoker","Smoker"))

mytheme <- theme_minimal(base_size=13) +
  theme(plot.title=element_text(face="bold",size=14),
        plot.subtitle=element_text(color="grey40",size=11))

# =============================================================================
# SECTION 1: CHOOSING THE RIGHT CORRELATION TEST (Q1–Q7)
# =============================================================================
cat("\n=== SECTION 1: CORRELATION TESTS ===\n")

# Q1-Q5: Birth weight vs Father's age — Pearson
cor_bw_fage <- cor.test(bw$Birthweight, bw$fage, method="pearson")
cat("Q1.  Test: Pearson product-moment correlation\n")
cat("Q2.  Both variables are continuous and normally distributed.\n")
cat("Q3.  Direction: Positive (r =", round(cor_bw_fage$estimate,4),")\n")
cat("Q4.  Form: Linear\n")
cat("Q5.  Degree: r =", round(cor_bw_fage$estimate,4),
    " p =", round(cor_bw_fage$p.value,4), "— weak, not significant\n")

# Q6-Q7: Smoking vs birth weight — Point-Biserial
pb <- cor.test(bw$smoker, bw$Birthweight)
cat("\nQ6.  Test: Point-Biserial (one binary + one continuous variable)\n")
cat("Q7.  r =", round(pb$estimate,4), " p =", round(pb$p.value,4), "\n")
cat("     Moderate negative correlation — significant (p < 0.05)\n")
cat("     Smoking is associated with lower birth weight\n")

# Full correlation table across all continuous pairs
cat("\n--- Correlation matrix (key variables) ---\n")
cor_vars <- bw %>% select(Birthweight, Length, Headcirc, Gestation, mheight, mppwt, fage, fheight)
print(round(cor(cor_vars), 3))

# =============================================================================
# SECTION 2: SCATTERPLOT — LENGTH VS BIRTH WEIGHT (Q8–Q11)
# =============================================================================
cat("\n=== SECTION 2: LENGTH VS BIRTH WEIGHT ===\n")
cat("Q8.  Independent variable: Length of baby\n")
cat("Q10. Linear? Yes — r =", round(cor(bw$Length, bw$Birthweight),4), "\n")
cat("Q11. Strong positive correlation; scatterplot shows clear linear trend\n")

p1 <- ggplot(bw, aes(Length, Birthweight)) +
  geom_point(color="#2ecc71", size=3, alpha=0.8) +
  geom_smooth(method="lm", se=TRUE, color="#27ae60", fill="#2ecc71", alpha=0.15) +
  labs(title="Baby Length vs Birth Weight (Q9)",
       subtitle=paste0("r = ", round(cor(bw$Length, bw$Birthweight),3),
                       "  ·  Independent: Length  ·  Dependent: Birth Weight"),
       x="Baby Length (cm) — Independent Variable",
       y="Birth Weight (kg) — Dependent Variable") + mytheme
ggsave("outputs/plots/09_length_vs_birthweight.png", p1, width=7, height=5, dpi=150)
cat("Saved: 09_length_vs_birthweight.png\n")

# =============================================================================
# SECTION 3: MULTIVARIATE CORRELATION (Q12–Q14)
# =============================================================================
cat("\n=== SECTION 3: BW, LENGTH & HEAD CIRCUMFERENCE ===\n")
cat("Q12. Related? Yes\n")
cm <- round(cor(bw[,c("Birthweight","Length","Headcirc")]),4)
print(cm)
cat("Q13/14. All three are positively correlated (r > 0.56).\n")
cat("        Larger overall fetal size drives all three measures together.\n")

# =============================================================================
# SECTION 4: REGRESSION — BABY LENGTH ~ MOTHER'S HEIGHT (Q15–Q29)
# =============================================================================
cat("\n=== SECTION 4: REGRESSION — BABY LENGTH ~ MOTHER'S HEIGHT ===\n")

lm_mht  <- lm(Length ~ mheight, data=bw)
lm_sum  <- summary(lm_mht)
pred170 <- predict(lm_mht, newdata=data.frame(mheight=170))

cat("Q15. A residual = observed value − predicted value.\n")
cat("     It measures how far each point falls from the regression line.\n")
cat("Q17. R² = variance explained by model.\n")
cat("     Adjusted R² penalises extra predictors — more honest for multiple regression.\n")
cat("Q18. Independence? Yes — each row is a different mother-baby pair.\n\n")
cat("Model: Length =", round(coef(lm_mht)[1],4),
    "+", round(coef(lm_mht)[2],4), "× Mother's Height\n")
cat("Q22. R² =", round(lm_sum$r.squared,4),
    "—", round(lm_sum$r.squared*100,1), "% of variance in baby length explained\n")
cat("Q23. Significant? Yes (p =", round(lm_sum$coefficients[2,4],4),")\n")
cat("Q25. b1 =", round(coef(lm_mht)[2],4), "(the slope)\n")
cat("Q26. Each +1cm in mother's height → +",
    round(coef(lm_mht)[2],4), "cm in baby length\n")
cat("Q27. Cannot extrapolate to 140–145cm: no data in that range.\n")
cat("Q28. Predicted length for mother 170cm:", round(pred170,4), "cm\n")

# Regression diagnostic plots
p2 <- ggplot(bw, aes(mheight, Length)) +
  geom_point(color="#3498db", size=3, alpha=0.8) +
  geom_smooth(method="lm", se=TRUE, color="#2980b9", fill="#3498db", alpha=0.15) +
  annotate("point", x=170, y=pred170, shape=18, size=6, color="#e74c3c") +
  annotate("text", x=171, y=pred170+0.9,
           label=paste0("170cm → ",round(pred170,2),"cm"),
           color="#e74c3c", size=3.8, hjust=0) +
  labs(title="Mother's Height vs Baby Length (Q28)",
       subtitle=paste0("R² = ", round(lm_sum$r.squared,3),
                       "  ·  b₁ = ", round(coef(lm_mht)[2],4),
                       "  ·  p = ", round(lm_sum$coefficients[2,4],4)),
       x="Mother's Height (cm)", y="Baby Length (cm)") + mytheme
ggsave("outputs/plots/10_mheight_regression.png", p2, width=8, height=5, dpi=150)

# Residual plot (Q20-Q21 homoscedasticity)
bw$fitted   <- fitted(lm_mht)
bw$residuals <- residuals(lm_mht)
p3 <- ggplot(bw, aes(fitted, residuals)) +
  geom_point(color="#3498db", size=3, alpha=0.8) +
  geom_hline(yintercept=0, linetype="dashed", color="grey40") +
  geom_smooth(se=FALSE, color="#e74c3c", linewidth=0.8) +
  labs(title="Residual Plot — Baby Length ~ Mother's Height (Q20–Q21)",
       subtitle="Even spread around zero = homoscedasticity satisfied",
       x="Fitted Values", y="Residuals") + mytheme
ggsave("outputs/plots/11_residuals_homoscedasticity.png", p3, width=8, height=5, dpi=150)
cat("Saved plots: 09, 10, 11\n")

# =============================================================================
# SECTION 5: Q30 — FATHER'S AGE VS BABY LENGTH
# =============================================================================
lm_fage <- lm(Length ~ fage, data=bw)
fage_p  <- summary(lm_fage)$coefficients[2,4]
cat("\nQ30. Father's age vs baby length: r =",
    round(cor(bw$fage, bw$Length),4), " p =", round(fage_p,4), "\n")
cat("     NOT significant — father's age cannot reliably predict baby length.\n")

cat("\n=== WEEK 2 EXTENSION COMPLETE ===\n")
