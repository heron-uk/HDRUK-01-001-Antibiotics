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

  for (i in seq_along(drug_diagnostics)) {
    write.csv(
      drug_diagnostics[[i]] %>%
        mutate(cdm_name = !!db_name),
      here("Results", paste0(
        names(drug_diagnostics)[i], "_", cdmName(cdm), ".csv"
      ))
    )
  }

  cli::cli_alert_success("- Finished drug exposure diagnostics")
}