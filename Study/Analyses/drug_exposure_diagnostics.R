if (run_drug_exposure_diagnostics == TRUE) {
  
  top_ingredients <- read.csv(here("Results", db_name, paste0("top_ten_ingredients_", db_name, ".csv")))[,-1] %>%
    select(-cohort_definition_id)
  
  if(isTRUE(run_watch_list)) {
  top_watch_list <- read.csv(here("Results", db_name, paste0("top_ten_watch_list_", db_name, ".csv")))[,-1] %>%
    select(-cohort_definition_id)
  
  ded_names <- rbind(top_ingredients, top_watch_list) %>%
    select(ingredient_name,concept_id) %>%
    distinct()
  } else {
    ded_names <- top_ingredients %>%
      select(ingredient_name,concept_id) %>%
      distinct()
  }
  cli::cli_alert_info("- Running drug exposure diagnostics")
  
  drug_diagnostics <- executeChecks(
    cdm = cdm,
    ingredients = ded_names$concept_id,
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
