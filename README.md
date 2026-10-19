# Air Quality Analysis in R: New York, May–September 1973

A class project in exploratory data analysis and linear regression using R's built-in `airquality` dataset. It covers missing-data handling, descriptive statistics, visualisation, correlation analysis, and a multiple linear regression predicting ground-level ozone from wind speed and temperature.

**Author:** Ezra Komen Kipyegon, BSc Biostatistics, Jomo Kenyatta University of Agriculture and Technology (JKUAT)

---

## 1. Objective

To describe the structure and quality of the New York air quality data, and to quantify how ozone concentration is associated with wind speed, temperature, and solar radiation.

This is an **observational** dataset. All results below are **associations**, not causal effects.

## 2. Data

Base R dataset `airquality` (`data(airquality)`): 153 daily observations, 6 variables.

| Variable | Description | Units |
|---|---|---|
| `Ozone` | Mean ozone, 13:00–15:00, Roosevelt Island | ppb |
| `Solar.R` | Solar radiation, 08:00–12:00, Central Park | Langleys |
| `Wind` | Average wind speed, 07:00 and 10:00, LaGuardia Airport | mph |
| `Temp` | Maximum daily temperature, LaGuardia Airport | °F |
| `Month` | Month of observation (5–9) | – |
| `Day` | Day of month | – |

Ozone and the weather variables were measured at different sites, so there is some measurement mismatch built into the data. See `?airquality` in R for full documentation.

## 3. Project questions

1. Identify missing values in `Ozone` and `Solar.R`.
2. Replace missing values with the column mean.
3. Calculate the average temperature for each month.
4. Plot temperature trends across months.
5. Plot Ozone vs Wind and describe the relationship.
6. Compute correlations among Ozone, Wind, Temp, and Solar.R. Which variables correlate most with Ozone?
7. Fit a model predicting Ozone from Wind and Temp and interpret the coefficients.
8. Identify the hottest day recorded.

## 4. Repository structure

```
.
├── README.md
├── airquality_analysis.R      # full reproducible script (Q1–Q8)
└── figures/
    ├── temp_by_month.png      # created by running the script
    └── ozone_vs_wind.png      # created by running the script
```

## 5. How to run

Requires R (≥ 4.0). No extra packages are needed; everything uses base R.

```r
source("airquality_analysis.R")
```

Or open the script in RStudio and run it section by section. The script creates the `figures/` folder and saves both plots.

## 6. Methods

- **Missingness:** counted with `is.na()`; Ozone missingness was also tabulated by month as a quick check on whether it is spread evenly.
- **Imputation:** mean imputation, as the assignment required. Its side effects were checked (see Results and Limitations).
- **Monthly temperature:** `aggregate(Temp ~ Month, FUN = mean)`.
- **Correlation:** Pearson correlation with `use = "pairwise.complete.obs"`, so each pair uses all rows available for that pair.
- **Model:** ordinary least squares, `lm(Ozone ~ Wind + Temp)`. `lm()` drops rows with missing values by default, so the model is fitted on the original data (n = 116), not the mean-imputed copy.

## 7. Results

### Missing data

| Variable | Missing | % of 153 |
|---|---|---|
| Ozone | 37 | 24.2% |
| Solar.R | 7 | 4.6% |

Column means used for imputation: Ozone = 42.13 ppb, Solar.R = 185.93 Langleys.

### Mean temperature by month

| Month | Mean Temp (°F) |
|---|---|
| May | 65.55 |
| June | 79.10 |
| July | 83.90 |
| August | 83.97 |
| September | 76.90 |

Temperature rises sharply from May to June, plateaus in July–August, and falls in September.

### Ozone vs Wind

The relationship is **negative** (r = −0.60): calmer days tend to have higher ozone. This fits the physical picture of ozone accumulating in stagnant air and being dispersed by wind.

### Correlation matrix (pairwise-complete)

| | Ozone | Wind | Temp | Solar.R |
|---|---|---|---|---|
| **Ozone** | 1.000 | −0.602 | 0.698 | 0.348 |
| **Wind** | −0.602 | 1.000 | −0.458 | −0.057 |
| **Temp** | 0.698 | −0.458 | 1.000 | 0.276 |
| **Solar.R** | 0.348 | −0.057 | 0.276 | 1.000 |

Temperature (r = 0.70) and wind (r = −0.60) correlate most strongly with ozone. Solar radiation is weaker (r = 0.35).

### Regression: `Ozone ~ Wind + Temp` (n = 116)

| Term | Estimate | Std. Error | p-value |
|---|---|---|---|
| Intercept | −71.03 | 23.58 | 0.003 |
| Wind | −3.055 | 0.663 | < 0.001 |
| Temp | 1.840 | 0.250 | < 0.001 |

R² = 0.569, adjusted R² = 0.561, residual SE = 21.85 on 113 df.

- Holding temperature constant, each additional 1 mph of wind is associated with about **3.1 ppb lower** ozone on average.
- Holding wind constant, each additional 1 °F is associated with about **1.8 ppb higher** ozone on average.
- The model explains roughly 57% of the variation in ozone; the rest is unexplained by these two predictors.

### Hottest day

**28 August 1973**, 97 °F (Ozone = 76 ppb, Wind = 9.7 mph, Solar.R = 203).

## 8. Limitations

- **Association, not causation.** Wind, temperature, and ozone are all driven by broader atmospheric conditions (pressure systems, humidity, emissions) that are not in the data.
- **Mean imputation distorts the data.** It keeps the mean but shrinks the variance and weakens correlations: Ozone–Wind moves from −0.602 to −0.531 and Ozone–Temp from 0.698 to 0.609 after imputation. With 24% of Ozone missing, this matters. Multiple imputation (e.g. `mice`) is the standard alternative.
- **Missingness mechanism unknown.** Mean imputation is only defensible if values are missing completely at random, which was not established.
- **Skewed outcome.** Ozone is right-skewed (skewness ≈ 1.24), so residual variance is expected to grow with fitted values. Modelling `log(Ozone)` gives a slightly higher R² (≈ 0.58) and is the more common choice in practice.
- **Temporal structure.** The data are daily and time-ordered, so the independence assumption deserves a check. An approximate Durbin–Watson statistic on the residuals was close to 2 (≈ 1.9), but rows dropped for missing Ozone leave gaps, so this is a rough check rather than a formal test.
- **Single season, single city.** Results should not be generalised beyond New York in summer 1973.

## 9. Possible extensions

- Refit the Q7 model on the mean-imputed data and compare coefficients with the complete-case fit.
- Replace mean imputation with multiple imputation (`mice`) and pool estimates.
- Fit `log(Ozone)` and add `Solar.R` and a `Wind × Temp` interaction; compare with AIC and cross-validation.
- Model the time structure explicitly (GLS with AR(1) errors or a GAM with a smooth term for day of year).

## 10. Reference

Chambers, J. M., Cleveland, W. S., Kleiner, B., & Tukey, P. A. (1983). *Graphical Methods for Data Analysis*. Wadsworth & Brooks/Cole.

Data: New York State Department of Conservation (ozone) and the National Weather Service (meteorology), as documented in R's `?airquality`.
