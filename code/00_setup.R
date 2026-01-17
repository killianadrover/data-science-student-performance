# code/00_setup.R
# Global setup: packages, options, reproducibility

options(stringsAsFactors = FALSE)
set.seed(42)

required_packages <- c(
  "readr", "dplyr", "ggplot2", "moments"
)

installed <- rownames(installed.packages())
missing <- setdiff(required_packages, installed)

if (length(missing) > 0) {
  install.packages(missing)
}

invisible(lapply(required_packages, library, character.only = TRUE))

 # ------------------------------------------------------------
# Project paths (used by all scripts)
# ------------------------------------------------------------

PATH_RAW       <- "data/raw"
PATH_PROCESSED <- "data/processed"
PATH_TAB       <- "outputs/tables"
PATH_FIG       <- "outputs/figures"

# Create output folders if missing (safe to run multiple times)
dir.create(PATH_TAB, showWarnings = FALSE, recursive = TRUE)
dir.create(PATH_FIG, showWarnings = FALSE, recursive = TRUE)
