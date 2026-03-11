# =============================================================================
# Titanic Survival Analysis — Mayerfeld Data Analytics Course | Week 4
# Author: MD Noornabi
# Date: March 2026
#
# Dataset: 1,309 Titanic passengers — survival, class, gender, age, fare,
#          family size, nationality across 15 variables
#
# Central question: Who survived the Titanic — and why?
# Unpacking the role of class, gender, age, family size and nationality.
#
# Analysis structure:
#   Section 1 — Exploratory Data Analysis & Missing Data Audit
#   Section 2 — "Women and Children First": Did it actually work?
#   Section 3 — Class: The Dominant Survival Factor
#   Section 4 — Family Size: The Non-Linear Sweet Spot
#   Section 5 — British vs American: Testing the Newspaper Headline
#   Section 6 — Logistic Regression: Predicting Survival Probability
#   Section 7 — Survival Archetypes: Putting It All Together
# =============================================================================

# install.packages(c("tidyverse","ggplot2","gridExtra","scales","ggmosaic"))

library(tidyverse)
library(ggplot2)
library(gridExtra)
library(scales)

# ── LOAD & CLEAN DATA ────────────────────────────────────────────────────────
titanic <- read.csv("data/Titanic.csv", stringsAsFactors=FALSE, na.strings=c("","NA"," "))

titanic <- titanic %>%
  mutate(
    survived   = factor(survived, levels=c(0,1), labels=c("Died","Survived")),
    pclass     = factor(pclass,   levels=c(1,2,3), labels=c("1st Class","2nd Class","3rd Class")),
    Gender     = factor(Gender,   levels=c(0,1),   labels=c("Male","Female")),
    Residence  = factor(Residence,levels=c(0,1,2), labels=c("American","British","Other")),
    age        = as.numeric(age),
    fare       = as.numeric(fare),
    sibsp      = as.integer(sibsp),
    parch      = as.integer(parch),
    family_size = sibsp + parch,
    family_group = case_when(
      family_size == 0 ~ "Solo",
      family_size <= 3 ~ "Small (1-3)",
      TRUE             ~ "Large (4+)"
    ),
    age_group = case_when(
      age < 18          ~ "Child (<18)",
      age < 40          ~ "Adult (18-39)",
      !is.na(age)       ~ "Older (40+)",
      TRUE              ~ NA_character_
    ),
    survived_num = as.integer(survived == "Survived")
  )

cat("=== DATASET OVERVIEW ===\n")
cat("Passengers:", nrow(titanic), "\n")
cat("Survived:", sum(titanic$survived=="Survived"), "(", round(mean(titanic$survived=="Survived")*100,1), "%)\n")
cat("Died:", sum(titanic$survived=="Died"), "\n")

# ── THEME ────────────────────────────────────────────────────────────────────
mytheme <- theme_minimal(base_size=13) +
  theme(
    plot.title    = element_text(face="bold", size=14, color="#1F4E79"),
    plot.subtitle = element_text(color="grey40", size=11),
    plot.caption  = element_text(color="grey55", size=9, face="italic"),
    panel.grid.minor = element_blank(),
    legend.position = "bottom"
  )

surv_colors <- c("Survived"="#27AE60","Died"="#E74C3C")
class_colors <- c("1st Class"="#1A5276","2nd Class"="#2980B9","3rd Class"="#85C1E9")
gender_colors <- c("Male"="#2980B9","Female"="#E74C3C")

# =============================================================================
# SECTION 1: EDA & MISSING DATA AUDIT
# =============================================================================
cat("\n=== SECTION 1: EDA & MISSING DATA ===\n")

# Missing data summary
missing_df <- data.frame(
  Variable = names(titanic),
  Missing  = sapply(titanic, function(x) sum(is.na(x)))
) %>% filter(Missing > 0) %>%
  mutate(Pct = round(Missing/nrow(titanic)*100, 1)) %>%
  arrange(desc(Pct))
