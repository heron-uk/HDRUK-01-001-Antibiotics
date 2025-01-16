# create logger ----
resultsFolder <- here("Results")
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
  write.csv(OmopSketch::summariseOmopSnapshot(cdm), here("Results", paste0(
    "cdm_snapshot_", cdmName(cdm), ".csv"
  )))
  info(logger, "SNAPSHOT COMPLETED")
}

#get top ten antibiotics
info(logger, "GETTING TOP TEN ANTIBIOTICS")
source(here("Cohorts", "TopTen.R"))
info(logger, "GOT TOP TEN ANTIBIOTICS")

info(logger, "RUNNING DRUG EXPOSURE DIAGNOSTICS")
source(here("Analyses", "drug_exposure_diagnostics.R"))
info(logger, "GOT DRUG EXPOSURE DIAGNOSTICS")

# instantiate necessary cohorts ----

if(run_main_study == TRUE){
info(logger, "INSTANTIATING STUDY COHORTS")
source(here("Cohorts", "InstantiateCohorts.R"))
info(logger, "STUDY COHORTS INSTANTIATED")

# run analyses ----
info(logger, "RUN ANALYSES")
source(here("Analyses", "functions.R"))
info(logger, "RUN DRUG UTILISATION")
source(here("Analyses", "drug_utilisation.R"))
info(logger, "DRUG UTILISATION FINISHED")
info(logger, "RUN INDICATIONS")
source(here("Analyses", "indications.R"))
info(logger, "INDICATIONS FINISHED")
info(logger, "RUN CHARACTERISTICS")
source(here("Analyses", "characteristics.R"))
info(logger, "CHARACTERISTICS FINISHED")
info(logger, "RUN INCIDENCE")
source(here("Analyses", "incidence.R"))
source(here("Analyses", "age_standardised_incidence.R"))
info(logger, "ANALYSES FINISHED")

# export results ----

info(logger, "EXPORTING RESULTS")

files_to_zip <- list.files(here("Results"))
files_to_zip <- files_to_zip[stringr::str_detect(
  files_to_zip,
  db_name
)]
files_to_zip <- files_to_zip[stringr::str_detect(
  files_to_zip,
  ".csv"
)]

zip::zip(
  zipfile = file.path(paste0(
    here("Results"), "/Results_", db_name, ".zip"
  )),
  files = files_to_zip,
  root = here("Results")
)

result <- omopgenerics::bind(results)
omopgenerics::exportSummarisedResult(result, minCellCount = 5, path = resultsFolder, fileName = paste0(
  "result_", db_name, ".csv"))

info(logger, "RESULTS EXPORTED")
}