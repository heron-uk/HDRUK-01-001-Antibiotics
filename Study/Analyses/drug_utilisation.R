if (run_drug_utilisation == TRUE) {
  cli::cli_alert_info("- Getting initial dose and duration")

  dus_summary <- list()
  
  if(isTRUE(run_watch_list)){
    cohort_names <- settings(cdm$top_ten) %>%
      mutate(ingredient_name = str_extract(cohort_name, "^[^_]+"))
    
    cohort_names <- merge(cohort_names, top_ten_antibiotics, by = "ingredient_name")
    
  } else{
    cohort_names <- top_ingredients %>%
      rename(cohort_name = ingredient_name)
    
    cohort_names <- merge(settings(cdm$top_ten), cohort_names, by = "cohort_name")
  }

  for (i in seq_along(cohort_names$cohort_name)) {

    dus_summary[[i]] <- cdm$top_ten |>
      summariseDrugUtilisation(
        cohortId = cohort_names$cohort_definition_id[i],
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
        cumulativeDose = FALSE
      )
  }

 final_summary <- dplyr::bind_rows(dus_summary)
 
 results[["drug_utilisation"]] <- final_summary
 
 omopgenerics::exportSummarisedResult(final_summary,
                        minCellCount = min_cell_count,
                        fileName = here(resultsFolder, paste0(
      "dus_summary_", cdmName(cdm), ".csv"
    )))

  cli::cli_alert_success("- Got initial dose and duration")
}