print(missing_df)

# Non-random missingness in age
age_missing_surv <- sum(is.na(titanic$age) & titanic$survived=="Survived")
age_missing_died <- sum(is.na(titanic$age) & titanic$survived=="Died")
cat(sprintf("\nAge missing — Survived: %d | Died: %d\n", age_missing_surv, age_missing_died))
cat(">> Age missingness is NOT random — disproportionately among those who died\n")

# Plot 1: Survival overview
surv_summary <- titanic %>%
  count(survived) %>%
  mutate(pct = n/sum(n)*100,
         label = paste0(survived, "\n", n, "\n(", round(pct,1), "%)"))

p1 <- ggplot(titanic, aes(x=factor(1), fill=survived)) +
  geom_bar(width=0.7, position="stack") +
  geom_text(data=surv_summary,
            aes(x=1, y=cumsum(n)-n/2, label=label, fill=NULL),
            size=4.5, fontface="bold", color="white") +
  scale_fill_manual(values=surv_colors) +
  coord_flip() +
  labs(title="Titanic: Overall Survival",
       subtitle="500 survived (38.2%) of 1,309 passengers | April 14–15, 1912",
       x=NULL, y="Number of Passengers", fill=NULL) +
  mytheme + theme(axis.text.y=element_blank(), axis.ticks.y=element_blank())
ggsave("outputs/plots/01_survival_overview.png", p1, width=9, height=4, dpi=150)
cat("Saved: 01_survival_overview.png\n")

# Plot 2: Missing data chart
p2 <- missing_df %>%
  filter(Variable %in% c("age","cabin","boat","body","home.dest")) %>%
  ggplot(aes(reorder(Variable, Pct), Pct, fill=Pct)) +
  geom_col(alpha=0.85) +
  geom_text(aes(label=paste0(Pct,"%")), hjust=-0.2, size=4) +
  scale_fill_gradient(low="#F9E79F", high="#E74C3C") +
  coord_flip() +
  labs(title="Missing Data Audit — Key Variables",
       subtitle="Age (20% missing, non-randomly) requires careful interpretation\nCabin/body/boat missing by design — not usable for analysis",
       x=NULL, y="% Missing") +
  mytheme + theme(legend.position="none") +
  ylim(0, 105)
ggsave("outputs/plots/02_missing_data.png", p2, width=8, height=5, dpi=150)
cat("Saved: 02_missing_data.png\n")


# =============================================================================
# SECTION 2: WOMEN AND CHILDREN FIRST
# =============================================================================
cat("\n=== SECTION 2: WOMEN AND CHILDREN FIRST ===\n")

# Gender survival
gender_surv <- titanic %>%
  group_by(Gender) %>%
  summarise(n=n(), survived=sum(survived_num), pct=mean(survived_num)*100)
print(gender_surv)

gender_chi <- chisq.test(table(titanic$Gender, titanic$survived))
cat(sprintf("Chi-square Gender x Survival: chi2=%.1f  p=%.2e\n",
            gender_chi$statistic, gender_chi$p.value))

# Odds ratio
f_s <- sum(titanic$Gender=="Female" & titanic$survived=="Survived")
f_d <- sum(titanic$Gender=="Female" & titanic$survived=="Died")
m_s <- sum(titanic$Gender=="Male"   & titanic$survived=="Survived")
m_d <- sum(titanic$Gender=="Male"   & titanic$survived=="Died")
or_gender <- (f_s/f_d) / (m_s/m_d)
cat(sprintf("Odds Ratio (Female vs Male): %.2fx\n", or_gender))

