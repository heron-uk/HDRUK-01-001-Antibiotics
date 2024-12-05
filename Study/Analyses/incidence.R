cli::cli_alert_info("- Getting incidence")
# Incidence
cdm <- generateDenominatorCohortSet(
  cdm = cdm,
  name = "denominator",
  cohortDateRange = studyPeriod,
  daysPriorObservation = 30
)

inc_q <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = "top_ten",
  interval = c("quarters"),
  repeatedEvents = TRUE,
  outcomeWashout = 30,
  completeDatabaseIntervals = TRUE,
  minCellCount = 5
)

inc_y <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = "top_ten",
  interval = c("years"),
  repeatedEvents = TRUE,
  outcomeWashout = 30,
  completeDatabaseIntervals = TRUE,
  minCellCount = 5
) 

write.csv(inc_q, here("Results", paste0(
  "incidence_quarters", cdmName(cdm), ".csv"
)))

write.csv(inc_y, here("Results", paste0(
  "incidence_years", cdmName(cdm), ".csv"
)))


cli::cli_alert_success("- Got incidence")

?estimateIncidence
