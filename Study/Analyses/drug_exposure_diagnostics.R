if (run_drug_exposure_diagnostics == TRUE) {
  cli::cli_alert_info("- Running drug exposure diagnostics")
  
  drug_diagnostics <- executeChecks(
    cdm = cdm,
    ingredients = top_ten_ingredients$concept_id,
    checks = c(
      "missing",
      "exposureDuration",
      "sourceConcept",
      "route",
      "dose",
      "quantity",
      "type"
    ),
    earliestStartDate = study_start,
    outputFolder = resultsFolder,
    filename = paste0("DED_Results_", db_name),
    minCellCount = min_cell_count
  )
  
  cli::cli_alert_success("- Finished drug exposure diagnostics")
}