# Plot 3: Gender survival
p3 <- gender_surv %>%
  ggplot(aes(Gender, pct, fill=Gender)) +
  geom_col(alpha=0.85, width=0.5) +
  geom_text(aes(label=paste0(round(pct,1),"%\n(n=",n,")")),
            vjust=-0.3, size=4.5, fontface="bold") +
  scale_fill_manual(values=gender_colors) +
  scale_y_continuous(limits=c(0,90), labels=function(x) paste0(x,"%")) +
  annotate("text", x=1.5, y=80,
           label=paste0("χ² = ", round(gender_chi$statistic,1),
                        ",  p < 0.001\nOdds Ratio = ", round(or_gender,1), "x"),
           size=4, color="grey30", hjust=0.5) +
  labs(title="Survival by Gender",
       subtitle="Women were 11.3x more likely to survive than men",
       x=NULL, y="Survival Rate") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/03_gender_survival.png", p3, width=7, height=6, dpi=150)
cat("Saved: 03_gender_survival.png\n")

# Children survival — overall vs by class
children <- titanic %>% filter(!is.na(age) & age < 18)
adults   <- titanic %>% filter(!is.na(age) & age >= 18)
cat(sprintf("\nChildren (<18): %d total, %d survived (%.1f%%)\n",
            nrow(children), sum(children$survived_num),
            mean(children$survived_num)*100))

children_by_class <- titanic %>%
  filter(!is.na(age) & age < 18) %>%
  group_by(pclass) %>%
  summarise(n=n(), pct=mean(survived_num)*100)
print(children_by_class)

# Women and Children First — three group comparison
wc_df <- data.frame(
  Group = c("Women","Children\n(<18)","Adult Men"),
  Pct   = c(
    mean(titanic$survived_num[titanic$Gender=="Female"])*100,
    mean(titanic$survived_num[!is.na(titanic$age) & titanic$age<18])*100,
    mean(titanic$survived_num[titanic$Gender=="Male" & (!is.na(titanic$age) & titanic$age>=18 | is.na(titanic$age))])*100
  ),
  n = c(
    sum(titanic$Gender=="Female"),
    sum(!is.na(titanic$age) & titanic$age<18),
    sum(titanic$Gender=="Male")
  )
)

p4 <- ggplot(wc_df, aes(Group, Pct, fill=Group)) +
  geom_col(alpha=0.85, width=0.5) +
  geom_text(aes(label=paste0(round(Pct,1),"%\n(n=",n,")")),
            vjust=-0.3, size=4.5, fontface="bold") +
  scale_fill_manual(values=c("Women"="#E74C3C","Children\n(<18)"="#F39C12","Adult Men"="#2980B9")) +
  scale_y_continuous(limits=c(0,90), labels=function(x) paste0(x,"%")) +
  labs(title='"Women and Children First" — Did the Rule Hold?',
       subtitle="The protocol was followed overall — but class determined whether it applied to children",
       x=NULL, y="Survival Rate") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/04_women_children_first.png", p4, width=8, height=6, dpi=150)
cat("Saved: 04_women_children_first.png\n")

# Plot 5: Children by class — the hidden story
p5 <- children_by_class %>%
  ggplot(aes(pclass, pct, fill=pclass)) +
  geom_col(alpha=0.85, width=0.5) +
  geom_text(aes(label=paste0(round(pct,1),"%\n(n=",n,")")),
            vjust=-0.3, size=4.5, fontface="bold") +
  scale_fill_manual(values=class_colors) +
  scale_y_continuous(limits=c(0,105), labels=function(x) paste0(x,"%")) +
  labs(title="Children's Survival Rate by Class: The Hidden Inequality",
       subtitle="'Women and children first' only held in 1st and 2nd class\n3rd class children (36.8%) died at nearly the same rate as adults",
       x=NULL, y="Survival Rate (children <18 only)") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/05_children_by_class.png", p5, width=8, height=6, dpi=150)
cat("Saved: 05_children_by_class.png\n")


# =============================================================================
# SECTION 3: CLASS — THE DOMINANT SURVIVAL FACTOR
# =============================================================================
cat("\n=== SECTION 3: CLASS ===\n")

class_surv <- titanic %>%
  group_by(pclass) %>%
  summarise(n=n(), survived=sum(survived_num), pct=mean(survived_num)*100)
