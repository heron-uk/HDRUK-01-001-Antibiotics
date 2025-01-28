if (run_incidence == TRUE) {
  cli::cli_alert_info("- Getting incidence")
  # Incidence
  cdm <- generateDenominatorCohortSet(
    cdm = cdm,
    name = "denominator",
    ageGroup = list(
      c(0, 17),
      c(18, 59), c(60, 150),
      c(0, 150)
    ),
    cohortDateRange = studyPeriod,
    sex = c("Male", "Female", "Both"),
    daysPriorObservation = c(0,30)
  )
  
  cdm$denominator <- cdm$denominator %>%
    addSex()

  inc <- estimateIncidence(
    cdm = cdm,
    denominatorTable = "denominator",
    outcomeTable = "top_ten_by_route",
    interval = c("quarters", "years"),
    repeatedEvents = TRUE,
    outcomeWashout = 30,
    completeDatabaseIntervals = FALSE
  )
  
  inc_tidy <- inc %>% 
    omopgenerics::splitAdditional() %>% 
    omopgenerics::splitGroup() %>% 
    omopgenerics::addSettings() %>% 
    filter(variable_name == "Outcome") %>%
    omopgenerics::pivotEstimates(pivotEstimatesBy = "estimate_name") 
  
  
  # get the denominator related results which contain the person years and denominator count
  inc_tidy1 <- inc %>% 
    omopgenerics::splitAdditional() %>% 
    omopgenerics::splitGroup() %>% 
    omopgenerics::addSettings() %>% 
    filter(variable_name == "Denominator") %>% 
    omopgenerics::pivotEstimates(pivotEstimatesBy = "estimate_name") %>% 
    select(person_days,
      person_years,
      denominator_count
    )
  
  inc_tidy <- bind_cols(inc_tidy, inc_tidy1)
  
  omopgenerics::exportSummarisedResult(inc,
                         minCellCount = min_cell_count,
                         fileName = here(resultsFolder, paste0(
    "incidence_", cdmName(cdm), ".csv"
  )))
  
  results[["incidence"]] <- inc


  cli::cli_alert_success("- Got crude incidence")
}
