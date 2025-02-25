# create logger ----
results_folder <- here("Results", cdmName(cdm))
if (!file.exists(results_folder)) {
  dir.create(results_folder, recursive = TRUE)
}
results <- list()
logger_name <- gsub(":| |-", "_", paste0("log_01_001_", Sys.time(), ".txt"))
logger <- create.logger()
logfile(logger) <- here(results_folder, logger_name)
level(logger) <- "INFO"
info(logger, "LOG CREATED")

# CDM manipulations -----
# drop anyone missing sex or year of birth
cdm$person <- cdm$person |>
  filter(
    !is.na(gender_concept_id),
    !is.na(year_of_birth)
  )

# Shared study parameters  ----
study_period <- c(as.Date(study_start), as.Date(NA))

# Create and export snapshot and obs period summary -----
info(logger, "RETRIEVING SNAPSHOT")
cli::cli_text("- GETTING CDM SNAPSHOT ({Sys.time()})")
results[["snap"]] <- summariseOmopSnapshot(cdm)
info(logger, "SNAPSHOT COMPLETED")

info(logger, "RETRIEVING OBSERVATION PERIOD SUMMARY")
cli::cli_text("- GETTING OBSERVATION PERIOD SUMMARY ({Sys.time()})")
results[["obs_period"]] <- summariseObservationPeriod(cdm$observation_period)
info(logger, "OBSERVATION PERIOD SUMMARY COMPLETED")

# Get top ten antibiotics: ingredient level -----
info(logger, "GETTING TOP TEN INGREDIENTS")
source(here("Cohorts", "TopTenIngredients.R"))
info(logger, "GOT TOP TEN INGREDIENTS")

# Get top ten antibiotics: watch list -----
if (run_watch_list) {
  info(logger, "GETTING TOP TEN WATCH LIST ANTIBIOTICS")
  source(here("Cohorts", "TopTenWatchList.R"))
  info(logger, "GOT TOP TEN WATCH LIST ANTIBIOTICS")
}

# Create cohorts -----
info(logger, "INSTANTIATING STUDY COHORTS")
source(here("Cohorts", "InstantiateCohorts.R"))
info(logger, "STUDY COHORTS INSTANTIATED")
# cohorts created:
# denominator for incidence analysis
# top_ten_outcomes - to be used for incidence
# top_ten - to be used for characteristation and drug utilisation


# Drug exposure diagnostics -----
if (run_drug_exposure_diagnostics == TRUE) {
  info(logger, "RUNNING DRUG EXPOSURE DIAGNOSTICS")
  source(here("Analyses", "drug_exposure_diagnostics.R"))
  info(logger, "GOT DRUG EXPOSURE DIAGNOSTICS")
}

# Study analyses ----
source(here("Analyses", "functions.R"))
if (run_drug_utilisation == TRUE) {
  info(logger, "RUN DRUG UTILISATION")
  source(here("Analyses", "drug_utilisation.R"))
  info(logger, "DRUG UTILISATION FINISHED")
}
if (run_characterisation == TRUE) {
  info(logger, "RUN CHARACTERISTICS")
  source(here("Analyses", "characteristics.R"))
  info(logger, "CHARACTERISTICS FINISHED")
}
if (run_incidence == TRUE) {
  info(logger, "RUN INCIDENCE")
  source(here("Analyses", "incidence.R"))
  info(logger, "INCIDENCE FINISHED")
}
info(logger, "ANALYSES FINISHED")

# Export results ----
info(logger, "EXPORTING RESULTS")
result <- omopgenerics::bind(results)
omopgenerics::exportSummarisedResult(result,
  minCellCount = min_cell_count,
  path = results_folder,
  fileName = "results.csv"
)
info(logger, "RESULTS EXPORTED")