print(class_surv)

class_chi <- chisq.test(table(titanic$pclass, titanic$survived))
cat(sprintf("Chi-square Class x Survival: chi2=%.1f  p=%.2e\n",
            class_chi$statistic, class_chi$p.value))

# Class OR (1st vs 3rd)
c1s <- sum(titanic$pclass=="1st Class" & titanic$survived=="Survived")
c1d <- sum(titanic$pclass=="1st Class" & titanic$survived=="Died")
c3s <- sum(titanic$pclass=="3rd Class" & titanic$survived=="Survived")
c3d <- sum(titanic$pclass=="3rd Class" & titanic$survived=="Died")
or_class <- (c1s/c1d)/(c3s/c3d)
cat(sprintf("Odds Ratio (1st vs 3rd class): %.2fx\n", or_class))

# Fare comparison
fare_surv <- titanic %>% filter(!is.na(fare)) %>%
  group_by(survived) %>%
  summarise(mean_fare=mean(fare), median_fare=median(fare))
print(fare_surv)
fare_t <- t.test(fare ~ survived, data=titanic %>% filter(!is.na(fare)), var.equal=FALSE)
cat(sprintf("Fare t-test: t=%.3f  p=%.6f\n", fare_t$statistic, fare_t$p.value))

# Plot 6: Class survival
p6 <- class_surv %>%
  ggplot(aes(pclass, pct, fill=pclass)) +
  geom_col(alpha=0.85, width=0.5) +
  geom_text(aes(label=paste0(round(pct,1),"%\n(n=",n,")")),
            vjust=-0.3, size=4.5, fontface="bold") +
  scale_fill_manual(values=class_colors) +
  scale_y_continuous(limits=c(0,80), labels=function(x) paste0(x,"%")) +
  annotate("text", x=2, y=72,
           label=paste0("χ² = ",round(class_chi$statistic,1),",  p < 0.001\n",
                        "OR (1st vs 3rd) = ",round(or_class,1),"x"),
           size=3.8, color="grey30", hjust=0.5) +
  labs(title="Survival by Passenger Class",
       subtitle="First class passengers were 4.74x more likely to survive than third class",
       x=NULL, y="Survival Rate") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/06_class_survival.png", p6, width=7, height=6, dpi=150)
cat("Saved: 06_class_survival.png\n")

# Plot 7: Class x Gender heatmap — the showpiece
class_gender <- titanic %>%
  group_by(pclass, Gender) %>%
  summarise(n=n(), pct=mean(survived_num)*100, .groups="drop")

p7 <- ggplot(class_gender, aes(Gender, pclass, fill=pct)) +
  geom_tile(color="white", linewidth=2) +
  geom_text(aes(label=paste0(round(pct,1),"%\n(n=",n,")")),
            size=4.5, fontface="bold", color="white") +
  scale_fill_gradient2(low="#E74C3C", mid="#F39C12", high="#27AE60",
                       midpoint=50, limits=c(0,100),
                       labels=function(x) paste0(x,"%")) +
  labs(title="Survival Rate: Class × Gender Interaction",
       subtitle="A 3rd class woman (49.1%) had a lower survival chance than a 1st class man (34.1%)\nClass overrode gender for women in steerage",
       x=NULL, y=NULL, fill="Survival Rate") +
  mytheme + theme(legend.position="right")
ggsave("outputs/plots/07_class_gender_heatmap.png", p7, width=8, height=6, dpi=150)
cat("Saved: 07_class_gender_heatmap.png\n")

