cli::cli_alert_info("- Getting incidence")
# Incidence
cdm <- generateDenominatorCohortSet(
  cdm = cdm,
  name = "denominator",
  cohortDateRange = studyPeriod,
  daysPriorObservation = 30
)

inc <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = "top_ten",
  interval = c("quarters", "years"),
  repeatedEvents = TRUE,
  outcomeWashout = 30,
  completeDatabaseIntervals = TRUE,
  minCellCount = 0
) 

write.csv(inc, here("Results", paste0(
  "incidence", cdmName(cdm), ".csv"
)))


cli::cli_alert_success("- Got incidence")

?estimateIncidence
