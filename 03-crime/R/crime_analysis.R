# =============================================================================
# US State Crime Rate Analysis — Mayerfeld Data Analytics Course | Week 3
# Author: [MD Noornabi]
# Date: March 2026
#
# Dataset: 47 US states, 27 variables across two timepoints (Year 0 & Year 10)
# Central question: What socioeconomic factors predict crime rates across
# US states — and how persistent are those patterns over a decade?
#
# Analysis structure:
#   Section 1 — Exploratory Data Analysis & Data Quality
#   Section 2 — Correlation Analysis: What predicts crime?
#   Section 3 — The Three Paradoxes (counterintuitive findings)
#   Section 4 — Group Comparisons (Southern states, youth unemployment)
#   Section 5 — Multiple Linear Regression
#   Section 6 — Longitudinal Analysis (10-year persistence)
# =============================================================================

# install.packages(c("tidyverse","ggplot2","ggcorrplot","gridExtra","reshape2","scales"))

library(tidyverse)
library(ggplot2)
library(ggcorrplot)
library(gridExtra)
library(reshape2)
library(scales)

crime <- read.csv("data/Crime.csv")
crime$Southern       <- factor(crime$Southern,       levels=c(0,1), labels=c("Non-Southern","Southern"))
crime$MoreMales      <- factor(crime$MoreMales,       levels=c(0,1), labels=c("No","Yes"))
crime$HighYouthUnemploy <- factor(crime$HighYouthUnemploy, levels=c(0,1), labels=c("Low","High"))

cat("=== DATASET OVERVIEW ===\n")
cat("States:", nrow(crime), "\n")
cat("Variables:", ncol(crime), "\n")
cat("Southern states:", sum(crime$Southern=="Southern"), "\n")
cat("Non-Southern states:", sum(crime$Southern=="Non-Southern"), "\n")

mytheme <- theme_minimal(base_size=13) +
  theme(
    plot.title    = element_text(face="bold", size=14, color="#1F4E79"),
    plot.subtitle = element_text(color="grey40", size=11),
    plot.caption  = element_text(color="grey55", size=9, face="italic"),
    panel.grid.minor = element_blank()
  )

cohens_d <- function(x, y) {
  (mean(x) - mean(y)) / sqrt((sd(x)^2 + sd(y)^2) / 2)
}

# =============================================================================
# SECTION 1: EXPLORATORY DATA ANALYSIS & DATA QUALITY
# =============================================================================
cat("\n=== SECTION 1: EXPLORATORY DATA ANALYSIS ===\n")

cat("\nCrime Rate (Year 0):\n")
cat("  Mean:   ", round(mean(crime$CrimeRate), 2), "\n")
cat("  Median: ", round(median(crime$CrimeRate), 2), "\n")
cat("  SD:     ", round(sd(crime$CrimeRate), 2), "\n")
cat("  Min:    ", min(crime$CrimeRate), "\n")
cat("  Max:    ", max(crime$CrimeRate), "\n")

cat("\nCrime Rate (Year 10):\n")
cat("  Mean:   ", round(mean(crime$CrimeRate10), 2), "\n")
cat("  Median: ", round(median(crime$CrimeRate10), 2), "\n")
cat("  SD:     ", round(sd(crime$CrimeRate10), 2), "\n")

# Skewness check on flagged variables
library(moments)
cat("\nSkewness check (flagged variables):\n")
cat("  ExpenditureYear0:      ", round(skewness(crime$ExpenditureYear0), 4), "\n")
cat("  Log(ExpenditureYear0): ", round(skewness(log(crime$ExpenditureYear0)), 4), "\n")
cat("  YouthUnemployment:     ", round(skewness(crime$YouthUnemployment), 4), "\n")
cat("  Log(YouthUnemploy):    ", round(skewness(log(crime$YouthUnemployment)), 4), "\n")

# Add log-transformed variables
crime$LogExpenditure <- log(crime$ExpenditureYear0)
crime$LogExpenditure10 <- log(crime$ExpenditureYear10)
crime$CrimeChange <- crime$CrimeRate10 - crime$CrimeRate

