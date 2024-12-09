# create logger ----
resultsFolder <- here("Results")
results <- list()
loggerName <- gsub(":| |-", "_", paste0("log_01_001_", Sys.time(),".txt"))
logger <- create.logger()
logfile(logger) <- here(resultsFolder, loggerName)
level(logger) <- "INFO"
info(logger, "LOG CREATED")

# start ----

start_time <- Sys.time()
maxObsEnd <- cdm$observation_period |>
  summarise(maxObsEnd = max(observation_period_end_date, na.rm = TRUE)) |>
  dplyr::pull()
studyPeriod <- c(as.Date("2012-01-01"), as.Date(maxObsEnd))

# create and export snapshot
info(logger, "Retrieving snapshot")
cli::cli_text("- Getting cdm snapshot ({Sys.time()})")
write.csv(OmopSketch::summariseOmopSnapshot(cdm), here("Results", paste0(
  "cdm_snapshot_", cdmName(cdm), ".csv"
)))
results[["snap"]] <- OmopSketch::summariseOmopSnapshot(cdm)
results[["obs_period"]] <- OmopSketch::summariseObservationPeriod(cdm$observation_period)
info(logger, "snapshot completed")

# instantiate necessary cohorts ----
info(logger, "INSTANTIATING STUDY COHORTS")
source(here("Cohorts", "InstantiateCohorts.R"))
info(logger, "STUDY COHORTS INSTANTIATED")

# run analyses ----
info(logger, "RUN ANALYSES")
source(here("Analyses", "initial_dose_duration.R"))
source(here("Analyses", "drug_exposure_diagnostics.R"))
source(here("Analyses", "characteristics.R"))
source(here("Analyses", "incidence.R"))
source(here("Analyses", "age_standardised_incidence.R"))
info(logger, "ANALYSES FINISHED")

# export results ----
info(logger, "CREATING SHINY DASHBOARD")

result <- results |>
  vctrs::list_drop_empty() |>
  omopgenerics::bind() |>
  omopgenerics::newSummarisedResult()

OmopViewer::exportStaticApp(result = result, directory = "/home/AD_NDORMS/rowelin/R/HDRUK-01-001-Antibiotics/Report",
                            logo = "hdr",
                            theme = "theme1",
                            title = "Commonly used antibiotics",
                            background = TRUE,
                            summary = TRUE,
                            open = FALSE)

info(logger, "CREATED SHINY DASHBOARD")

info(logger, "EXPORTING RESULTS")

files_to_zip <- list.files(here("Results"))
files_to_zip <- files_to_zip[stringr::str_detect(files_to_zip,
                                        db_name)]
files_to_zip <- files_to_zip[stringr::str_detect(files_to_zip,
                                        ".csv")]

zip::zip(zipfile = file.path(paste0(
  here("Results"), "/Results_", db_name, ".zip"
)),
files = files_to_zip,
root = here("Results"))

info(logger, "RESULTS EXPORTED")