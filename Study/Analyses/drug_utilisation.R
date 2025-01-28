if (run_drug_utilisation == TRUE) {
  cli::cli_alert_info("- Getting initial dose and duration")

  dus_summary <- list()

  for (i in seq_along(ingredient_cohorts$cohort_name)) {

    dus_summary[[i]] <- cdm$top_ten |>
      summariseDrugUtilisation(
        cohortId = ingredient_cohorts$cohort_definition_id[i],
        indexDate = "cohort_start_date",
        censorDate = "cohort_end_date",
        ingredientConceptId = ingredient_cohorts$concept_id[i],
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
