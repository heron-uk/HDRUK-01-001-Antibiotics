cli::cli_alert_info("- Getting age standardised incidence")

cdm <- generateDenominatorCohortSet(cdm = cdm,
                                    name = "denominator_strat",
                                    ageGroup = list(c(0, 17),
                                                    c(18, 59), c(60, 150),
                                                    c(0,150)
                                    ),
                                    cohortDateRange = studyPeriod,
                                    sex = c("Male", "Female", "Both"),
                                    daysPriorObservation = 30)
cdm$denominator_strat <- cdm$denominator_strat %>%
  addSex()

inc_strat <- estimateIncidence(cdm,
                              denominatorTable = "denominator_strat",
                              outcomeTable = "watch_list",
                              interval = c("quarters", "years"),
                              outcomeWashout = 30,
                              repeatedEvents = TRUE) 

inc_strat_tidy <- inc_strat %>% 
  visOmopResults::splitAdditional() %>% 
  visOmopResults::addSettings() %>% 
  pivot_wider(
    names_from = estimate_name,
    values_from = c(estimate_value, estimate_type)
  ) %>% 
  mutate(across(starts_with("estimate_value"), as.numeric)) %>%  # Convert estimate_value columns to numeric
  rename_with(~ gsub("^estimate_value_", "", .), starts_with("estimate_value")) %>% 
  select(-starts_with("estimate_type")) %>% 
  mutate(outcome_count = as.integer(outcome_count)
  )


write.csv(inc_strat, here("Results", paste0(
  "incidence_stratified_tidy", cdmName(cdm), ".csv"
)))

results[["stratified_incidence"]] <- inc_strat


cli::cli_alert_success("- Getting age standardised incidence")