# Plot 1: Crime rate distributions — both timepoints overlaid
cr_long <- data.frame(
  CrimeRate = c(crime$CrimeRate, crime$CrimeRate10),
  Timepoint = rep(c("Year 0","Year 10"), each=nrow(crime))
)
p1 <- ggplot(cr_long, aes(CrimeRate, fill=Timepoint, color=Timepoint)) +
  geom_histogram(aes(y=after_stat(density)), bins=15, alpha=0.45, position="identity") +
  geom_density(linewidth=1.1, alpha=0) +
  geom_vline(xintercept=mean(crime$CrimeRate),   linetype="dashed", color="#2980b9", linewidth=0.9) +
  geom_vline(xintercept=mean(crime$CrimeRate10), linetype="dashed", color="#e67e22", linewidth=0.9) +
  scale_fill_manual(values=c("Year 0"="#2980b9","Year 10"="#e67e22")) +
  scale_color_manual(values=c("Year 0"="#2980b9","Year 10"="#e67e22")) +
  labs(title="US State Crime Rate Distribution — Year 0 vs Year 10",
       subtitle=paste0("Year 0: Mean=",round(mean(crime$CrimeRate),1),
                       "  |  Year 10: Mean=",round(mean(crime$CrimeRate10),1),
                       "  |  n=47 states"),
       x="Crime Rate (offences per million)", y="Density",
       caption="Dashed lines = group means",
       fill="Timepoint", color="Timepoint") + mytheme
ggsave("outputs/plots/01_crimerate_distribution.png", p1, width=9, height=5, dpi=150)
cat("Saved: 01_crimerate_distribution.png\n")

# Plot 2: Log transformation comparison
exp_df <- data.frame(
  Value = c(crime$ExpenditureYear0, log(crime$ExpenditureYear0)),
  Type  = rep(c("Original (skewness=0.92)","Log-transformed (skewness=0.28)"), each=nrow(crime))
)
p2 <- ggplot(exp_df, aes(Value, fill=Type)) +
  geom_histogram(bins=15, alpha=0.8, color="white") +
  facet_wrap(~Type, scales="free_x") +
  scale_fill_manual(values=c("#e74c3c","#27ae60")) +
  labs(title="Police Expenditure: Correcting Positive Skew with Log Transformation",
       subtitle="Log transformation reduces skewness from 0.92 to 0.28 — closer to normal distribution",
       x="Value", y="Count") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/02_log_transformation.png", p2, width=10, height=5, dpi=150)
cat("Saved: 02_log_transformation.png\n")


# =============================================================================
# SECTION 2: CORRELATION ANALYSIS
# =============================================================================
cat("\n=== SECTION 2: CORRELATION ANALYSIS ===\n")

cont_vars <- c("CrimeRate","Youth","Education","ExpenditureYear0","LabourForce",
               "Males","StateSize","YouthUnemployment","MatureUnemployment",
               "Wage","BelowWage")

cat("Correlations with CrimeRate:\n")
for (v in cont_vars[-1]) {
  r_val <- cor(crime[[v]], crime$CrimeRate)
  p_val <- cor.test(crime[[v]], crime$CrimeRate)$p.value
  sig   <- ifelse(p_val < 0.05, " **", "")
  cat(sprintf("  %-25s r=%+.4f  p=%.4f%s\n", v, r_val, p_val, sig))
}

# Plot 3: Full correlation heatmap
cor_data <- crime %>% select(all_of(cont_vars))
cor_matrix <- cor(cor_data, use="complete.obs")
p3 <- ggcorrplot(cor_matrix,
                 hc.order=TRUE,
                 type="lower",
                 lab=TRUE,
                 lab_size=3,
                 colors=c("#c0392b","white","#1a7abf"),
                 outline.color="white",
                 title="Correlation Matrix — All Continuous Variables") +
  labs(subtitle="Hierarchical clustering reveals variable groupings  ·  n=47 states") +
  mytheme +
  theme(axis.text.x=element_text(angle=45, hjust=1))
ggsave("outputs/plots/03_correlation_heatmap.png", p3, width=10, height=9, dpi=150)
cat("Saved: 03_correlation_heatmap.png\n")

