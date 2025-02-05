if (run_drug_exposure_diagnostics == TRUE) {
drug_diagnostics <- executeChecks(
    cdm = cdm,
    ingredients = all_concepts_counts$concept_id,
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
    filename = paste0("DED_results_ingredients", db_name),
    minCellCount = min_cell_count
  )
}