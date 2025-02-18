if (run_drug_exposure_diagnostics == TRUE) {
  
  ded_ingredients <- all_concepts_counts %>%
    select(cohort_name)
  
  if(exists("top_ten_antibiotics")){
    
    ded_antibiotics <- top_ten_antibiotics %>%
      select(cohort_name)
    
  ded_names <- rbind(ded_ingredients, ded_antibiotics) %>%
    distinct()
  } else {
    ded_names <- ded_ingredients %>%
      distinct()
  }
  
  ded_names <- ded_names %>%
    separate(cohort_name, into = c("concept_code", "concept_name"), sep = "_")
  
  ded_names <- merge(ded_names, ing_av, by = c("concept_name", "concept_code"))
    
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
