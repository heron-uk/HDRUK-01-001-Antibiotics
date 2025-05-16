if (run_drug_exposure_diagnostics == TRUE) {
  
  ded_ingredients <- sub("_.*", "", names(ingredient_desc))

  ded_codes <- cdm$concept %>%
    filter(domain_id == "Drug",
           concept_class_id == "Ingredient",
           standard_concept == "S",
           concept_code %in% ded_ingredients) %>%
    pull("concept_id")

  cli::cli_alert_info("- Running drug exposure diagnostics")
  drug_diagnostics <- executeChecks(
    cdm = cdm,
    ingredients = ded_codes,
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
    outputFolder = results_folder,
    filename = paste0("DED_Results_", cdmName(cdm)),
    minCellCount = min_cell_count
  )

  cli::cli_alert_success("- Finished drug exposure diagnostics")
}