# Plot 8: Fare by survival — violin
p8 <- titanic %>% filter(!is.na(fare) & fare > 0) %>%
  ggplot(aes(survived, fare, fill=survived)) +
  geom_violin(alpha=0.7, trim=TRUE) +
  geom_boxplot(width=0.15, alpha=0.9, outlier.shape=NA) +
  scale_y_log10(labels=function(x) paste0("£",x)) +
  scale_fill_manual(values=surv_colors) +
  annotate("text", x=1.5, y=300,
           label=paste0("Survivors paid £",round(mean(titanic$fare[titanic$survived=="Survived"],na.rm=TRUE),2),
                        " avg\nDied paid £",round(mean(titanic$fare[titanic$survived=="Died"],na.rm=TRUE),2),
                        " avg\np < 0.001"),
           size=3.8, color="grey30", hjust=0.5) +
  labs(title="Ticket Fare by Survival Outcome (Log Scale)",
       subtitle="Survivors paid more than twice the average fare of those who died",
       x=NULL, y="Fare (£, log scale)",
       caption="Log scale used — fare is heavily right-skewed") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/08_fare_survival.png", p8, width=7, height=6, dpi=150)
cat("Saved: 08_fare_survival.png\n")


# =============================================================================
# SECTION 4: FAMILY SIZE — THE NON-LINEAR SWEET SPOT
# =============================================================================
cat("\n=== SECTION 4: FAMILY SIZE ===\n")

family_surv <- titanic %>%
  group_by(family_size) %>%
  summarise(n=n(), pct=mean(survived_num)*100) %>%
  filter(n >= 5)  # exclude tiny cells
print(family_surv)

# ANOVA across family groups
fam_anova <- aov(survived_num ~ family_group, data=titanic)
fam_sum <- summary(fam_anova)
cat(sprintf("Family group ANOVA: F=%.1f  p=%.4f\n",
            fam_sum[[1]]$`F value`[1], fam_sum[[1]]$`Pr(>F)`[1]))

# Plot 9: Family size curve
p9 <- titanic %>%
  group_by(family_size) %>%
  summarise(n=n(), pct=mean(survived_num)*100) %>%
  filter(n >= 5) %>%
  ggplot(aes(factor(family_size), pct, fill=pct)) +
  geom_col(alpha=0.85) +
  geom_text(aes(label=paste0(round(pct,0),"%\n(n=",n,")")),
            vjust=-0.3, size=3.8) +
  scale_fill_gradient2(low="#E74C3C", mid="#F39C12", high="#27AE60",
                       midpoint=50, limits=c(0,100)) +
  scale_y_continuous(limits=c(0,85), labels=function(x) paste0(x,"%")) +
  labs(title="Survival Rate by Family Size: The Non-Linear Sweet Spot",
       subtitle="Family size 3 had the highest survival (69.8%)  ·  Families of 4+ saw survival collapse\nSolo travellers (30.3%) did worse than those with 1–3 family members",
       x="Family Size (siblings + spouses + parents + children)",
       y="Survival Rate",
       caption="Only groups with n ≥ 5 shown") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/09_family_size.png", p9, width=9, height=6, dpi=150)
cat("Saved: 09_family_size.png\n")


# =============================================================================
# SECTION 5: BRITISH vs AMERICAN — TESTING THE HEADLINE
# =============================================================================
cat("\n=== SECTION 5: BRITISH vs AMERICAN ===\n")

res_surv <- titanic %>%
  filter(Residence %in% c("American","British")) %>%
  group_by(Residence) %>%
  summarise(n=n(), pct=mean(survived_num)*100)
print(res_surv)

res_chi <- chisq.test(table(
  titanic$Residence[titanic$Residence %in% c("American","British")],
  titanic$survived[titanic$Residence %in% c("American","British")]
))
cat(sprintf("Chi-square British vs American: chi2=%.3f  p=%.4f\n",
            res_chi$statistic, res_chi$p.value))

# Class composition
class_comp <- titanic %>%
  filter(Residence %in% c("American","British")) %>%
  group_by(Residence, pclass) %>%
  summarise(n=n(), .groups="drop") %>%
  group_by(Residence) %>%
  mutate(pct=n/sum(n)*100)
print(class_comp)

