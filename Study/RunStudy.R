# create logger ----
resultsFolder <- here("Results")
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
info(logger, "snapshot completed")

# instantiate necessary cohorts ----
info(logger, "INSTANTIATING STUDY COHORTS")
source(here("Cohorts", "InstantiateCohorts.R"))
info(logger, "STUDY COHORTS INSTANTIATED")

# run analyses ----
info(logger, "RUN ANALYSES")
source(here("Analyses", "characteristics.R"))
source(here("Analyses", "incidence.R"))
info(logger, "ANALYSES FINISHED")

# export results ----
info(logger, "EXPORTING RESULTS")
exportSummarisedResult(
  resultSnapshot,
  minCellCount = minCellCount,
  path = resultsFolder
)
zip(
  zipfile = file.path(paste0(resultsFolder, "/Results_", cdmName(cdm), ".zip")),
  files = list.files(resultsFolder, full.names = TRUE)
)
