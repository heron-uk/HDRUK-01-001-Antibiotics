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

# Stratified Incidence

cdm <- generateDenominatorCohortSet(
  cdm = cdm,
  cohortDateRange = studyPeriod,
  sex = c("Both", "Male","Female"),
  ageGroup = list(c(0,17),
                  c(18,150)),
  daysPriorObservation = 30,
  name = "denominator_age_sex"
)


cdm$age_sex <- cdm$top_ten |>
  addAge(ageGroup = list("child" = c(0, 17), "adult" = c(18, 150))) |>
  addSex(name = "age_sex") |>
  stratifyCohorts(
    strata = list("sex", c("sex", "age_group")), name = "age_sex"
  )

strat_inc <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator_age_sex",
  outcomeTable = "age_sex",
  interval = c("quarters","overall"),
  repeatedEvents = TRUE,
  outcomeWashout = 30,
  completeDatabaseIntervals = TRUE,
  minCellCount = 5
)

write.csv(inc, here("Results", paste0(
  "incidence_", cdmName(cdm), ".csv"
)))

write.csv(strat_inc, here("Results", paste0(
  "stratified_incidence_", cdmName(cdm), ".csv"
)))