# Plot 4: Top 3 predictors — faceted scatter
top3 <- crime %>%
  select(CrimeRate, ExpenditureYear0, Wage, StateSize, Southern) %>%
  pivot_longer(c(ExpenditureYear0, Wage, StateSize),
               names_to="Predictor", values_to="Value") %>%
  mutate(Predictor = recode(Predictor,
    "ExpenditureYear0" = "Police Expenditure (r=+0.65**)",
    "Wage"             = "Median Wage (r=+0.42**)",
    "StateSize"        = "State Size (r=+0.31*)"
  ))

p4 <- ggplot(top3, aes(Value, CrimeRate, color=Southern)) +
  geom_point(size=2.8, alpha=0.8) +
  geom_smooth(method="lm", se=TRUE, aes(group=1),
              color="#2c3e50", fill="grey70", alpha=0.2, linewidth=1) +
  facet_wrap(~Predictor, scales="free_x") +
  scale_color_manual(values=c("Non-Southern"="#2980b9","Southern"="#e67e22")) +
  labs(title="Top Three Predictors of Crime Rate",
       subtitle="Each shows a significant positive relationship with crime  ·  Colour = Southern state",
       x=NULL, y="Crime Rate (offences per million)",
       color="Region") + mytheme
ggsave("outputs/plots/04_top_predictors_scatter.png", p4, width=12, height=5, dpi=150)
cat("Saved: 04_top_predictors_scatter.png\n")


# =============================================================================
# SECTION 3: THE THREE PARADOXES
# =============================================================================
cat("\n=== SECTION 3: THE THREE PARADOXES ===\n")

# Paradox 1: Expenditure — reverse causation test
r_exp_cr0  <- cor.test(crime$ExpenditureYear0, crime$CrimeRate)
r_exp_cr10 <- cor.test(crime$ExpenditureYear0, crime$CrimeRate10)
cat("PARADOX 1 — Police Expenditure:\n")
cat(sprintf("  Exp(t0) vs Crime(t0):  r=%+.4f  p=%.4f\n",
            r_exp_cr0$estimate, r_exp_cr0$p.value))
cat(sprintf("  Exp(t0) vs Crime(t10): r=%+.4f  p=%.4f\n",
            r_exp_cr10$estimate, r_exp_cr10$p.value))
cat("  >> If pure reverse causation: t0 spending predicting t10 crime should weaken.\n")
cat("  >> It doesn't — suggesting a structural, bidirectional relationship.\n")

# Plot 5: Expenditure paradox — t0 predicts t10
p5 <- ggplot(crime, aes(ExpenditureYear0, CrimeRate10, color=Southern)) +
  geom_point(size=3, alpha=0.85) +
  geom_smooth(method="lm", se=TRUE, aes(group=1),
              color="#2c3e50", fill="grey70", alpha=0.2, linewidth=1.1) +
  scale_color_manual(values=c("Non-Southern"="#2980b9","Southern"="#e74c3c")) +
  labs(title="The Expenditure Paradox: Does Spending Cause Crime or Respond to It?",
       subtitle=paste0("Police expenditure at Year 0 predicts crime at Year 10 (r=",
                       round(r_exp_cr10$estimate,3),", p<0.001)\n",
                       "If pure reverse causation, this forward-looking prediction should weaken — it doesn't"),
       x="Police Expenditure per Capita — Year 0",
       y="Crime Rate — Year 10",
       caption="Structural relationship: high-crime states invest more in policing, which itself becomes embedded in state infrastructure",
       color="Region") + mytheme
ggsave("outputs/plots/05_expenditure_paradox.png", p5, width=9, height=6, dpi=150)
cat("Saved: 05_expenditure_paradox.png\n")

# Paradox 2: Wage–BelowWage–Crime triangle
cat("\nPARADOX 2 — Wage triangle:\n")
cat(sprintf("  Wage vs CrimeRate:      r=%+.4f  p=%.4f\n",
            cor(crime$Wage, crime$CrimeRate),
            cor.test(crime$Wage, crime$CrimeRate)$p.value))
cat(sprintf("  BelowWage vs CrimeRate: r=%+.4f  p=%.4f\n",
            cor(crime$BelowWage, crime$CrimeRate),
            cor.test(crime$BelowWage, crime$CrimeRate)$p.value))
cat(sprintf("  Wage vs BelowWage:      r=%+.4f  p=%.4f\n",
            cor(crime$Wage, crime$BelowWage),
            cor.test(crime$Wage, crime$BelowWage)$p.value))
