if (run_drug_utilisation == TRUE) {
  cli::cli_alert_info("- Getting initial dose and duration")

  if (isTRUE(run_watch_list)) {
    for (i in seq_along(top_ten_watch_list)) {
      working_watch_list <- top_ten_watch_list[i]
      working_cohort_id <- getCohortId(cdm$top_ten,
        cohortName = names(working_watch_list)
      )
      working_ing_concept_code <- str_split(
        names(working_watch_list),
        "_"
      )[[1]][2]
      working_ingredient_concept_id <- cdm$concept |>
        filter(concept_code == !!working_ing_concept_code) |>
        pull("concept_id")
      cli::cli_inform("     -- For {names(working_watch_list)}")
      results[[paste0("drug_utilisation_", i)]] <- cdm$top_ten |>
        summariseDrugUtilisation(
          cohortId = working_cohort_id,
          indexDate = "cohort_start_date",
          censorDate = "cohort_end_date",
          ingredientConceptId = working_ingredient_concept_id,
          conceptSet = working_watch_list,
          gapEra = 7,
          initialExposureDuration = FALSE,
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

    cli::cli_alert_success("- Got initial dose and duration")
  } else {
    cli::cli_alert_success("- Ingredient level only - skip drug utilisation")
  }
}
