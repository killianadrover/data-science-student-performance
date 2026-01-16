# ------------------------------------------------------------
# 03_first_model.R
# First OLS model
# ------------------------------------------------------------

source("code/00_setup.R")

# Load cleaned dataset
data <- readRDS(file.path(PATH_PROCESSED, "students_clean.rds"))

# Ensure categorical variables are factors (safe even if already factors)
data <- data %>%
  mutate(
    parental_level_of_education = as.factor(parental_level_of_education),
    lunch = as.factor(lunch),
    test_preparation_course = as.factor(test_preparation_course)
  )

# Optional: set reference levels if they exist (makes interpretation clearer)
if ("free/reduced" %in% levels(data$lunch)) {
  data$lunch <- relevel(data$lunch, ref = "free/reduced")
}
if ("none" %in% levels(data$test_preparation_course)) {
  data$test_preparation_course <- relevel(data$test_preparation_course, ref = "none")
}

# Fit first OLS model
m1 <- lm(
  math_score ~ reading_score + writing_score +
    parental_level_of_education + lunch + test_preparation_course,
  data = data
)

# Save coefficients table (clean + easy to reuse in report)
m1_tidy <- broom::tidy(m1) %>%
  mutate(
    estimate = round(estimate, 4),
    std.error = round(std.error, 4),
    statistic = round(statistic, 4),
    p.value = round(p.value, 4)
  )

write_csv(m1_tidy, file.path(PATH_TAB, "first_model_results.csv"))

# Save model-level statistics (R2, adj.R2, etc.)
m1_glance <- broom::glance(m1) %>%
  mutate(across(where(is.numeric), ~ round(.x, 4)))

write_csv(m1_glance, file.path(PATH_TAB, "first_model_fit.csv"))

# Save full summary as a text file (keeps all info: F-test, residual SE, etc.)
sink(file.path(PATH_TAB, "first_model_summary.txt"))
print(summary(m1))
sink()
