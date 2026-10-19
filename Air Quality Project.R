# ==========================================================================
# Air Quality Project : base R "airquality" dataset
# NY daily air quality measurements, May-Sep 1973 (n = 153, 6 variables)
# ==========================================================================
data(airquality)
str(airquality)
summary(airquality)
# --------------------------------------------------------------------------
# Q1: Identify missing values in Ozone and Solar.R
# --------------------------------------------------------------------------
colSums(is.na(airquality))
sum(is.na(airquality$Ozone))    
# 37 missing (24.2% of 153)
sum(is.na(airquality$Solar.R))  #  7 missing (4.6% of 153)
# We assessed whether missingness in Ozone varied across calender month as an
# explanatory assessment of missingness patterns. This does not establish the
# MCR assumption.
tapply(is.na(airquality$Ozone), airquality$Month, mean)
# --------------------------------------------------------------------------
# Q2: Replace missing values with the column mean (mean imputation) and compare
# distribution visually
# --------------------------------------------------------------------------
aq_imputed <- airquality
ozone_mean <- mean(airquality$Ozone, na.rm = TRUE)
solar_mean <- mean(airquality$Solar.R, na.rm = TRUE)
aq_imputed$Ozone[is.na(aq_imputed$Ozone)] <- ozone_mean
aq_imputed$Solar.R[is.na(aq_imputed$Solar.R)] <- solar_mean
ozone_mean; solar_mean
# Diagnostic: imputation shrinks variance and attenuates correlations
sd(airquality$Ozone, na.rm = TRUE); sd(aq_imputed$Ozone)
cor(airquality$Ozone, airquality$Wind, use = "complete.obs")   # raw
cor(aq_imputed$Ozone, aq_imputed$Wind)                          
# after imputation
# compare distribution visuaaly
hist(airquality$Ozone,
     main = "Observed Ozone",
     xlab = "Ozone (ppb)")
hist(aq_imputed$Ozone,
     main = "Mean Imputed Ozone",
     xlab = "Ozone (ppb)")
# --------------------------------------------------------------------------
# Q3: Average temperature for each month
# --------------------------------------------------------------------------
month_temp <- aggregate(Temp ~ Month, data = airquality, FUN = mean)
month_temp$Temp <- round(month_temp$Temp, 2)
print(month_temp)
# --------------------------------------------------------------------------
# Q4: Plot temperature trends across months
# --------------------------------------------------------------------------
boxplot(Temp ~ Month, data = airquality,
        names = c("May", "Jun", "Jul", "Aug", "Sep"),
        col = "lightblue",
        xlab = "Month (1973)", 
        ylab = "Temperature (°F)",
        main = "Daily max temperature by Month - New York, 1973")
lines(1:5, month_temp$Temp, type = "o", col = "red", pch = 19, lwd = 2)
legend("bottomright", legend = "Monthly mean", col = "red", pch = 19, lwd = 2, bty = "n")
# --------------------------------------------------------------------------
# Q5: Plot Ozone vs Wind : describe the relationship
# --------------------------------------------------------------------------
plot(airquality$Wind, airquality$Ozone,
     pch = 19, col = "steelblue",
     xlab = "Wind speed (mph)", ylab = "Ozone (ppb)",
     main = "Ozone vs wind speed - New York, 1973")
abline(lm(Ozone ~ Wind, data = airquality), col = "red", lwd = 2)
cor(airquality$Ozone, airquality$Wind, use = "complete.obs")
# r ≈ -0.60 → moderate-to-strong NEGATIVE relationship
# --------------------------------------------------------------------------
# Q6: Correlation matrix : Ozone, Wind, Temp, Solar.R
# --------------------------------------------------------------------------
vars <- airquality[, c("Ozone", "Wind", "Temp", "Solar.R")]
round(cor(vars, use = "pairwise.complete.obs"), 3)
# Temp (r ≈ 0.70) and Wind (r ≈ -0.60) correlate most strongly with Ozone;
# Solar.R is weaker (r ≈ 0.35)
# --------------------------------------------------------------------------
# Q7: Fit a model predicting Ozone using Wind and Temp
# --------------------------------------------------------------------------
model <- lm(Ozone ~ Wind + Temp, data = airquality)
summary(model)
confint(model)
# Diagnostics : check assumptions before trusting the coefficients
par(mfrow = c(2, 2))
plot(model)
par(mfrow = c(1, 1))
# --------------------------------------------------------------------------
# Q8: Identify the hottest day recorded
# --------------------------------------------------------------------------
airquality[which.max(airquality$Temp), ]
# Month 8 (August), Day 28 → Temp = 97°
