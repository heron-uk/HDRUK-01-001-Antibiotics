if (run_drug_utilisation == TRUE) {
  cli::cli_alert_info("- Getting initial dose and duration")

  if(isTRUE(run_watch_list)){
    
  dus_summary <- list()
  
  cdm <- generateDrugUtilisationCohortSet(
    cdm = cdm,
    name = "top_ten_du",
    conceptSet = top_ten_watch_list,
    gapEra = 7
  ) 
  
  cdm$top_ten_du <- cdm$top_ten_du |>
    requirePriorObservation(indexDate = "cohort_start_date",
                            minPriorObservation = 30) |>
    requireInDateRange(dateRange = c(as.Date(c(study_start, maxObsEnd))))
    
    cohort_names <- merge(settings(cdm$top_ten_du), watch_list_antibiotics, by = "cohort_name") %>%
      select(c(cohort_name, cohort_definition_id.x)) %>%
      separate(cohort_name, into = c("concept_code", "concept_name"), sep = "_")
    
    du_codes <- cdm$concept %>%
      filter(domain_id == "Drug") %>%
      filter(concept_class_id == "Ingredient") %>%
      filter(standard_concept == "S") %>%
      select(c("concept_id", "concept_name", "concept_code")) %>%
      filter(concept_name %in% cohort_names$concept_name) %>%
      collect()
    
    cohort_names <- merge(cohort_names, du_codes, by = c("concept_name", "concept_code"))

  for (i in seq_along(cohort_names$concept_code)) {

    dus_summary[[i]] <- cdm$top_ten_du |>
      summariseDrugUtilisation(
        cohortId = cohort_names$cohort_definition_id.x[i],
        indexDate = "cohort_start_date",
        censorDate = "cohort_end_date",
        ingredientConceptId = cohort_names$concept_id[i],
        gapEra = 7, 
        numberExposures = TRUE,
        numberEras = FALSE,
        daysExposed = TRUE,
        timeToExposure = FALSE,
        initialQuantity = FALSE,
        cumulativeQuantity = FALSE,
        initialDailyDose = TRUE,
        cumulativeDose = FALSE,
        restrictIncident = FALSE
      )
  }

 final_summary <- dplyr::bind_rows(dus_summary)
 
 results[["drug_utilisation"]] <- final_summary

cli::cli_alert_success("- Got initial dose and duration")
  } else {
    cli::cli_alert_success("- Ingredient level only - skip drug utilisation")
  }
}    
