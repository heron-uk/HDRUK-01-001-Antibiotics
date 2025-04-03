if (run_incidence == TRUE) {
  cli::cli_alert_info("- Getting incidence")
  # Incidence
  results[["incidence"]] <- estimateIncidence(
    cdm = cdm,
    denominatorTable = "denominator",
    outcomeTable = "antibiotics",
    interval = c("quarters"),
    repeatedEvents = TRUE,
    outcomeWashout = 30,
    completeDatabaseIntervals = FALSE
  )

  cli::cli_alert_success("- Got crude incidence")
}

tableIncidence(results[["incidence"]])
