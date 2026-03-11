# Analysis Notes — Crime Rate Project
## Key Findings, Paradoxes & Interpretation Guide

---

## The Central Finding

Crime rates across US states are **structurally persistent** to a near-perfect degree. The correlation between Year 0 and Year 10 crime rates is r = 0.997 — one of the most striking single numbers in this portfolio. It means that knowing a state's crime rank in Year 0 predicts its rank 10 years later with almost no error.

This persistence finding reframes everything else in the analysis. The predictors that matter — police expenditure, wage (as urbanisation proxy), state size — are themselves slow-moving structural variables. This is not a dataset that responds to short-term policy tweaks.

---

## The Three Paradoxes Explained

### Paradox 1: Police Expenditure

**The finding:** Highest correlation with crime (r = +0.65). More spending = more crime.

**The naive interpretation:** Police cause crime. Cut police spending.

**The reverse causation challenge:** High-crime states spend more on policing because of high crime — not the other way round.

**Why that's only part of the story:** Year 0 expenditure predicts Year 10 crime (r = +0.644, p < 0.001). If reverse causation fully explained it, this forward-looking prediction should weaken. It doesn't.

**The correct interpretation:** The relationship is bidirectional and structurally embedded:
- High crime → states invest in policing
- That investment becomes part of the state's infrastructure
- States with historically high crime maintain high expenditure AND high crime across both timepoints
- Expenditure is both a response to crime and a structural marker of high-crime states

### Paradox 2: Wage

**The finding:** Higher wages correlate with higher crime (r = +0.42).

**The naive interpretation:** Prosperity causes crime. Richer states are more dangerous.

**Why that's wrong:** The same high-wage states have dramatically fewer families below the poverty line (Wage vs BelowWage: r = −0.88).

**The correct interpretation:** Wage is a proxy for **urbanisation**:
- High-wage states = more urban states
- Urban areas have higher crime rates (density, opportunity, more comprehensive reporting)
- Urban areas also have higher wages and lower poverty
- Wage is a confounding variable — it correlates with crime not because wages cause crime, but because both are downstream of the urban/rural dimension

### Paradox 3: Education

**The finding:** Education slightly positively associated with crime (r = +0.16, not significant at either timepoint).

**The naive interpretation:** Education doesn't protect against crime.

**The correct interpretation:** Same urbanisation confound. More educated states are more urban. The urban effect on crime masks education's direct protective effect. In a properly controlled multiple regression with urbanisation accounted for, education would likely show a negative relationship.

---

## Southern States — The Interesting Null Result

Southern states have:
- Significantly lower wages (p < 0.001)
- Significantly lower education (p = 0.001)
- Significantly lower police expenditure (p = 0.005)
- Significantly more families below poverty line (p < 0.001)

But their crime rates are **not significantly different** from non-Southern states (p = 0.691).

**Why this is interesting:** Simple economic disadvantage doesn't explain crime rates. Southern states are disadvantaged on every measured socioeconomic variable — yet their crime rates are broadly comparable to non-Southern states. This suggests either:
1. The relationships between socioeconomic disadvantage and crime are more complex than simple direct effects
2. Structural/historical factors specific to each state matter more than current conditions
3. The urbanisation confound — Southern states may be less urban on average, counterbalancing socioeconomic disadvantages

---

## Regression Model Notes

**Variables in final model:** Log(Expenditure), Wage, StateSize, BelowWage

**Why LogExpenditure:** Expenditure was right-skewed (skewness = 0.92). Log transformation reduced this to 0.28, satisfying the normality assumption for regression. This also fits the economic intuition that expenditure effects are proportional rather than linear.

**R² = 0.629:** Strong result for observational social science data. Four variables explain 63% of variance in crime rates. The remaining 37% reflects factors not captured here — specific historical events, policing strategies, demographic changes, etc.

**Standardised β interpretation:**
- Log(Expenditure) = dominant predictor
- Wage = second strongest
- StateSize and BelowWage = weaker, potentially capturing residual urbanisation effects

**What the model cannot do:** Establish causality. These are observational data — correlational relationships only. The regression tells us which variables are associated with crime after controlling for others, not which variables *cause* crime.

---

## Youth Unemployment — The Borderline Result

p = 0.062 with Cohen's d ≈ 0.60 (medium effect). This is almost certainly a **Type II error** — with only 47 states, the test has limited power to detect moderate group differences. A sample of 200+ states (if they existed) would almost certainly produce a significant result given the effect size.

**What to say in an interview:** "The result was borderline — p = 0.062. I'd interpret this as a power limitation rather than absence of effect. The effect size is medium (d = 0.60) and the directional hypothesis (high youth unemployment → more crime) is theoretically well-supported. With a larger dataset this would likely reach significance."

---

## Limitations

1. **n = 47** — all 50 states minus three with missing data. Small for regression — results should be interpreted cautiously
2. **Observational data** — correlational only. No causal claims
3. **Ecological fallacy risk** — these are state-level aggregates. Individual-level relationships may differ substantially
4. **No time-series control** — the 10-year comparison cannot control for national trends affecting all states simultaneously
5. **Missing variables** — urbanisation (the key confound identified here) is not directly measured; it's inferred from proxies like wage and state size

---

## What Would Strengthen This Analysis

1. **Direct urbanisation measure** — % urban population would allow the confound to be controlled directly
2. **Multilevel modelling** — accounting for the nested structure (counties within states)
3. **Fixed effects panel regression** — using the two-timepoint structure properly as a panel dataset to control for time-invariant state characteristics
4. **More timepoints** — a proper time-series would allow trend analysis and causal inference approaches like difference-in-differences
