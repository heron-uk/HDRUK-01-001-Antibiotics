if (run_drug_exposure_diagnostics == TRUE) {
  ded_ingredients <- all_routes_counts %>%
    select(cohort_name)

  if (exists("watch_list_antibiotics")) {
    ded_antibiotics <- watch_list_antibiotics %>%
      select(cohort_name)

    ded_names <- rbind(ded_ingredients, ded_antibiotics) %>%
      distinct()
  } else {
    ded_names <- ded_ingredients %>%
      distinct()
  }

  ded_names <- ded_names %>%
    separate(cohort_name, into = c("concept_code", "concept_name"), sep = "_")

  ded_codes <- cdm$concept %>%
    filter(domain_id == "Drug") %>%
    filter(concept_class_id == "Ingredient") %>%
    filter(standard_concept == "S") %>%
    select(c("concept_id", "concept_name", "concept_code")) %>%
    filter(concept_name %in% ded_names$concept_name) %>%
    pull(concept_id)

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
    filename = paste0("DED_Results_", db_name),
    minCellCount = min_cell_count
  )

  cli::cli_alert_success("- Finished drug exposure diagnostics")
}
