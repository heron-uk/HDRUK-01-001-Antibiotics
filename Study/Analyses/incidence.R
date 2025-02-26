if (run_incidence == TRUE) {
  cli::cli_alert_info("- Getting incidence")
  # Incidence
  results[["incidence"]] <- estimateIncidence(
    cdm = cdm,
    denominatorTable = "denominator",
    outcomeTable = "top_ten_outcomes",
    interval = c("quarters", "overall"),
    repeatedEvents = TRUE,
    outcomeWashout = 30,
    completeDatabaseIntervals = FALSE
  )

  cli::cli_alert_success("- Got crude incidence")
}
