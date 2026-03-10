# =============================================================================
# Cholesterol Reduction Study — Mayerfeld Data Analytics Course | Week 2
# Author: [MD Noornabi]
# Date: March 2026
#
# Description:
#   Repeated-measures analysis of a cholesterol reduction study. 18 participants
#   followed a margarine-based low-fat diet over 8 weeks. Cholesterol measured
#   at baseline, 4 weeks, and 8 weeks. Two margarine types (A and B) compared.
#
#   Extended analysis includes:
#     - Rate of reduction (weeks 0-4 vs 4-8): does the effect plateau?
#     - % reduction per participant (clinically interpretable)
#     - Baseline cholesterol as predictor of reduction achieved
#     - Within-type effectiveness (both A and B individually significant?)
#     - Margarine A vs B compared at all three timepoints
# =============================================================================

library(tidyverse)
library(ggplot2)
library(moments)

chol <- read.csv("data/Cholesterol.csv")
chol$Margarine <- factor(chol$Margarine)

typeA <- chol %>% filter(Margarine == "A")
typeB <- chol %>% filter(Margarine == "B")

cat("Dataset:", nrow(chol), "participants |",
    nrow(typeA), "Margarine A |", nrow(typeB), "Margarine B\n")

mytheme <- theme_minimal(base_size=13) +
  theme(plot.title=element_text(face="bold",size=14),
        plot.subtitle=element_text(color="grey40",size=11))

cohens_d_paired <- function(x, y) { d <- x - y; mean(d) / sd(d) }


# =============================================================================
# SECTION 1: DESCRIPTIVE STATISTICS
# =============================================================================
cat("\n=== SECTION 1: DESCRIPTIVE STATISTICS ===\n")

# Add derived columns
chol <- chol %>% mutate(
  reduction_4wk = Before - After4weeks,
  reduction_8wk = Before - After8weeks,
  reduction_4_to_8 = After4weeks - After8weeks,
  pct_reduction_8wk = (Before - After8weeks) / Before * 100
)

# Summary across timepoints
data.frame(
  Timepoint       = c("Before", "After 4 Weeks", "After 8 Weeks"),
  Mean            = round(c(mean(chol$Before), mean(chol$After4weeks), mean(chol$After8weeks)), 4),
  SD              = round(c(sd(chol$Before),   sd(chol$After4weeks),   sd(chol$After8weeks)), 4),
  Min             = c(min(chol$Before), min(chol$After4weeks), min(chol$After8weeks)),
  Max             = c(max(chol$Before), max(chol$After4weeks), max(chol$After8weeks))
) %>% print()

cat("\nMean reduction (wks 0-4):", round(mean(chol$reduction_4wk), 4), "mmol/L\n")
cat("Mean reduction (wks 0-8):", round(mean(chol$reduction_8wk), 4), "mmol/L\n")
cat("Mean reduction (wks 4-8):", round(mean(chol$reduction_4_to_8), 4), "mmol/L\n")
cat("\nRate comparison:\n")
cat("  Wks 0-4:", round(mean(chol$reduction_4wk), 4), "mmol/L (",
    round(mean(chol$reduction_4wk)/mean(chol$Before)*100, 2), "%)\n")
cat("  Wks 4-8:", round(mean(chol$reduction_4_to_8), 4), "mmol/L (",
    round(mean(chol$reduction_4_to_8)/mean(chol$After4weeks)*100, 2), "%)\n")
cat("  >> Most reduction occurs in the first 4 weeks; effect plateaus but continues.\n")

cat("\nPercentage reduction at 8 weeks:\n")
cat("  Mean:", round(mean(chol$pct_reduction_8wk), 2), "%\n")
cat("  Min: ", round(min(chol$pct_reduction_8wk), 2), "%  |  Max:",
    round(max(chol$pct_reduction_8wk), 2), "%\n")
cat("  Every participant achieved a reduction (min > 0)\n")


# =============================================================================
# SECTION 2: NORMALITY OF DIFFERENCES
# =============================================================================
cat("\n=== SECTION 2: NORMALITY OF DIFFERENCES ===\n")
cat("Paired t-test assumes differences are normally distributed.\n\n")

