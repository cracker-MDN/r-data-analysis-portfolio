# =============================================================================
# Birthweight Analysis - Mayerfeld Data Analytics Course | Week 1
# Author: [MD Noornabi]
# Date: March 2026
#
# Description:
#   Full exploratory data analysis of the Birthweight dataset investigating
#   the effect of maternal smoking on infant outcomes. Goes beyond the core
#   homework questions to include:
#     - Independent samples t-tests (are group differences significant?)
#     - Dose-response analysis (cigarettes/day vs birth weight)
#     - Correlation analysis across continuous variables
#     - Low birth weight risk by smoking status
#     - Cohen's d effect size for practical significance
# =============================================================================


# -----------------------------------------------------------------------------
# 0. SETUP & DATA LOADING
# -----------------------------------------------------------------------------
# install.packages(c("tidyverse", "ggplot2", "moments", "gridExtra"))

library(tidyverse)
library(ggplot2)
library(moments)       # skewness, kurtosis
library(gridExtra)     # multi-plot layouts

bw <- read.csv("data/Birthweight.csv")

bw$smoker_label <- factor(bw$smoker,  levels = c(0, 1), labels = c("Non-Smoker", "Smoker"))
bw$lowbwt_label <- factor(bw$lowbwt,  levels = c(0, 1), labels = c("Normal Weight", "Low Birth Weight"))
bw$mage35_label <- factor(bw$mage35,  levels = c(0, 1), labels = c("Under 35", "35 or Over"))

non_smokers <- bw %>% filter(smoker == 0)
smokers     <- bw %>% filter(smoker == 1)

cat("Dataset loaded:", nrow(bw), "babies |",
    nrow(non_smokers), "non-smoking |", nrow(smokers), "smoking mothers\n")


# =============================================================================
# SECTION 1: DESCRIPTIVE STATISTICS  (Homework Q1-Q10)
# =============================================================================
cat("\n=== SECTION 1: DESCRIPTIVE STATISTICS ===\n")

q1 <- mean(non_smokers$Birthweight)
q2 <- mean(smokers$Birthweight)
q3 <- mean(non_smokers$Headcirc)
q4 <- mean(smokers$Gestation)
q5 <- max(non_smokers$Headcirc)
q6 <- min(smokers$Gestation)
q7_ns <- mean(non_smokers$Gestation)
q7_s  <- mean(smokers$Gestation)
q9    <- max(smokers$Birthweight) - min(smokers$Birthweight)

cat("Q1.  Mean birth weight (non-smokers):       ", round(q1, 4), "kg\n")
cat("Q2.  Mean birth weight (smokers):           ", round(q2, 4), "kg\n")
cat("     Difference:                            ", round(q1 - q2, 4), "kg\n")
cat("Q3.  Mean head circumference (non-smokers): ", round(q3, 4), "cm\n")
cat("Q4.  Mean gestational age (smokers):        ", round(q4, 4), "weeks\n")
cat("Q5.  Max head circumference (non-smokers):  ", q5, "cm\n")
cat("Q6.  Min gestational age (smokers):         ", q6, "weeks\n")
cat("Q7.  Non-smokers:", round(q7_ns, 4), "wks vs smokers:", round(q7_s, 4), "wks -> smokers shorter\n")
cat("Q9.  Birth weight range (smokers):          ", round(q9, 4), "kg\n")
cat("Q10. Wide range reflects variable impact of smoking across pregnancies.\n")

# Extended group summary
summary_tbl <- bw %>%
  group_by(smoker_label) %>%
  summarise(
    n              = n(),
    mean_bw        = round(mean(Birthweight), 3),
    sd_bw          = round(sd(Birthweight), 3),
    median_bw      = round(median(Birthweight), 3),
    mean_headcirc  = round(mean(Headcirc), 3),
    mean_length    = round(mean(Length), 3),
    mean_gestation = round(mean(Gestation), 3),
    pct_low_bwt    = round(mean(lowbwt) * 100, 1)
  )
cat("\n--- Group Summary Table ---\n")
print(summary_tbl)


# =============================================================================
# SECTION 2: NORMALITY TESTING  (Homework Q11-Q16, Q19-Q20)
# =============================================================================
cat("\n=== SECTION 2: NORMALITY TESTING ===\n")

