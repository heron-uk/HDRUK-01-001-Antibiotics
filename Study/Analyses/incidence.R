cli::cli_alert_info("- Getting incidence")
# Incidence
cdm <- generateDenominatorCohortSet(cdm = cdm,
                                    name = "denominator",
                                    ageGroup = list(c(0, 17),
                                                    c(18, 59), c(60, 150),
                                                    c(0,150)
                                    ),
                                    cohortDateRange = studyPeriod,
                                    sex = c("Male", "Female", "Both"),
                                    daysPriorObservation = 30)
cdm$denominator <- cdm$denominator %>%
  addSex()

inc <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator",
  outcomeTable = "watch_list",
  interval = c("quarters", "years", "overall"),
  repeatedEvents = TRUE,
  outcomeWashout = 30
) 

inc_tidy <- inc %>% 
  visOmopResults::splitAdditional() %>% 
  visOmopResults::splitGroup() %>%
  visOmopResults::addSettings() %>% 
  pivot_wider(
    names_from = estimate_name,
    values_from = c(estimate_value, estimate_type)
  ) %>% 
  mutate(across(starts_with("estimate_value"), as.numeric)) %>%  # Convert estimate_value columns to numeric
  rename_with(~ gsub("^estimate_value_", "", .), starts_with("estimate_value")) %>% 
  select(-starts_with("estimate_type")) %>% 
  mutate(outcome_count = as.integer(outcome_count))

write.csv(inc_tidy, here("Results", paste0(
  "incidence", cdmName(cdm), ".csv"
)))

results[["incidence"]] <- inc

cli::cli_alert_success("- Got incidence")
