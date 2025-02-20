if (run_incidence == TRUE) {
  cli::cli_alert_info("- Getting incidence")
  # Incidence
  cdm <- generateDenominatorCohortSet(
    cdm = cdm,
    name = "denominator",
    ageGroup = list(
      c(0, 150),
      c(0, 4),
      c(5, 9),
      c(10, 19),
      c(20, 29),
      c(30, 39),
      c(40, 49),
      c(50, 59),
      c(60, 69),
      c(70, 79),
      c(80, 150),
      c(0, 19),
      c(20, 64),
      c(65, 150)
    ),
    cohortDateRange = studyPeriod,
    sex = c("Male", "Female", "Both"),
    daysPriorObservation = c(0,30)
  )

  inc <- estimateIncidence(
    cdm = cdm,
    denominatorTable = "denominator",
    outcomeTable = "top_ten",
    interval = c("quarters"),
    repeatedEvents = TRUE,
    outcomeWashout = 30,
    completeDatabaseIntervals = FALSE
  )
  
  results[["incidence"]] <- inc
  
  if(isTRUE(run_watch_list) & length(routes) > 0){
  
  inc_route <- estimateIncidence(
    cdm = cdm,
    denominatorTable = "denominator",
    outcomeTable = "top_ten_by_route",
    interval = c("quarters"),
    repeatedEvents = TRUE,
    outcomeWashout = 30,
    completeDatabaseIntervals = FALSE
  )
  results[["incidence_by_route"]] <- inc_route
  }
  
  cli::cli_alert_success("- Got crude incidence")
}