cat("  >> Higher wages -> fewer families below poverty line (r=-0.88)\n")
cat("  >> But higher wages -> more crime (r=+0.42)\n")
cat("  >> Wage is a proxy for URBANISATION — not a direct driver of crime\n")

# Plot 6: Wage triangle
p6a <- ggplot(crime, aes(Wage, CrimeRate, color=Southern)) +
  geom_point(size=2.8, alpha=0.85) +
  geom_smooth(method="lm", se=TRUE, aes(group=1), color="#2c3e50", fill="grey70", alpha=0.2) +
  scale_color_manual(values=c("Non-Southern"="#2980b9","Southern"="#e74c3c")) +
  labs(title="Higher Wages → More Crime?",
       subtitle=paste0("r = +", round(cor(crime$Wage, crime$CrimeRate),3)),
       x="Median Weekly Wage", y="Crime Rate") + mytheme

p6b <- ggplot(crime, aes(Wage, BelowWage, color=Southern)) +
  geom_point(size=2.8, alpha=0.85) +
  geom_smooth(method="lm", se=TRUE, aes(group=1), color="#2c3e50", fill="grey70", alpha=0.2) +
  scale_color_manual(values=c("Non-Southern"="#2980b9","Southern"="#e74c3c")) +
  labs(title="Higher Wages → Fewer Families in Poverty",
       subtitle=paste0("r = ", round(cor(crime$Wage, crime$BelowWage),3), " — very strong"),
       x="Median Weekly Wage", y="Families Below Half-Wage (per 1000)") + mytheme

p6 <- grid.arrange(p6a, p6b, ncol=2,
  top=grid::textGrob("The Wage Paradox: Urbanisation as Hidden Confound",
    gp=grid::gpar(fontface="bold", fontsize=14, col="#1F4E79")))
ggsave("outputs/plots/06_wage_paradox.png", p6, width=12, height=5, dpi=150)
cat("Saved: 06_wage_paradox.png\n")

# Paradox 3: Education
cat("\nPARADOX 3 — Education:\n")
cat(sprintf("  Education(t0) vs Crime(t0):   r=%+.4f  p=%.4f\n",
            cor(crime$Education, crime$CrimeRate),
            cor.test(crime$Education, crime$CrimeRate)$p.value))
cat(sprintf("  Education(t10) vs Crime(t10): r=%+.4f  p=%.4f\n",
            cor(crime$Education10, crime$CrimeRate10),
            cor.test(crime$Education10, crime$CrimeRate10)$p.value))
cat("  >> More education slightly associated with MORE crime — neither timepoint significant\n")
cat("  >> Urbanisation confound again: educated states tend to be urban, urban = more crime\n")


# =============================================================================
# SECTION 4: GROUP COMPARISONS
# =============================================================================
cat("\n=== SECTION 4: GROUP COMPARISONS ===\n")

# Southern vs Non-Southern — deep dive
south    <- crime %>% filter(Southern=="Southern")
nonsouth <- crime %>% filter(Southern=="Non-Southern")

cat("SOUTHERN vs NON-SOUTHERN:\n")
vars_to_compare <- c("CrimeRate","Wage","Education","ExpenditureYear0",
                     "BelowWage","YouthUnemployment")
for (v in vars_to_compare) {
  s_vals  <- south[[v]]
  ns_vals <- nonsouth[[v]]
  tt <- t.test(s_vals, ns_vals, var.equal=FALSE)
  d  <- cohens_d(ns_vals, s_vals)
  cat(sprintf("  %-20s South=%.1f  NonSouth=%.1f  p=%.4f  d=%.3f %s\n",
              v, mean(s_vals), mean(ns_vals), tt$p.value,
              abs(d), ifelse(tt$p.value<0.05,"**","")))
}

# Plot 7: Southern states comparison panel
south_long <- crime %>%
  select(Southern, CrimeRate, Wage, Education, ExpenditureYear0, BelowWage) %>%
  pivot_longer(-Southern, names_to="Variable", values_to="Value") %>%
  mutate(Variable = recode(Variable,
    "CrimeRate"        = "Crime Rate\n(p=0.691, ns)",
    "Wage"             = "Median Wage\n(p<0.001 **)",
    "Education"        = "Education Years\n(p=0.001 **)",
    "ExpenditureYear0" = "Police Expenditure\n(p=0.005 **)",
    "BelowWage"        = "Families Below\nPoverty (p<0.001 **)"
  ))

