# ------------------------------------------------------------
# 05_final_model.R
# Final model (with simple corrections + sensitivity checks)
# ------------------------------------------------------------

source("code/00_setup.R")

# Load cleaned dataset
data <- readRDS(file.path(PATH_PROCESSED, "students_clean.rds"))

# Ensure factors (safe)
data <- data %>%
  mutate(
    parental_level_of_education = as.factor(parental_level_of_education),
    lunch = as.factor(lunch),
    test_preparation_course = as.factor(test_preparation_course)
  )

# Reference levels (optional but clearer)
if ("free/reduced" %in% levels(data$lunch)) {
  data$lunch <- relevel(data$lunch, ref = "free/reduced")
}
if ("none" %in% levels(data$test_preparation_course)) {
  data$test_preparation_course <- relevel(data$test_preparation_course, ref = "none")
}

# ----------------------------
# 1) Baseline model (same as Model 1)
# ----------------------------
m1 <- lm(
  math_score ~ reading_score + writing_score +
    parental_level_of_education + lunch + test_preparation_course,
  data = data
)

# ----------------------------
# 2) Quadratic terms (functional form check)
# ----------------------------
m_quad <- lm(
  math_score ~ reading_score + I(reading_score^2) +
    writing_score + I(writing_score^2) +
    parental_level_of_education + lunch + test_preparation_course,
  data = data
)

# Compare nested models (ANOVA)
anova_comp <- anova(m1, m_quad)
anova_df <- as.data.frame(anova_comp)
write_csv(anova_df, file.path(PATH_TAB, "anova_m1_vs_mquad.csv"))

# Extract p-value of the comparison (2nd row)
p_anova <- anova_comp$`Pr(>F)`[2]

# Choose final model based on the comparison
# Rule: if quadratic terms significantly improve fit (p < 0.05), keep m_quad
final_model <- if (!is.na(p_anova) && p_anova < 0.05) m_quad else m1
final_model_name <- if (!is.na(p_anova) && p_anova < 0.05) "m_quad" else "m1"

# ----------------------------
# 3) Sensitivity: remove influential points (Cook's D > 4/n)
# ----------------------------
n <- nrow(data)
cooks <- cooks.distance(m1)
threshold <- 4 / n
idx_infl <- which(cooks > threshold)

data_trim <- data
if (length(idx_infl) > 0) {
  data_trim <- data[-idx_infl, ]
}

m_trim <- lm(
  math_score ~ reading_score + writing_score +
    parental_level_of_education + lunch + test_preparation_course,
  data = data_trim
)

# Save influential points info
infl_df <- data.frame(
  threshold = threshold,
  n_influential = length(idx_infl)
)
write_csv(infl_df, file.path(PATH_TAB, "influential_points_summary.csv"))

# ----------------------------
# 4) Export results (final + sensitivity)
# ----------------------------

# Final model coefficients
final_tidy <- broom::tidy(final_model) %>%
  mutate(
    estimate = round(estimate, 4),
    std.error = round(std.error, 4),
    statistic = round(statistic, 4),
    p.value = round(p.value, 4)
  )

write_csv(final_tidy, file.path(PATH_TAB, "final_model_results.csv"))

# Final model fit stats
final_glance <- broom::glance(final_model) %>%
  mutate(across(where(is.numeric), ~ round(.x, 4))) %>%
  mutate(model = final_model_name)

write_csv(final_glance, file.path(PATH_TAB, "final_model_fit.csv"))

# Sensitivity model coefficients
trim_tidy <- broom::tidy(m_trim) %>%
  mutate(
    estimate = round(estimate, 4),
    std.error = round(std.error, 4),
    statistic = round(statistic, 4),
    p.value = round(p.value, 4)
  )

write_csv(trim_tidy, file.path(PATH_TAB, "sensitivity_model_results.csv"))

# Sensitivity model fit stats
trim_glance <- broom::glance(m_trim) %>%
  mutate(across(where(is.numeric), ~ round(.x, 4))) %>%
  mutate(model = "m_trim")

write_csv(trim_glance, file.path(PATH_TAB, "sensitivity_model_fit.csv"))

# Save full summaries as text (keeps extra stats)
sink(file.path(PATH_TAB, "final_model_summary.txt"))
cat("=== Final model selected ===\n")
cat("final_model =", final_model_name, "\n")
cat("anova p-value (m1 vs m_quad) =", p_anova, "\n\n")

cat("=== Summary: m1 ===\n")
print(summary(m1))
cat("\n=== Summary: m_quad ===\n")
print(summary(m_quad))
cat("\n=== Summary: m_trim (without influential points) ===\n")
print(summary(m_trim))
sink()
