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

nrow(df)