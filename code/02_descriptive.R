# ------------------------------------------------------------
# 02_descriptives.R
# Descriptive statistics
# ------------------------------------------------------------

source("code/00_setup.R")

# Load cleaned dataset (saved as .rds for fast/reproducible I/O)
data <- readRDS(file.path(PATH_PROCESSED, "students_clean.rds"))

# ----------------------------
# First 10 rows (for the report screenshot/table)
# ----------------------------
first_10 <- head(data, 10)
write_csv(first_10, file.path(PATH_TAB, "first_10_rows.csv"))

# ----------------------------
# Quantitative variables
# ----------------------------
quant_vars <- data %>%
  select(math_score, reading_score, writing_score)

# Build a compact descriptive table:
# - sapply() applies the same function column-by-column
descriptives_quant <- data.frame(
  Variable = names(quant_vars),

  # Count non-missing values per column (robust even if NA exist)
  N = sapply(quant_vars, function(x) sum(!is.na(x))),

  Mean = sapply(quant_vars, mean),
  Min  = sapply(quant_vars, min),
  Max  = sapply(quant_vars, max),
  SD   = sapply(quant_vars, sd),

  # - skewness measures asymmetry
  # - kurtosis measures tail/heaviness/peakedness
  Skewness = sapply(quant_vars, moments::skewness),
  Kurtosis = sapply(quant_vars, moments::kurtosis)
)

write_csv(descriptives_quant,
          file.path(PATH_TAB, "descriptives_quantitative.csv"))

# ----------------------------
# Qualitative variables
# ----------------------------
qual_vars <- data %>%
  select(parental_level_of_education, lunch, test_preparation_course)

for (var in names(qual_vars)) {

  p <- ggplot(data, aes_string(x = var)) +
    geom_bar(fill = "steelblue") +
    theme_minimal() +
    labs(
      title = paste("Frequency:", var),
      x = var,
      y = "Count"
    )

  # ggsave() writes the last plot (or the plot you pass) to disk.
  # Using PATH_FIG centralizes where figures are stored.
  ggsave(
    filename = paste0("freq_", var, ".png"),
    plot = p,
    path = PATH_FIG,
    width = 6,
    height = 4
  )
}

# ----------------------------
# Histograms
# ----------------------------
for (var in names(quant_vars)) {

  # Same aes_string logic: var is a column name stored as text.
  p <- ggplot(data, aes_string(x = var)) +
    geom_histogram(bins = 20, fill = "darkorange") +
    theme_minimal() +
    labs(
      title = paste("Histogram:", var),
      x = var,
      y = "Frequency"
    )

  ggsave(
    filename = paste0("hist_", var, ".png"),
    plot = p,
    path = PATH_FIG,
    width = 6,
    height = 4
  )
}