run_normality <- function(x, label) {
  sw <- shapiro.test(x)
  sk <- skewness(x)
  kt <- kurtosis(x)
  cat(sprintf("  %-42s W=%.4f  p=%.4f  skew=%+.3f  kurt=%.3f  [%s]\n",
              label, sw$statistic, sw$p.value, sk, kt,
              ifelse(sw$p.value > 0.05, "NORMAL", "NOT NORMAL")))
  invisible(sw$p.value)
}

run_normality(smokers$Headcirc,       "Q11/12  Head circumference - smokers")
run_normality(non_smokers$Birthweight,"Q14     Birth weight - non-smokers")
run_normality(smokers$Birthweight,    "Q15/16  Birth weight - smokers")
run_normality(non_smokers$Length,     "Q19/20  Baby length - non-smokers")
cat("\n  Q14: Positive skewness -> right-skewed distribution\n")


# =============================================================================
# SECTION 3: Z-SCORES & PROBABILITY  (Homework Q13, Q17-Q18, Q21-Q22)
# =============================================================================
cat("\n=== SECTION 3: Z-SCORES & PROBABILITY ===\n")

mean_hc_ns  <- mean(non_smokers$Headcirc);   sd_hc_ns  <- sd(non_smokers$Headcirc)
mean_bw_s   <- mean(smokers$Birthweight);    sd_bw_s   <- sd(smokers$Birthweight)
mean_len_ns <- mean(non_smokers$Length);     sd_len_ns <- sd(non_smokers$Length)
mean_bw_all <- mean(bw$Birthweight);         sd_bw_all <- sd(bw$Birthweight)

z13 <- (35.05 - mean_hc_ns) / sd_hc_ns
z18 <- (4.2   - mean_bw_s)  / sd_bw_s
z21 <- (48.5  - mean_len_ns)/ sd_len_ns
z22 <- (55    - mean_len_ns)/ sd_len_ns

cat("Q13. Z (HC=35.05, non-smokers):        Z =", round(z13, 4), "[35.05 = mean, so Z=0]\n")
cat("Q17. +/- 1 SD range (all):            [", round(mean_bw_all - sd_bw_all, 3),
    ",", round(mean_bw_all + sd_bw_all, 3), "] -> ~68% confidence\n")
cat("Q18. P(BW < 4.2 | smokers):            Z =", round(z18, 4),
    "-> p =", round(pnorm(z18), 4), "(", round(pnorm(z18)*100, 2), "%)\n")
cat("Q21. Z (length=48.5, non-smokers):     Z =", round(z21, 4), "\n")
cat("Q22. P(length > 55 | non-smokers):     Z =", round(z22, 4),
    "-> p =", round(1-pnorm(z22), 4), "(", round((1-pnorm(z22))*100, 2), "%)\n")


# =============================================================================
# SECTION 4: EXTENDED INFERENTIAL ANALYSIS
# =============================================================================
cat("\n=== SECTION 4: EXTENDED ANALYSIS ===\n")

# --- 4A. Welch's t-tests + Cohen's d ---
cat("\n--- 4A. Independent Samples t-tests (Welch) + Effect Size ---\n")
cohens_d <- function(x, y) (mean(x) - mean(y)) / sqrt((sd(x)^2 + sd(y)^2) / 2)

run_ttest <- function(v_ns, v_s, label) {
  tt <- t.test(v_ns, v_s, var.equal = FALSE)
  d  <- cohens_d(v_ns, v_s)
  mag <- ifelse(abs(d) >= 0.8, "large", ifelse(abs(d) >= 0.5, "medium", "small"))
  sig <- ifelse(tt$p.value < 0.05, "**", "ns")
  cat(sprintf("  %-28s t=%6.3f  p=%.4f %s  d=%+.3f (%s)\n",
              label, tt$statistic, tt$p.value, sig, d, mag))
}

run_ttest(non_smokers$Birthweight, smokers$Birthweight, "Birth weight")
run_ttest(non_smokers$Headcirc,    smokers$Headcirc,    "Head circumference")
run_ttest(non_smokers$Gestation,   smokers$Gestation,   "Gestational age")
run_ttest(non_smokers$Length,      smokers$Length,      "Baby length")
cat("  ** p<0.05 | ns = not significant | Cohen's d: small=0.2, medium=0.5, large=0.8\n")