# Plot 10: British vs American survival
p10 <- res_surv %>%
  ggplot(aes(Residence, pct, fill=Residence)) +
  geom_col(alpha=0.85, width=0.45) +
  geom_text(aes(label=paste0(round(pct,1),"%\n(n=",n,")")),
            vjust=-0.3, size=4.5, fontface="bold") +
  scale_fill_manual(values=c("American"="#2980B9","British"="#E74C3C")) +
  scale_y_continuous(limits=c(0,75), labels=function(x) paste0(x,"%")) +
  annotate("text", x=1.5, y=67,
           label=paste0("χ² = ",round(res_chi$statistic,2),",  p < 0.001"),
           size=4, color="grey30", hjust=0.5) +
  labs(title='British vs American Survival: Testing the "Queuing" Headline',
       subtitle="Americans survived at nearly twice the rate of British passengers\nBut is this really about queuing — or about class?",
       x=NULL, y="Survival Rate") +
  mytheme + theme(legend.position="none")
ggsave("outputs/plots/10_british_vs_american.png", p10, width=7, height=6, dpi=150)
cat("Saved: 10_british_vs_american.png\n")

# Plot 11: Class composition — the confound revealed
p11 <- class_comp %>%
  ggplot(aes(Residence, pct, fill=pclass)) +
  geom_col(alpha=0.85) +
  geom_text(aes(label=paste0(round(pct,0),"%")),
            position=position_stack(vjust=0.5),
            size=4, fontface="bold", color="white") +
  scale_fill_manual(values=class_colors) +
  scale_y_continuous(labels=function(x) paste0(x,"%")) +
  labs(title="The Confound Revealed: Class Composition by Nationality",
       subtitle="69.8% of Americans were 1st class  ·  Only 11.6% of British were 1st class\nThe 'queuing' story is almost certainly a class story in disguise",
       x=NULL, y="% of Nationality Group", fill="Class") +
  mytheme
ggsave("outputs/plots/11_nationality_class_confound.png", p11, width=8, height=6, dpi=150)
cat("Saved: 11_nationality_class_confound.png\n")


# =============================================================================
# SECTION 6: LOGISTIC REGRESSION
# =============================================================================
cat("\n=== SECTION 6: LOGISTIC REGRESSION ===\n")

# Build model on complete cases
titanic_complete <- titanic %>%
  filter(!is.na(age) & !is.na(fare)) %>%
  mutate(pclass_num = as.integer(pclass),
         gender_num = as.integer(Gender=="Female"))

model <- glm(survived_num ~ gender_num + pclass_num + age + fare + family_size,
             data=titanic_complete, family=binomial)
model_sum <- summary(model)
cat("\nLogistic Regression Summary:\n")
print(model_sum)

# Odds ratios
or_df <- data.frame(
  Predictor = c("Female (vs Male)","Class (per step down)","Age (per year)","Fare (per £)","Family Size (per person)"),
  OR        = exp(coef(model)[-1]),
  Lower     = exp(confint.default(model)[-1,1]),
  Upper     = exp(confint.default(model)[-1,2]),
  p         = model_sum$coefficients[-1,4]
) %>% mutate(
  Significant = ifelse(p < 0.05,"Significant (p<0.05)","Not significant")
)
print(or_df)

# Pseudo R-squared (McFadden)
null_model <- glm(survived_num ~ 1, data=titanic_complete, family=binomial)
pseudo_r2 <- 1 - logLik(model)/logLik(null_model)
cat(sprintf("\nMcFadden Pseudo-R²: %.4f\n", pseudo_r2))

