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
  interval = c("quarters","overall"),
  repeatedEvents = TRUE,
  outcomeWashout = 30,
  completeDatabaseIntervals = TRUE,
  minCellCount = 5
)

write.csv(inc, here("Results", paste0(
  "incidence_", cdmName(cdm), ".csv"
)))