# --- 4B. Dose-response: cigarettes vs birth weight ---
cat("\n--- 4B. Dose-Response: Cigarettes Per Day vs Birth Weight ---\n")
lm_dose <- lm(Birthweight ~ mnocig, data = smokers)
r_dose  <- cor(smokers$mnocig, smokers$Birthweight)
cat("  Pearson r:", round(r_dose, 4), "\n")
cat("  OLS: Birth weight =", round(coef(lm_dose)[1], 4),
    "+", round(coef(lm_dose)[2], 4), "* cigarettes/day\n")
cat("  Each additional cigarette/day is associated with",
    round(coef(lm_dose)[2]*1000, 1), "g change in birth weight\n")
cat("  R-squared:", round(summary(lm_dose)$r.squared, 4), "\n")

# --- 4C. Low birth weight risk ---
cat("\n--- 4C. Low Birth Weight Incidence ---\n")
lowbwt_tbl <- bw %>% group_by(smoker_label) %>%
  summarise(n=n(), n_lowbwt=sum(lowbwt), pct=round(mean(lowbwt)*100,1))
print(lowbwt_tbl)
chi_res <- chisq.test(table(bw$smoker, bw$lowbwt), correct = FALSE)
cat("  Chi-sq:", round(chi_res$statistic, 4), " p:", round(chi_res$p.value, 4),
    ifelse(chi_res$p.value < 0.05, " [SIGNIFICANT]", " [not significant]"), "\n")

# --- 4D. Correlation matrix ---
cat("\n--- 4D. Correlation Matrix (Key Variables) ---\n")
cor_vars <- bw %>% select(Birthweight, Length, Headcirc, Gestation, mnocig, mheight, mppwt, fheight)
print(round(cor(cor_vars, use="complete.obs"), 3))


# =============================================================================
# SECTION 5: VISUALISATIONS (8 plots)
# =============================================================================
cat("\n=== SECTION 5: GENERATING PLOTS ===\n")

mytheme <- theme_minimal(base_size = 13) +
  theme(plot.title    = element_text(face = "bold", size = 14),
        plot.subtitle = element_text(size = 11, color = "grey40"))

NS_COL <- "#2ecc71"; S_COL <- "#e74c3c"

# Plot 1: Boxplot + jitter
p1 <- ggplot(bw, aes(smoker_label, Birthweight, fill = smoker_label)) +
  geom_boxplot(alpha=.7, outlier.shape=NA, width=.5) +
  geom_jitter(width=.15, alpha=.65, size=2.5) +
  stat_summary(fun=mean, geom="point", shape=18, size=4, color="black") +
  scale_fill_manual(values=c("Non-Smoker"=NS_COL,"Smoker"=S_COL)) +
  labs(title="Birth Weight by Maternal Smoking Status",
       subtitle="Boxes = IQR · dots = individual babies · diamond = mean",
       x=NULL, y="Birth Weight (kg)") + mytheme + theme(legend.position="none")
ggsave("outputs/plots/01_birthweight_by_smoker.png", p1, width=7, height=5, dpi=150)

# Plot 2: Distribution density
means_df <- bw %>% group_by(smoker_label) %>% summarise(m = mean(Birthweight))
p2 <- ggplot(bw, aes(Birthweight, fill=smoker_label, color=smoker_label)) +
  geom_histogram(aes(y=after_stat(density)), bins=11, alpha=.4, position="identity") +
  geom_density(linewidth=1.2, alpha=0) +
  geom_vline(data=means_df, aes(xintercept=m, color=smoker_label), linetype="dashed", linewidth=1) +
  scale_fill_manual(values=c("Non-Smoker"=NS_COL,"Smoker"=S_COL)) +
  scale_color_manual(values=c("Non-Smoker"="#27ae60","Smoker"="#c0392b")) +
  labs(title="Birth Weight Distribution by Smoking Status",
       subtitle="Dashed lines = group means", x="Birth Weight (kg)", y="Density", fill=NULL, color=NULL) +
  mytheme
ggsave("outputs/plots/02_birthweight_distribution.png", p2, width=8, height=5, dpi=150)

# Plot 3: QQ plots
png("outputs/plots/03_qqplots_normality.png", width=1000, height=450, res=130)
par(mfrow=c(1,2), mar=c(4,4,3.5,1))
qqnorm(non_smokers$Birthweight, main="Q-Q: Birth Weight\n(Non-Smoking Mothers)",
       col=NS_COL, pch=16, cex=1.2); qqline(non_smokers$Birthweight, col="#27ae60", lwd=2)