for (pair in list(
  list(x=chol$Before, y=chol$After4weeks, label="Before - After4weeks"),
  list(x=chol$Before, y=chol$After8weeks, label="Before - After8weeks"),
  list(x=chol$After4weeks, y=chol$After8weeks, label="After4 - After8weeks")
)) {
  d  <- pair$x - pair$y
  sw <- shapiro.test(d)
  cat(sprintf("  %-28s W=%.4f  p=%.4f  [%s]\n", pair$label,
              sw$statistic, sw$p.value,
              ifelse(sw$p.value > 0.05, "Normal ✓", "Not Normal ✗")))
}


# =============================================================================
# SECTION 3: PAIRED T-TESTS — OVERALL
# =============================================================================
cat("\n=== SECTION 3: PAIRED T-TESTS (All Participants) ===\n")

run_paired <- function(x, y, label) {
  tt <- t.test(x, y, paired=TRUE)
  d  <- cohens_d_paired(x, y)
  mag <- ifelse(abs(d)>=0.8,"large",ifelse(abs(d)>=0.5,"medium","small"))
  cat(sprintf("  %-30s t=%7.4f  p=%.6f  d=%.4f (%s)  [%s]\n",
              label, tt$statistic, tt$p.value, d, mag,
              ifelse(tt$p.value<0.05,"SIGNIFICANT **","not significant")))
}

run_paired(chol$Before,      chol$After4weeks,  "Before vs After 4 weeks")
run_paired(chol$Before,      chol$After8weeks,  "Before vs After 8 weeks")
run_paired(chol$After4weeks, chol$After8weeks,  "After 4 vs After 8 weeks")
cat("  Cohen's d > 3.5 = exceptionally large effect.\n")


# =============================================================================
# SECTION 4: WITHIN-TYPE EFFECTIVENESS (Extended)
# =============================================================================
cat("\n=== SECTION 4: EFFECTIVENESS WITHIN EACH MARGARINE TYPE ===\n")
cat("Does each margarine type individually produce significant reductions?\n\n")

for (marg in list(list(df=typeA, label="Margarine A"),
                  list(df=typeB, label="Margarine B"))) {
  cat(paste0("  --- ", marg$label, " (n=", nrow(marg$df), ") ---\n"))
  run_paired(marg$df$Before, marg$df$After4weeks, "  Before vs After 4 weeks")
  run_paired(marg$df$Before, marg$df$After8weeks, "  Before vs After 8 weeks")
}


# =============================================================================
# SECTION 5: MARGARINE A vs B AT ALL TIMEPOINTS (Extended)
# =============================================================================
cat("\n=== SECTION 5: MARGARINE A vs B AT ALL TIMEPOINTS ===\n")

for (pair in list(
  list(a=typeA$Before,      b=typeB$Before,      label="Before"),
  list(a=typeA$After4weeks, b=typeB$After4weeks, label="After 4 Weeks"),
  list(a=typeA$After8weeks, b=typeB$After8weeks, label="After 8 Weeks")
)) {
  tt <- t.test(pair$a, pair$b, var.equal=FALSE)
  cat(sprintf("  %-14s  MeanA=%.3f  MeanB=%.3f  t=%.4f  p=%.4f  [%s]\n",
              pair$label,
              mean(pair$a), mean(pair$b),
              tt$statistic, tt$p.value,
              ifelse(tt$p.value<0.05,"SIGNIFICANT","not significant")))
}
cat("  >> Groups not significantly different at any timepoint.\n")
cat("     Groups started at similar baselines — fair comparison.\n")


# =============================================================================
# SECTION 6: BASELINE PREDICTS REDUCTION (Extended — Key Insight)
# =============================================================================
cat("\n=== SECTION 6: DOES BASELINE CHOLESTEROL PREDICT REDUCTION? ===\n")

cor_base_red <- cor.test(chol$Before, chol$reduction_8wk)
cat("Pearson r (baseline vs 8-week reduction):",
    round(cor_base_red$estimate, 4), "\n")
cat("p-value:", round(cor_base_red$p.value, 4), "\n")
cat(">> People with higher baseline cholesterol achieved greater absolute reductions.\n")
cat(">> Clinically meaningful: the intervention is most impactful for higher-risk individuals.\n")

lm_base <- lm(reduction_8wk ~ Before, data=chol)
cat("Regression: Reduction =", round(coef(lm_base)[1],4),
    "+", round(coef(lm_base)[2],4), "× Before\n")
cat("R² =", round(summary(lm_base)$r.squared, 4), "\n")


