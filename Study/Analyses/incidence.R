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
  outcomeTable = "watch_list",
  interval = c("quarters", "years"),
  repeatedEvents = TRUE,
  outcomeWashout = 30
) 

inc_tidy <- inc %>% 
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

write.csv(inc_tidy, here("Results", paste0(
  "incidence", cdmName(cdm), ".csv"
)))

results[["incidence"]] <- inc

cli::cli_alert_success("- Got incidence")
