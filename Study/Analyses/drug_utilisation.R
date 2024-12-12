if (run_drug_utilisation == TRUE) {
  cli::cli_alert_info("- Getting initial dose and duration")

  dus_summary <- list()

  drug_ingredient_codes <- cdm$concept %>%
    filter(standard_concept == "S") %>%
    filter(domain_id == "Drug") %>%
    filter(concept_name %in% local(top_ten_names)) %>%
    filter(concept_class_id == "Ingredient") %>%
    filter(standard_concept == "S") %>%
    select(c("concept_id", "concept_name")) %>%
    collect()

  ingredient_codes <- drug_ingredient_codes %>%
    pull(concept_id)

  for (i in seq_along(ingredient_codes)) {
    name <- drug_ingredient_codes %>%
      filter(concept_id == ingredient_codes[i]) %>%
      pull(concept_name)

    if (name == "rifampin") {
      name <- "rifampicin"
    }

    dus_summary[[i]] <- cdm$watch_list |>
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
      ) %>%
      filter(grepl(paste0("^", name), group_level))
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
