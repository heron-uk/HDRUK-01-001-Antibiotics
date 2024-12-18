if (run_drug_utilisation == TRUE) {
  cli::cli_alert_info("- Getting initial dose and duration")

  dus_summary <- list()

  ingredient_codes <- top_ten_ingredients %>%
    pull(concept_id)

  for (i in seq_along(ingredient_codes)) {

    dus_summary[[i]] <- cdm$top_ten |>
      summariseDrugUtilisation(
        indexDate = "cohort_start_date",
        censorDate = "cohort_end_date",
        ingredientConceptId = ingredient_codes[i],
        restrictIncident = TRUE,
        gapEra = 7,
        numberExposures = TRUE,
        numberEras = FALSE,
        exposedTime = TRUE,
        timeToExposure = FALSE,
        initialQuantity = FALSE,
        cumulativeQuantity = FALSE,
        initialDailyDose = TRUE,
        cumulativeDose = FALSE
      )
  }

  final_summary <- dplyr::bind_rows(dus_summary)

  results[["initial_dose_and_duration"]] <- final_summary

  write.csv(
    final_summary,
    here("Results", paste0(
      "dus_summary_", cdmName(cdm), ".csv"
    ))
  )

  cli::cli_alert_success("- Got initial dose and duration")
}