p7 <- ggplot(south_long, aes(Southern, Value, fill=Southern)) +
  geom_boxplot(alpha=0.75, width=0.5, outlier.shape=21) +
  geom_jitter(width=0.12, alpha=0.5, size=1.8, color="grey30") +
  facet_wrap(~Variable, scales="free_y", nrow=1) +
  scale_fill_manual(values=c("Non-Southern"="#2980b9","Southern"="#e74c3c")) +
  labs(title="Southern vs Non-Southern States: Similar Crime Rates, Very Different Conditions",
       subtitle="Crime rates do not differ significantly — but wages, education, spending, and poverty all do",
       x=NULL, y=NULL) +
  mytheme + theme(legend.position="none",
                  axis.text.x=element_text(angle=30, hjust=1))
ggsave("outputs/plots/07_southern_comparison.png", p7, width=14, height=6, dpi=150)
cat("Saved: 07_southern_comparison.png\n")

# High vs Low Youth Unemployment
high_yu <- crime %>% filter(HighYouthUnemploy=="High")
low_yu  <- crime %>% filter(HighYouthUnemploy=="Low")
tt_yu   <- t.test(high_yu$CrimeRate, low_yu$CrimeRate, var.equal=FALSE)
d_yu    <- cohens_d(high_yu$CrimeRate, low_yu$CrimeRate)

cat(sprintf("\nHigh vs Low Youth Unemployment:\n"))
cat(sprintf("  High (n=%d): mean=%.2f  Low (n=%d): mean=%.2f\n",
            nrow(high_yu), mean(high_yu$CrimeRate),
            nrow(low_yu),  mean(low_yu$CrimeRate)))
cat(sprintf("  t=%.4f  p=%.4f  d=%.4f\n", tt_yu$statistic, tt_yu$p.value, d_yu))
cat(sprintf("  >> Borderline (p=0.062) — medium effect (d=%.2f) but insufficient power\n", abs(d_yu)))

p8 <- ggplot(crime, aes(HighYouthUnemploy, CrimeRate, fill=HighYouthUnemploy)) +
  geom_boxplot(alpha=0.75, width=0.45, outlier.shape=NA) +
  geom_jitter(width=0.15, alpha=0.65, size=2.5, color="grey30") +
  stat_summary(fun=mean, geom="point", shape=18, size=5, color="#2c3e50") +
  scale_fill_manual(values=c("Low"="#27ae60","High"="#e74c3c")) +
  annotate("text", x=1.5, y=163,
           label=paste0("p = ",round(tt_yu$p.value,3),
                        "  |  d = ",round(abs(d_yu),2),
                        "\n(borderline — power limited by n=47)"),
           size=3.5, color="grey30", hjust=0.5) +
  labs(title="High vs Low Youth Unemployment: Crime Rate Comparison",
       subtitle=paste0("High group (n=",nrow(high_yu),"): mean=",round(mean(high_yu$CrimeRate),1),
                       "  |  Low group (n=",nrow(low_yu),"): mean=",round(mean(low_yu$CrimeRate),1)),
       x="Youth Unemployment Level", y="Crime Rate",
       caption="Diamond = group mean") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/08_youth_unemployment.png", p8, width=7, height=6, dpi=150)
cat("Saved: 08_youth_unemployment.png\n")


# =============================================================================
# SECTION 5: MULTIPLE LINEAR REGRESSION
# =============================================================================
cat("\n=== SECTION 5: MULTIPLE LINEAR REGRESSION ===\n")

# Model: CrimeRate ~ LogExpenditure + Wage + StateSize + BelowWage
model <- lm(CrimeRate ~ LogExpenditure + Wage + StateSize + BelowWage, data=crime)
model_sum <- summary(model)

cat("Model: CrimeRate ~ LogExpenditure + Wage + StateSize + BelowWage\n\n")
print(model_sum)
cat(sprintf("\nR² = %.4f  Adjusted R² = %.4f\n",
            model_sum$r.squared, model_sum$adj.r.squared))

