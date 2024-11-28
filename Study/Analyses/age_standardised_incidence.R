cdm <- generateDenominatorCohortSet(cdm = cdm,
                                    name = "denominator_strat",
                                    ageGroup = list(c(0, 150),
                                                    c(0, 17), c(18, 150),
                                                    c(18, 59), c(60, 150),
                                                    # pediatric
                                                    c(0, 1), c(1, 4), c(5, 9),
                                                    c(10, 14), c(15, 17)
                                    ),
                                    cohortDateRange = studyPeriod,
                                    sex = c("Both"),
                                    daysPriorObservation = c(0, 30))
cdm$denominator <- cdm$denominator %>%
  addSex(sexName = "sex")

inc_strat <- estimateIncidence(cdm,
                              denominatorTable = "denominator_strat",
                              outcomeTable = "top_ten",
                              interval = c("quarters", "years"),
                              completeDatabaseIntervals = TRUE,
                              outcomeWashout = 30,
                              repeatedEvents = TRUE)

write.csv(inc_strat, here("Results", paste0(
  "incidence_stratified", cdmName(cdm), ".csv"
)))