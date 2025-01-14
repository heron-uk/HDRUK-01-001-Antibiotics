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
      "quantity"
    ),
    earliestStartDate = "2012-01-01"
  )
  
  writeResultToDisk(drug_diagnostics,
                    databaseId = paste0("DED_",db_name),
                    outputFolder = here("Results")
  )
  
  cli::cli_alert_success("- Finished drug exposure diagnostics")
}