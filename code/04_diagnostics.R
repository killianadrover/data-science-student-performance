# ------------------------------------------------------------
# 04_diagnostics.R
# OLS diagnostics: correlation, linearity, normality, VIF, outliers
# ------------------------------------------------------------

source("code/00_setup.R")

# Load cleaned dataset
data <- readRDS(file.path(PATH_PROCESSED, "students_clean.rds"))

# Ensure factors (safe even if already factors)
data <- data %>%
  mutate(
    parental_level_of_education = as.factor(parental_level_of_education),
    lunch = as.factor(lunch),
    test_preparation_course = as.factor(test_preparation_course)
  )

# Set reference levels (optional but clearer)
if ("free/reduced" %in% levels(data$lunch)) {
  data$lunch <- relevel(data$lunch, ref = "free/reduced")
}
if ("none" %in% levels(data$test_preparation_course)) {
  data$test_preparation_course <- relevel(data$test_preparation_course, ref = "none")
}

# Fit the same first model (self-contained script)
m1 <- lm(
  math_score ~ reading_score + writing_score +
    parental_level_of_education + lunch + test_preparation_course,
  data = data
)

# ----------------------------
# 1) Correlation (quant variables)
# ----------------------------
quant_df <- data %>%
  select(math_score, reading_score, writing_score)

corr_mat <- cor(quant_df, use = "complete.obs")
write_csv(as.data.frame(corr_mat), file.path(PATH_TAB, "correlation_matrix.csv"))

# Optional: correlation heatmap-like plot (simple)
corr_long <- as.data.frame(as.table(corr_mat))
colnames(corr_long) <- c("Var1", "Var2", "Correlation")

p_corr <- ggplot(corr_long, aes(x = Var1, y = Var2, fill = Correlation)) +
  geom_tile() +
  theme_minimal() +
  labs(title = "Correlation matrix (quantitative variables)", x = "", y = "")

ggsave("correlation_matrix.png", p_corr, path = PATH_FIG, width = 6, height = 5)

# ----------------------------
# 2) Linearity checks
# ----------------------------