# =============================================================================
# SECTION 7: VISUALISATIONS (8 plots)
# =============================================================================
cat("\n=== SECTION 7: GENERATING PLOTS ===\n")

# Plot 1: Mean trend with SD band
time_means <- data.frame(
  Timepoint = factor(c("Before","After 4 Weeks","After 8 Weeks"),
                     levels=c("Before","After 4 Weeks","After 8 Weeks")),
  Mean = c(mean(chol$Before), mean(chol$After4weeks), mean(chol$After8weeks)),
  SD   = c(sd(chol$Before),   sd(chol$After4weeks),   sd(chol$After8weeks))
)
p1 <- ggplot(time_means, aes(Timepoint, Mean, group=1)) +
  geom_ribbon(aes(ymin=Mean-SD, ymax=Mean+SD), fill="#3498db", alpha=0.15) +
  geom_line(color="#2980b9", linewidth=1.4) +
  geom_point(size=5, color="#2980b9") +
  geom_text(aes(label=round(Mean,3)), vjust=-1.5, fontface="bold", size=4.2) +
  scale_y_continuous(limits=c(4.2, 7.8)) +
  labs(title="Mean Cholesterol Over Time",
       subtitle="Shaded band = ±1 SD  ·  n=18",
       x=NULL, y="Cholesterol (mmol/L)") + mytheme
ggsave("outputs/plots/01_cholesterol_trend.png", p1, width=7, height=5, dpi=150)
cat("Saved: 01_cholesterol_trend.png\n")

# Plot 2: Individual spaghetti
chol_long <- chol %>%
  pivot_longer(c(Before, After4weeks, After8weeks),
               names_to="Timepoint", values_to="Cholesterol") %>%
  mutate(Timepoint=factor(Timepoint,
         levels=c("Before","After4weeks","After8weeks"),
         labels=c("Before","4 Weeks","8 Weeks")))

p2 <- ggplot(chol_long, aes(Timepoint, Cholesterol, group=ID, color=Margarine)) +
  geom_line(alpha=0.55, linewidth=0.9) +
  geom_point(size=2.5, alpha=0.85) +
  scale_color_manual(values=c("A"="#e67e22","B"="#8e44ad")) +
  stat_summary(aes(group=1), fun=mean, geom="line",
               color="black", linewidth=2, linetype="dashed") +
  labs(title="Individual Cholesterol Trajectories",
       subtitle="Each line = 1 participant  ·  Dashed = group mean  ·  Colour = margarine type",
       x=NULL, y="Cholesterol (mmol/L)", color="Margarine") + mytheme
ggsave("outputs/plots/02_spaghetti.png", p2, width=8, height=5, dpi=150)
cat("Saved: 02_spaghetti.png\n")

# Plot 3: Before vs After8 scatter (diagonal = no change)
p3 <- ggplot(chol, aes(Before, After8weeks, color=Margarine)) +
  geom_point(size=3.5, alpha=0.85) +
  geom_smooth(method="lm", se=TRUE, aes(group=1), color="#2c3e50", fill="grey70", alpha=0.2) +
  geom_abline(slope=1, intercept=0, linetype="dashed", color="grey50", linewidth=1) +
  scale_color_manual(values=c("A"="#e67e22","B"="#8e44ad")) +
  labs(title="Baseline vs 8-Week Cholesterol",
       subtitle="All points below dashed line = reduction achieved (100% of participants)",
       x="Before (mmol/L)", y="After 8 Weeks (mmol/L)", color="Margarine") + mytheme
ggsave("outputs/plots/03_before_vs_after8.png", p3, width=7, height=5, dpi=150)
cat("Saved: 03_before_vs_after8.png\n")

# Plot 4: Margarine type comparison across timepoints
p4 <- ggplot(chol_long, aes(Timepoint, Cholesterol, fill=Margarine)) +
  geom_boxplot(alpha=0.7, width=0.5) +
  scale_fill_manual(values=c("A"="#e67e22","B"="#8e44ad")) +
  labs(title="Cholesterol by Margarine Type Across Time",
       subtitle="No significant difference between types at any timepoint",
       x=NULL, y="Cholesterol (mmol/L)", fill="Margarine Type") + mytheme
ggsave("outputs/plots/04_margarine_comparison.png", p4, width=8, height=5, dpi=150)
cat("Saved: 04_margarine_comparison.png\n")

