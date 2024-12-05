cli::cli_alert_info("- Getting age standardised incidence")

cdm <- generateDenominatorCohortSet(cdm = cdm,
                                    name = "denominator_strat",
                                    ageGroup = list(c(0, 17),
                                                    c(18, 59), c(60, 150)
                                    ),
                                    cohortDateRange = studyPeriod,
                                    sex = c("Male", "Female"),
                                    daysPriorObservation = 30)
cdm$denominator_strat <- cdm$denominator_strat %>%
  addSex()

inc_strat_q <- estimateIncidence(cdm,
                              denominatorTable = "denominator_strat",
                              outcomeTable = "top_ten",
                              interval = c("quarters"),
                              completeDatabaseIntervals = TRUE,
                              outcomeWashout = 30,
                              repeatedEvents = TRUE) 

inc_strat_y <- estimateIncidence(cdm,
                                 denominatorTable = "denominator_strat",
                                 outcomeTable = "top_ten",
                                 interval = c("years"),
                                 completeDatabaseIntervals = TRUE,
                                 outcomeWashout = 30,
                                 repeatedEvents = TRUE)

write.csv(inc_strat_q, here("Results", paste0(
  "incidence_stratified_quarters", cdmName(cdm), ".csv"
)))

write.csv(inc_strat_y, here("Results", paste0(
  "incidence_stratified_years", cdmName(cdm), ".csv"
)))


cli::cli_alert_success("- Getting age standardised incidence")