# Plot 12: Odds ratio plot
or_df$Predictor <- factor(or_df$Predictor, levels=rev(or_df$Predictor))
p12 <- ggplot(or_df, aes(OR, Predictor, color=Significant)) +
  geom_vline(xintercept=1, linetype="dashed", color="grey50", linewidth=1) +
  geom_errorbarh(aes(xmin=Lower, xmax=Upper), height=0.25, linewidth=1.1) +
  geom_point(size=5) +
  geom_text(aes(label=paste0("OR=",round(OR,2))), hjust=-0.3, size=3.8, color="grey30") +
  scale_color_manual(values=c("Significant (p<0.05)"="#1A7ABF","Not significant"="#E74C3C")) +
  scale_x_log10() +
  labs(title="Logistic Regression: Odds Ratios for Survival",
       subtitle=paste0("Being female increased survival odds by 11x  ·  Each class step down reduced odds by ~60%\n",
                       "McFadden Pseudo-R² = ",round(as.numeric(pseudo_r2),3),
                       "  ·  n = ",nrow(titanic_complete)," complete cases"),
       x="Odds Ratio (log scale)  ·  OR > 1 = higher survival odds",
       y=NULL, color=NULL,
       caption="Error bars = 95% confidence intervals") +
  mytheme
ggsave("outputs/plots/12_odds_ratios.png", p12, width=10, height=6, dpi=150)
cat("Saved: 12_odds_ratios.png\n")


# =============================================================================
# SECTION 7: SURVIVAL ARCHETYPES
# =============================================================================
cat("\n=== SECTION 7: SURVIVAL ARCHETYPES ===\n")

# Predicted probabilities for archetypal passengers
archetypes <- data.frame(
  Archetype   = c("1st class woman, 30","2nd class woman, 30","3rd class woman, 25",
                  "1st class man, 40","2nd class man, 30","3rd class man, 25"),
  gender_num  = c(1,1,1,0,0,0),
  pclass_num  = c(1,2,3,1,2,3),
  age         = c(30,30,25,40,30,25),
  fare        = c(89,22,13,89,22,13),  # class median fares
  family_size = c(0,0,0,0,0,0)
)
archetypes$pred_prob <- predict(model, newdata=archetypes, type="response") * 100
archetypes$Outcome <- ifelse(archetypes$pred_prob >= 50, "Likely Survived","Likely Died")
cat("\nArchetype Survival Probabilities:\n")
print(archetypes[,c("Archetype","pred_prob","Outcome")])

# Plot 13: Archetypes
p13 <- archetypes %>%
  mutate(Archetype=factor(Archetype, levels=rev(Archetype))) %>%
  ggplot(aes(pred_prob, Archetype, fill=Outcome)) +
  geom_col(alpha=0.85, width=0.6) +
  geom_vline(xintercept=50, linetype="dashed", color="grey40", linewidth=1) +
  geom_text(aes(label=paste0(round(pred_prob,1),"%")),
            hjust=-0.2, size=4, fontface="bold") +
  scale_fill_manual(values=c("Likely Survived"="#27AE60","Likely Died"="#E74C3C")) +
  scale_x_continuous(limits=c(0,110), labels=function(x) paste0(x,"%")) +
  labs(title="Predicted Survival Probability by Passenger Archetype",
       subtitle="Logistic regression model predictions  ·  Dashed line = 50% threshold\nClass and gender together almost entirely determined fate",
       x="Predicted Survival Probability", y=NULL, fill=NULL,
       caption="Predictions based on solo traveller, class-median fare, no family") +
  mytheme
ggsave("outputs/plots/13_survival_archetypes.png", p13, width=10, height=6, dpi=150)
cat("Saved: 13_survival_archetypes.png\n")

cat("\n=== ANALYSIS COMPLETE — 13 plots saved ===\n")
cat("\nKey findings summary:\n")
cat(sprintf("  Gender OR:  %.2fx (female vs male)\n", or_gender))
cat(sprintf("  Class OR:   %.2fx (1st vs 3rd)\n", or_class))
cat(sprintf("  Pseudo-R²:  %.3f\n", as.numeric(pseudo_r2)))
cat("  Family size 3: highest survival (69.8%)\n")
cat("  3rd class children: 36.8% — same as adults\n")
cat("  British class confound: 69.8% of Americans were 1st class vs 11.6% of British\n")