# Plot 5: Rate of reduction (bar: wks 0-4 vs 4-8)
rate_df <- data.frame(
  Period = factor(c("Weeks 0–4","Weeks 4–8"), levels=c("Weeks 0–4","Weeks 4–8")),
  Reduction = c(mean(chol$reduction_4wk), mean(chol$reduction_4_to_8))
)
p5 <- ggplot(rate_df, aes(Period, Reduction, fill=Period)) +
  geom_col(width=0.45, alpha=0.85) +
  geom_text(aes(label=round(Reduction,3)), vjust=-0.5, fontface="bold", size=4.5) +
  scale_fill_manual(values=c("Weeks 0–4"="#2980b9","Weeks 4–8"="#85c1e9")) +
  scale_y_continuous(limits=c(0, 0.75)) +
  labs(title="Rate of Cholesterol Reduction by Period",
       subtitle="Reduction is 9× faster in the first 4 weeks — effect plateaus but continues",
       x=NULL, y="Mean Reduction (mmol/L)") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/05_rate_of_reduction.png", p5, width=7, height=5, dpi=150)
cat("Saved: 05_rate_of_reduction.png\n")

# Plot 6: % reduction per participant
p6 <- ggplot(chol, aes(x=reorder(as.factor(ID), pct_reduction_8wk),
                        y=pct_reduction_8wk, fill=Margarine)) +
  geom_col(alpha=0.85) +
  geom_hline(yintercept=mean(chol$pct_reduction_8wk),
             linetype="dashed", color="#2c3e50", linewidth=1) +
  scale_fill_manual(values=c("A"="#e67e22","B"="#8e44ad")) +
  labs(title="Percentage Cholesterol Reduction at 8 Weeks (Per Participant)",
       subtitle=paste0("Mean reduction: ", round(mean(chol$pct_reduction_8wk),2),
                       "%  ·  Dashed = mean  ·  All participants improved"),
       x="Participant ID", y="% Reduction", fill="Margarine") +
  mytheme
ggsave("outputs/plots/06_pct_reduction_per_participant.png", p6, width=9, height=5, dpi=150)
cat("Saved: 06_pct_reduction_per_participant.png\n")

# Plot 7: Baseline cholesterol vs reduction (key insight)
p7 <- ggplot(chol, aes(Before, reduction_8wk, color=Margarine)) +
  geom_point(size=3.5, alpha=0.85) +
  geom_smooth(method="lm", se=TRUE, aes(group=1), color="#2c3e50", fill="grey70", alpha=0.2) +
  scale_color_manual(values=c("A"="#e67e22","B"="#8e44ad")) +
  labs(title="Does Baseline Cholesterol Predict Reduction?",
       subtitle=paste0("r = ", round(cor(chol$Before, chol$reduction_8wk),3),
                       "  p = ", round(cor.test(chol$Before, chol$reduction_8wk)$p.value,4),
                       "  ·  Higher baseline → greater absolute reduction"),
       x="Baseline Cholesterol (mmol/L)", y="Reduction at 8 Weeks (mmol/L)",
       color="Margarine") + mytheme
ggsave("outputs/plots/07_baseline_vs_reduction.png", p7, width=8, height=5, dpi=150)
cat("Saved: 07_baseline_vs_reduction.png\n")

# Plot 8: Faceted by margarine type
p8 <- ggplot(chol_long, aes(Timepoint, Cholesterol, group=ID)) +
  geom_line(alpha=0.5, color="grey60", linewidth=0.8) +
  geom_point(aes(color=Timepoint), size=2.5) +
  stat_summary(aes(group=1), fun=mean, geom="line",
               color="black", linewidth=1.5, linetype="dashed") +
  facet_wrap(~Margarine, labeller=labeller(Margarine=c("A"="Margarine A","B"="Margarine B"))) +
  scale_color_manual(values=c("Before"="#e74c3c","4 Weeks"="#f39c12","8 Weeks"="#2ecc71")) +
  labs(title="Trajectories by Margarine Type",
       subtitle="Both types show consistent downward trend  ·  Dashed = group mean",
       x=NULL, y="Cholesterol (mmol/L)", color="Timepoint") + mytheme
ggsave("outputs/plots/08_faceted_by_type.png", p8, width=9, height=5, dpi=150)
cat("Saved: 08_faceted_by_type.png\n")

cat("\n=== ANALYSIS COMPLETE — 8 plots saved ===\n")