# Check LINE assumptions
sw_resid <- shapiro.test(residuals(model))
cat(sprintf("\nShapiro-Wilk on residuals: W=%.4f  p=%.4f  [%s]\n",
            sw_resid$statistic, sw_resid$p.value,
            ifelse(sw_resid$p.value>0.05,"Normal ✓","Not Normal ✗")))

# Plot 9: Actual vs Predicted
crime$predicted <- fitted(model)
crime$residuals <- residuals(model)
r_ap <- cor(crime$CrimeRate, crime$predicted)

p9 <- ggplot(crime, aes(predicted, CrimeRate, color=Southern)) +
  geom_point(size=3, alpha=0.85) +
  geom_abline(slope=1, intercept=0, linetype="dashed", color="grey40", linewidth=1) +
  geom_smooth(method="lm", se=FALSE, aes(group=1), color="#2c3e50", linewidth=0.8) +
  scale_color_manual(values=c("Non-Southern"="#2980b9","Southern"="#e74c3c")) +
  labs(title="Multiple Regression: Predicted vs Actual Crime Rate",
       subtitle=paste0("R² = ", round(model_sum$r.squared,3),
                       "  |  Adjusted R² = ", round(model_sum$adj.r.squared,3),
                       "  |  r(predicted, actual) = ", round(r_ap,3)),
       x="Predicted Crime Rate", y="Actual Crime Rate",
       caption="Points close to dashed diagonal = accurate predictions",
       color="Region") + mytheme
ggsave("outputs/plots/09_actual_vs_predicted.png", p9, width=8, height=6, dpi=150)
cat("Saved: 09_actual_vs_predicted.png\n")

# Plot 10: Residuals plot
p10 <- ggplot(crime, aes(predicted, residuals)) +
  geom_point(color="#2980b9", size=3, alpha=0.8) +
  geom_hline(yintercept=0, linetype="dashed", color="grey40", linewidth=1) +
  geom_smooth(se=FALSE, color="#e74c3c", linewidth=0.9) +
  labs(title="Residual Plot — Homoscedasticity Check",
       subtitle=paste0("Shapiro-Wilk on residuals: p = ",round(sw_resid$p.value,3),
                       "  [", ifelse(sw_resid$p.value>0.05,"Normal ✓","Not Normal ✗"),"]"),
       x="Fitted Values", y="Residuals",
       caption="Even spread around zero = homoscedasticity satisfied") + mytheme
ggsave("outputs/plots/10_residuals.png", p10, width=8, height=5, dpi=150)
cat("Saved: 10_residuals.png\n")

# Plot 11: Standardised coefficient plot
std_model <- lm(scale(CrimeRate) ~ scale(LogExpenditure) + scale(Wage) +
                  scale(StateSize) + scale(BelowWage), data=crime)
coef_df <- data.frame(
  Predictor = c("Log(Police Expenditure)","Median Wage","State Size","Below-Wage Families"),
  Beta      = coef(std_model)[-1],
  SE        = summary(std_model)$coefficients[-1,2],
  p_val     = summary(std_model)$coefficients[-1,4]
) %>% mutate(
  Significant = ifelse(p_val < 0.05, "Significant (p<0.05)", "Not significant"),
  Label       = sprintf("β=%.3f", Beta)
) %>% arrange(abs(Beta))
coef_df$Predictor <- factor(coef_df$Predictor, levels=coef_df$Predictor)

p11 <- ggplot(coef_df, aes(Beta, Predictor, color=Significant)) +
  geom_vline(xintercept=0, linetype="dashed", color="grey50", linewidth=0.9) +
  geom_errorbarh(aes(xmin=Beta-1.96*SE, xmax=Beta+1.96*SE), height=0.2, linewidth=1) +
  geom_point(size=5) +
  geom_text(aes(label=Label), hjust=-0.3, size=3.5, color="grey30") +
  scale_color_manual(values=c("Significant (p<0.05)"="#1a7abf","Not significant"="#e74c3c")) +
  labs(title="Multiple Regression: Standardised Coefficients (β)",
       subtitle="Error bars = 95% confidence intervals  ·  All predictors on same scale for comparison",
       x="Standardised Beta Coefficient", y=NULL,
       caption="β > 0: higher value → higher crime rate",
       color=NULL) + mytheme
