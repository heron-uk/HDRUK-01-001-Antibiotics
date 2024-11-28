# instantiate cancer cohorts
cli::cli_alert_info("- Getting watch list antibiotics")

# get concept sets from cohorts----

codes <- codesFromConceptSet(here::here("Cohorts", "WatchList"), cdm)

# instantiate the cohorts with no prior history 

cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = codes, name = "watch_list") |>
  requireInDateRange(indexDate = "cohort_start_date",
                     dateRange = studyPeriod)

cli::cli_alert_success("- Got watch list antibiotics")

cli::cli_alert_info("- Getting top ten antibiotics")

count_settings <- merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
  arrange(desc(number_records)) %>%
  slice_head(n = 10)

top_ten <- sub("_.*", "", count_settings$cohort_name)

json_dir <- "Cohorts/WatchList"

# List all JSON files in the directory
json_files <- list.files(json_dir, pattern = "\\.json$", full.names = TRUE)

pattern <- paste0("\\b(", paste(top_ten, collapse = "|"), ")\\b")

file_names <- basename(json_files)
filtered_indices <- grep(pattern, file_names, ignore.case = TRUE)
filtered_files <- json_files[filtered_indices]

output_dir <- "Cohorts/TopTen"

if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# List all files in the output directory
existing_files <- list.files(output_dir, full.names = TRUE)

# Ask the user if they want to overwrite all existing files
if (length(existing_files) > 0) {
  cat("The following files already exist in the output directory (top 10 most used antibiotics):\n")
  print(basename(existing_files))
  
  # Ask the user for confirmation to overwrite
  overwrite <- readline("Do you want to overwrite all existing files? (y/n): ")
  
  if (tolower(overwrite) == "n") {
    # Abort the operation if the user says no
    cat("Operation aborted. No files have been replaced.\n")
  } else if (tolower(overwrite) == "y") {
    # Delete existing files if user confirms
    file.remove(existing_files)
    cat("All existing files have been deleted.\n")
    
    # Copy the new files to the output directory
    file.copy(filtered_files, file.path(output_dir, basename(filtered_files)))
    cat("New files have been copied to the output directory.\n")
  } else {
    cat("Invalid input. Please answer 'y' or 'n'.\n")
  }
} else {
  # If no files exist in the directory, just copy the new files
  file.copy(filtered_files, file.path(output_dir, basename(filtered_files)))
  cat("All files have been copied to the output directory.\n")
}

codes_ten <- codesFromConceptSet(here::here("Cohorts", "TopTen"), cdm)

codes_routes <- stratifyByRouteCategory(codes_ten, cdm, keepOriginal = FALSE)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten",
  conceptSet = codes_ten
)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten_routes",
  conceptSet = codes_routes
)

cdm$top_ten <- cdm$top_ten |>
  requireDrugInDateRange(
    dateRange = studyPeriod)

cdm$top_ten_routes <- cdm$top_ten_routes |>
  requireDrugInDateRange(
    dateRange = studyPeriod)

cli::cli_alert_success("- Got top ten antibiotics")