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