ggsave("outputs/plots/11_coefficient_plot.png", p11, width=9, height=5, dpi=150)
cat("Saved: 11_coefficient_plot.png\n")


# =============================================================================
# SECTION 6: LONGITUDINAL ANALYSIS — 10-YEAR PERSISTENCE
# =============================================================================
cat("\n=== SECTION 6: LONGITUDINAL ANALYSIS ===\n")

# Paired t-test: overall change
tt_long <- t.test(crime$CrimeRate, crime$CrimeRate10, paired=TRUE)
cat(sprintf("Paired t-test (Crime Y0 vs Y10): t=%.4f  p=%.4f\n",
            tt_long$statistic, tt_long$p.value))
cat(sprintf("Mean change: %.2f  |  SD of change: %.2f\n",
            mean(crime$CrimeChange), sd(crime$CrimeChange)))
cat(sprintf("Increased: %d/47  Decreased: %d/47\n",
            sum(crime$CrimeChange>0), sum(crime$CrimeChange<0)))

# Crime persistence
r_persist <- cor.test(crime$CrimeRate, crime$CrimeRate10)
cat(sprintf("\nCrime persistence (r between t0 and t10): r=%.4f  p=%.6f\n",
            r_persist$estimate, r_persist$p.value))
cat(">> Exceptional stability — crime rate is a structural state characteristic\n")

# Plot 12: Crime persistence — Year 0 vs Year 10
p12 <- ggplot(crime, aes(CrimeRate, CrimeRate10, color=Southern)) +
  geom_point(size=3, alpha=0.85) +
  geom_abline(slope=1, intercept=0, linetype="dashed", color="grey50", linewidth=1) +
  geom_smooth(method="lm", se=TRUE, aes(group=1),
              color="#2c3e50", fill="grey70", alpha=0.2, linewidth=1.1) +
  scale_color_manual(values=c("Non-Southern"="#2980b9","Southern"="#e74c3c")) +
  annotate("text", x=58, y=170,
           label=paste0("r = ",round(r_persist$estimate,3),
                        "\np < 0.001\nExceptional structural persistence"),
           size=3.8, hjust=0, color="#1F4E79", fontface="bold") +
  labs(title="Crime Rate Persistence Across 10 Years (r = 0.997)",
       subtitle="States with high crime in Year 0 almost perfectly maintained that ranking 10 years later",
       x="Crime Rate — Year 0", y="Crime Rate — Year 10",
       caption="Points above diagonal = increased; below = decreased  ·  Dashed = no change",
       color="Region") + mytheme
ggsave("outputs/plots/12_crime_persistence.png", p12, width=9, height=7, dpi=150)
cat("Saved: 12_crime_persistence.png\n")

# Plot 13: Crime change distribution
change_df <- data.frame(
  State    = 1:47,
  Change   = crime$CrimeChange,
  Direction = ifelse(crime$CrimeChange > 0, "Increased","Decreased"),
  Southern = crime$Southern
)
p13 <- ggplot(change_df, aes(x=reorder(State, Change), y=Change, fill=Direction)) +
  geom_col(alpha=0.85) +
  geom_hline(yintercept=0, color="grey30", linewidth=0.8) +
  geom_hline(yintercept=mean(change_df$Change), linetype="dashed",
             color="#2c3e50", linewidth=1) +
  scale_fill_manual(values=c("Increased"="#e74c3c","Decreased"="#27ae60")) +
  labs(title="Crime Rate Change per State Over 10 Years",
       subtitle=paste0("27 states increased, 20 decreased  |  Mean change = ",
                       round(mean(change_df$Change),2),
                       " (not significant, p=0.640)  |  Dashed = mean"),
       x="States (ordered by change)", y="Change in Crime Rate",
       fill="Direction") + mytheme +
  theme(axis.text.x=element_blank(), axis.ticks.x=element_blank())
ggsave("outputs/plots/13_crime_change.png", p13, width=10, height=5, dpi=150)
cat("Saved: 13_crime_change.png\n")

cat("\n=== ANALYSIS COMPLETE — 13 plots saved ===\n")
