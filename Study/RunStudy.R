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

maxObsEnd <- cdm$observation_period |>
  summarise(maxObsEnd = max(observation_period_end_date, na.rm = TRUE)) |>
  dplyr::pull()

# CDM manipulations -----
# drop anyone missing sex or year of birth

if(isTRUE(restrict_to_inpatient) & isFALSE(restrict_to_paediatric)){
cdm <- OmopConstructor::generateObservationPeriod(
  cdm,
  collapseEra = 545,
  persistenceWindow = 545,
  censorDate = as.Date(maxObsEnd),
  censorAge = 150L,
  recordsFrom = c("visit_occurrence", "condition_occurrence", "drug_exposure")
)
} else if(isTRUE(restrict_to_inpatient) & isTRUE(restrict_to_paediatric)){
  cdm <- OmopConstructor::generateObservationPeriod(
    cdm,
    collapseEra = 545,
    persistenceWindow = 545,
    censorDate = as.Date(maxObsEnd),
    censorAge = 18L,
    recordsFrom = c("visit_occurrence", "condition_occurrence", "drug_exposure")
  )
}

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
info(logger, "GETTING CODELISTS")
source(here("Cohorts", "GenerateCodelists.R"))
info(logger, "GOT CODELISTS")

# Create cohorts -----
info(logger, "INSTANTIATING STUDY COHORTS")
source(here("Cohorts", "InstantiateCohorts.R"))
info(logger, "STUDY COHORTS INSTANTIATED")
# cohorts created:
# denominator for incidence analysis
# antibiotics from watch list with at least 100 users

if(run_drug_exposure_diagnostics == TRUE){
info(logger, "RUNNING DRUG EXPSURE DIAGNOSTICS")
source(here("Cohorts", "InstantiateCohorts.R"))
info(logger, "FINISHED DRUG EXPSURE DIAGNOSTICS")
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
  fileName = "results_{cdm_name}_{date}.csv"
)
info(logger, "RESULTS EXPORTED")

info(logger, "STUDY CODE FINISHED")

cli::cli_alert_success("Study finished - Thank you for running the study")