qqnorm(smokers$Birthweight, main="Q-Q: Birth Weight\n(Smoking Mothers)",
       col=S_COL, pch=16, cex=1.2); qqline(smokers$Birthweight, col="#c0392b", lwd=2)
dev.off()

# Plot 4: Head circ vs birth weight scatter
p4 <- ggplot(bw, aes(Headcirc, Birthweight, color=smoker_label)) +
  geom_point(size=3, alpha=.8) +
  geom_smooth(method="lm", se=TRUE, alpha=.12, linewidth=1) +
  scale_color_manual(values=c("Non-Smoker"=NS_COL,"Smoker"=S_COL)) +
  labs(title="Head Circumference vs Birth Weight",
       subtitle="Linear trend per group with 95% CI",
       x="Head Circumference (cm)", y="Birth Weight (kg)", color=NULL) + mytheme
ggsave("outputs/plots/04_headcirc_vs_birthweight.png", p4, width=8, height=5, dpi=150)

# Plot 5: Gestation violin
p5 <- ggplot(bw, aes(smoker_label, Gestation, fill=smoker_label)) +
  geom_violin(alpha=.55, trim=FALSE) +
  geom_boxplot(width=.1, fill="white", alpha=.85, outlier.size=2) +
  scale_fill_manual(values=c("Non-Smoker"="#3498db","Smoker"=S_COL)) +
  labs(title="Gestational Age by Maternal Smoking Status", x=NULL, y="Gestation (weeks)") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/05_gestation_by_smoker.png", p5, width=7, height=5, dpi=150)

# Plot 6: Dose-response
p6 <- ggplot(smokers, aes(mnocig, Birthweight)) +
  geom_point(color=S_COL, size=3, alpha=.8) +
  geom_smooth(method="lm", se=TRUE, color="#c0392b", fill=S_COL, alpha=.15) +
  labs(title="Dose-Response: Cigarettes Per Day vs Birth Weight",
       subtitle="Smoking mothers only · OLS with 95% CI",
       x="Cigarettes Smoked Per Day (Mother)", y="Birth Weight (kg)") + mytheme
ggsave("outputs/plots/06_dose_response_cigarettes.png", p6, width=8, height=5, dpi=150)

# Plot 7: Low birth weight incidence
lowbwt_plot <- bw %>% group_by(smoker_label) %>%
  summarise(pct=mean(lowbwt)*100, n=n())
p7 <- ggplot(lowbwt_plot, aes(smoker_label, pct, fill=smoker_label)) +
  geom_col(width=.5, alpha=.85) +
  geom_text(aes(label=paste0(round(pct,1),"% (n=",n,")")), vjust=-0.5, size=4.5, fontface="bold") +
  scale_fill_manual(values=c("Non-Smoker"=NS_COL,"Smoker"=S_COL)) +
  scale_y_continuous(limits=c(0,60), labels=function(x) paste0(x,"%")) +
  labs(title="Low Birth Weight Incidence by Smoking Status",
       x=NULL, y="% Low Birth Weight") + mytheme + theme(legend.position="none")
ggsave("outputs/plots/07_lowbwt_risk.png", p7, width=7, height=5, dpi=150)

# Plot 8: All outcomes faceted
bw_long <- bw %>%
  select(smoker_label, Birthweight, Headcirc, Length, Gestation) %>%
  pivot_longer(-smoker_label, names_to="Outcome", values_to="Value") %>%
  mutate(Outcome=recode(Outcome,
    "Birthweight"="Birth Weight (kg)", "Headcirc"="Head Circumference (cm)",
    "Length"="Baby Length (cm)", "Gestation"="Gestational Age (wks)"))
p8 <- ggplot(bw_long, aes(smoker_label, Value, fill=smoker_label)) +
  geom_boxplot(alpha=.7, outlier.size=1.5) +
  facet_wrap(~Outcome, scales="free_y", ncol=2) +
  scale_fill_manual(values=c("Non-Smoker"=NS_COL,"Smoker"=S_COL)) +
  labs(title="All Infant Outcomes by Maternal Smoking Status",
       subtitle="Faceted across four key measures", x=NULL, y=NULL, fill=NULL) +
  mytheme + theme(strip.text=element_text(face="bold"), legend.position="bottom")
ggsave("outputs/plots/08_all_outcomes_faceted.png", p8, width=9, height=7, dpi=150)

cat("All 8 plots saved to outputs/plots/\n")
cat("Run birthweight_report.Rmd for the full HTML report.\n")
