# Titanic Analysis — Notes & Methodological Decisions

## Dataset Quirks

- **Age missing 20.1%** — critically, missingness is NOT random. 190 deaths vs 73 survivors
  had missing age. This likely reflects lower-class passengers being less well-documented.
  Age findings (p=0.077, not significant) must be interpreted with this caveat.
- **Cabin 77.5% missing** — by design; cabin assignments were not recorded for most passengers.
  Not used in analysis.
- **Boat/Body** — missing by definition (boat = only if rescued; body = only if recovered).

## Key Analytical Decisions

### Why logistic regression (not linear)?
Outcome is binary (survived/died). Logistic regression is the correct model for binary outcomes.
Linear regression would produce predictions outside 0–1 and violates assumptions.

### Why McFadden Pseudo-R²?
Standard R² does not apply to logistic regression. McFadden's = 1 - (log-likelihood of model /
log-likelihood of null). Values of 0.2–0.4 indicate excellent model fit (unlike OLS R²).
Our value of ~0.32 indicates a well-fitting model.

### Why log scale for fare?
Fare is heavily right-skewed (max = £512.33, median = £14.45 overall). Log scale reveals
the within-group distributions more clearly.

### Complete cases for regression
Logistic regression run on 1,037 complete cases (age + fare present). This is 79.2% of
the dataset — sufficient for reliable estimation. The missing age pattern (biased toward
deaths) may slightly underestimate the true age effect.

### Odds ratios vs regression coefficients
Odds ratios (exp(β)) are reported throughout as they are more interpretable:
"Being female multiplied survival odds by 11.3x" vs "β = 2.43".

## The British vs American Finding — Methodological Note

The raw survival gap (56.2% vs 31.8%) is real and statistically significant. However,
the class composition analysis reveals the confound: 69.8% of Americans were 1st class
vs 11.6% of British. This is a textbook example of Simpson's Paradox / confounding —
a finding that appears meaningful in aggregate but is explained by a third variable.

This is reported honestly: the gap exists, but the cultural explanation ("queuing")
is not supported. The class explanation is more parsimonious.

## Family Size Finding

The non-linear relationship (sweet spot at size 3, collapse at 4+) is a genuine
discovery in this dataset. The likely mechanism: small families could locate each other
and move together; large families were immobilised trying to keep everyone together.
This is noted as a plausible interpretation, not a proven causal claim.

## What Was Not Analysed

- **Embarkation port** — dropped because it is a class proxy:
  Cherbourg = 52% 1st class, Queenstown = 92% 3rd class. No independent story.
- **Interaction terms in regression** — gender × class interaction would be
  the natural next step but is beyond the scope of this course.
- **Multiple imputation for missing age** — advanced missing data technique;
  noted as a limitation.
