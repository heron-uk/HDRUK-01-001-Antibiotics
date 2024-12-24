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
    daysPriorObservation = 30
  )
  cdm$denominator <- cdm$denominator %>%
    addSex()

  inc <- estimateIncidence(
    cdm = cdm,
    denominatorTable = "denominator",
    outcomeTable = "top_ten_by_route",
    interval = c("quarters", "years", "overall"),
    repeatedEvents = TRUE,
    outcomeWashout = 30,
    completeDatabaseIntervals = FALSE
  )

  write.csv(inc, here("Results", paste0(
    "_incidence", cdmName(cdm), ".csv"
  )))

  results[["incidence"]] <- inc

  cli::cli_alert_success("- Got crude incidence")
}
