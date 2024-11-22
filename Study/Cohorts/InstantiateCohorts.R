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

top_10 <- sub("_.*", "", count_settings$cohort_name)

json_files <- list.files(here::here( "Cohorts", "WatchList"), pattern = "\\.json$", full.names = TRUE)

file_names <- basename(json_files)

pattern <- paste0("\\b(", paste(top_10, collapse = "|"), ")\\b")

filtered_indices <- grep(pattern, file_names, ignore.case = TRUE)
filtered_files <- json_files[filtered_indices]

output_dir <- here::here("Cohorts", "TopTen")

# Create the directory if it doesn't already exist
if (!dir.exists(output_dir)) {
  dir.create(output_dir)
}

# Check if any files in the filtered_files list already exist in the output directory
existing_files <- file.path(output_dir, basename(filtered_files))
conflicting_files <- existing_files[file.exists(existing_files)]

if (length(conflicting_files) > 0) {
  cat("The following files already exist in the 'top 10' output directory:\n")
  print(basename(conflicting_files))
  
  overwrite <- readline("Do you want to overwrite these files? (y/n): ")
  
  if (tolower(overwrite) == "y") {
    file.copy(filtered_files, file.path(output_dir, basename(filtered_files)), overwrite = TRUE)
    cat("Files have been replaced.\n")
  } else {
    non_conflicting_files <- setdiff(filtered_files, conflicting_files)
    file.copy(non_conflicting_files, file.path(output_dir, basename(non_conflicting_files)))
    cat("Non-conflicting files have been copied. Conflicting files were skipped.\n")
  }
} else {
  # No conflicts, proceed with copying
  file.copy(filtered_files, file.path(output_dir, basename(filtered_files)))
  cat("All files have been copied to the output directory.\n")
}

codes_ten <- codesFromConceptSet(here::here("Cohorts", "TopTen"), cdm)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten",
  conceptSet = codes_ten
)

cdm$top_ten <- cdm$top_ten |>
  requireDrugInDateRange(
    dateRange = studyPeriod)

cli::cli_alert_success("- Got top ten antibiotics")