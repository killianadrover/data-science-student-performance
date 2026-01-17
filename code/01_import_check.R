# code/01_import_check.R
source("code/00_setup.R")

data_path <- "data/raw/students.csv"

if (!file.exists(data_path)) {
  stop(
    "Dataset not found: ", data_path, "\n",
    "Download from Kaggle and place it as data/raw/students.csv"
  )
}

df <- readr::read_csv(data_path, show_col_types = FALSE)

# Basic checks
cat("Rows:", nrow(df), "\n")
cat("Cols:", ncol(df), "\n\n")

# Show first 10 rows in console
print(head(df, 10))

# Export first 10 rows as a table (for screenshot / insertion in report)
dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
write.csv(head(df, 10), "outputs/tables/first_10_rows.csv", row.names = FALSE)

cat("\nSaved: outputs/tables/first_10_rows.csv\n")

# ------------------------------------------------------------
# Clean dataset for analysis (keep only variables used)
# ------------------------------------------------------------

df_clean <- df %>%
  rename(
    parental_level_of_education = `parental level of education`,
    test_preparation_course = `test preparation course`,
    math_score = `math score`,
    reading_score = `reading score`,
    writing_score = `writing score`
  ) %>%
  select(
    math_score,
    reading_score,
    writing_score,
    parental_level_of_education,
    lunch,
    test_preparation_course
  ) %>%
  mutate(
    parental_level_of_education = as.factor(parental_level_of_education),
    lunch = as.factor(lunch),
    test_preparation_course = as.factor(test_preparation_course)
  )

# Save cleaned dataset
saveRDS(df_clean, file.path(PATH_PROCESSED, "students_clean.rds"))
cat("Saved:", file.path(PATH_PROCESSED, "students_clean.rds"), "\n")