# Scatterplots with linear fit (math vs each quantitative predictor)
p_sc_read <- ggplot(data, aes(x = reading_score, y = math_score)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  labs(title = "math_score vs reading_score", x = "reading_score", y = "math_score")

ggsave("scatter_math_reading.png", p_sc_read, path = PATH_FIG, width = 6, height = 4)

p_sc_write <- ggplot(data, aes(x = writing_score, y = math_score)) +
  geom_point(alpha = 0.6) +
  geom_smooth(method = "lm", se = FALSE) +
  theme_minimal() +
  labs(title = "math_score vs writing_score", x = "writing_score", y = "math_score")

ggsave("scatter_math_writing.png", p_sc_write, path = PATH_FIG, width = 6, height = 4)

# Residuals vs fitted
diag_df <- data.frame(
  fitted = fitted(m1),
  resid  = resid(m1)
)

p_rvf <- ggplot(diag_df, aes(x = fitted, y = resid)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  theme_minimal() +
  labs(title = "Residuals vs Fitted (Model 1)", x = "Fitted values", y = "Residuals")

ggsave("residuals_vs_fitted_m1.png", p_rvf, path = PATH_FIG, width = 6, height = 4)

# ----------------------------
# 3) Normality checks (residuals)
# ----------------------------

resid_m1 <- resid(m1)

# Histogram of residuals
p_hist_res <- ggplot(data.frame(resid = resid_m1), aes(x = resid)) +
  geom_histogram(bins = 25) +
  theme_minimal() +
  labs(title = "Residuals histogram (Model 1)", x = "Residuals", y = "Frequency")

ggsave("hist_residuals_m1.png", p_hist_res, path = PATH_FIG, width = 6, height = 4)

# QQ plot (normality)
qq_df <- data.frame(sample = resid_m1)
p_qq <- ggplot(qq_df, aes(sample = sample)) +
  stat_qq() +
  stat_qq_line() +
  theme_minimal() +
  labs(title = "QQ plot of residuals (Model 1)")

ggsave("qqplot_residuals_m1.png", p_qq, path = PATH_FIG, width = 6, height = 4)

# Residual skewness & kurtosis
resid_stats <- data.frame(
  Metric = c("Skewness", "Kurtosis"),
  Value  = c(moments::skewness(resid_m1), moments::kurtosis(resid_m1))
)

write_csv(resid_stats, file.path(PATH_TAB, "residuals_skew_kurt_m1.csv"))
# ----------------------------
# 4) Multicollinearity (VIF)
# ----------------------------

vif_values <- car::vif(m1)

# car::vif() returns:
# - a numeric vector (no factors)
# - OR a matrix with GVIF, Df, GVIF^(1/(2*Df)) (with factors)
if (is.matrix(vif_values)) {

  vif_df <- data.frame(
    Term = rownames(vif_values),
    GVIF = vif_values[, "GVIF"],
    Df   = vif_values[, "Df"],
    GVIF_adj = vif_values[, "GVIF^(1/(2*Df))"]
  )

} else {

  vif_df <- data.frame(
    Term = names(vif_values),
    VIF  = as.numeric(vif_values)
  )

}

write_csv(vif_df, file.path(PATH_TAB, "vif_m1.csv"))

# ----------------------------
# 5) Omitted variables (simple functional form check)
# ----------------------------

# Add quadratic terms for quantitative predictors (functional form check)
m1_quad <- lm(
  math_score ~ reading_score + I(reading_score^2) +
    writing_score + I(writing_score^2) +
    parental_level_of_education + lunch + test_preparation_course,
  data = data
)

# Compare models (nested comparison)
anova_comp <- anova(m1, m1_quad)
anova_df <- as.data.frame(anova_comp)
write_csv(anova_df, file.path(PATH_TAB, "anova_m1_vs_m1_quad.csv"))

# ----------------------------
# 6) Outliers / influential observations
# ----------------------------

n <- nrow(data)

# Cook's distance
cooks <- cooks.distance(m1)

# Common rule of thumb: Cook's D > 4/n
threshold <- 4 / n

influential_idx <- which(cooks > threshold)

infl_df <- data.frame(
  index = influential_idx,
  cooks_distance = cooks[influential_idx],
  threshold = threshold
)

write_csv(infl_df, file.path(PATH_TAB, "influential_points_cooks_m1.csv"))

# Cook's distance plot
cooks_df <- data.frame(index = 1:n, cooks = cooks)

p_cooks <- ggplot(cooks_df, aes(x = index, y = cooks)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = threshold, linetype = "dashed") +
  theme_minimal() +
  labs(title = "Cook's distance (Model 1)", x = "Observation index", y = "Cook's distance")

ggsave("cooks_distance_m1.png", p_cooks, path = PATH_FIG, width = 6, height = 4)

# Studentized residuals (helps detect outliers in y-direction)
stud_res <- rstudent(m1)
stud_df <- data.frame(index = 1:n, stud_resid = stud_res)

write_csv(stud_df, file.path(PATH_TAB, "studentized_residuals_m1.csv"))

p_stud <- ggplot(stud_df, aes(x = index, y = stud_resid)) +
  geom_point(alpha = 0.6) +
  geom_hline(yintercept = c(-2, 0, 2), linetype = "dashed") +
  theme_minimal() +
  labs(title = "Studentized residuals (Model 1)", x = "Observation index", y = "Studentized residual")

ggsave("studentized_residuals_m1.png", p_stud, path = PATH_FIG, width = 6, height = 4)

# Save full diagnostics summary as text
sink(file.path(PATH_TAB, "diagnostics_m1_summary.txt"))
cat("=== Model 1 summary ===\n")
print(summary(m1))
cat("\n=== Model comparison (m1 vs m1_quad) ===\n")
print(anova(m1, m1_quad))
cat("\n=== Cook's distance threshold ===\n")
cat("threshold =", threshold, "\n")
cat("influential points (Cook's D > threshold):", length(influential_idx), "\n")
sink()
