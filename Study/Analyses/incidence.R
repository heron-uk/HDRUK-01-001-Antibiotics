if (run_incidence == TRUE) {
  cli::cli_alert_info("- Getting incidence")
  # Incidence
  
  incidence <- estimateIncidence(
    cdm = cdm,
    denominatorTable = "denominator",
    outcomeTable = "antibiotics",
    interval = c("quarters"),
    repeatedEvents = TRUE,
    outcomeWashout = 30,
    completeDatabaseIntervals = FALSE
  )
  
  results[["incidence"]] <- incidence %>%
    filter(additional_name != "reason_id")

  cli::cli_alert_success("- Got crude incidence")
}