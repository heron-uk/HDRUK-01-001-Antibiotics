# create logger ----
resultsFolder <- here("Results", db_name)
if (!file.exists(resultsFolder)){
  dir.create(resultsFolder, recursive = TRUE)}
results <- list()
loggerName <- gsub(":| |-", "_", paste0("log_01_001_", Sys.time(), ".txt"))
logger <- create.logger()
logfile(logger) <- here(resultsFolder, loggerName)
level(logger) <- "INFO"
info(logger, "LOG CREATED")

# start ----

start_time <- Sys.time()
maxObsEnd <- cdm$observation_period |>
  summarise(maxObsEnd = max(observation_period_end_date, na.rm = TRUE)) |>
  dplyr::pull()
studyPeriod <- c(as.Date(study_start), as.Date(maxObsEnd))

# create and export snapshot
if (run_cdm_snapshot == TRUE) {
  info(logger, "RETRIEVING SNAPSHOT")
  cli::cli_text("- GETTING CDM SNAPSHOT ({Sys.time()})")
  results[["snap"]] <- OmopSketch::summariseOmopSnapshot(cdm)
  info(logger, "SNAPSHOT COMPLETED")
}

#get top ten antibiotics
info(logger, "GETTING TOP TEN INGREDIENTS")
source(here("Cohorts", "TopTenIngredients.R"))
info(logger, "GOT TOP TEN INGREDIENTS")

info(logger, "GETTING TOP TEN WATCH LIST ANTIBIOTICS")
source(here("Cohorts", "TopTenWatchList.R"))
info(logger, "GOT TOP TEN WATCH LIST ANTIBIOTICS")

info(logger, "INSTANTIATING STUDY COHORTS")
source(here("Cohorts", "InstantiateCohorts.R"))
info(logger, "STUDY COHORTS INSTANTIATED")

if(run_drug_exposure_diagnostics == TRUE) {
info(logger, "RUNNING DRUG EXPOSURE DIAGNOSTICS")
source(here("Analyses", "drug_exposure_diagnostics.R"))
info(logger, "GOT DRUG EXPOSURE DIAGNOSTICS")
}

# run analyses ----
source(here("Analyses", "functions.R"))
if(run_drug_utilisation == TRUE){
info(logger, "RUN DRUG UTILISATION")
source(here("Analyses", "drug_utilisation.R"))
info(logger, "DRUG UTILISATION FINISHED")
}
if(run_characterisation == TRUE){
info(logger, "RUN CHARACTERISTICS")
source(here("Analyses", "characteristics.R"))
info(logger, "CHARACTERISTICS FINISHED")
}
if(run_incidence == TRUE){
info(logger, "RUN INCIDENCE")
source(here("Analyses", "incidence.R"))
info(logger, "INCIDENCE FINISHED")
}
info(logger, "ANALYSES FINISHED")

# export results ----

info(logger, "EXPORTING RESULTS")

result <- omopgenerics::bind(results)
omopgenerics::exportSummarisedResult(result, minCellCount = min_cell_count, path = resultsFolder, fileName = "results.csv")

info(logger, "RESULTS EXPORTED")