if (run_characterisation == TRUE) {
  cli::cli_alert_info("- Getting cohort attrition")
  results[["cohort_attrition"]] <- summariseCohortAttrition(cdm$top_ten)

  cli::cli_alert_info("- Getting characteristics")
  cdm$top_ten_chars <- cdm$top_ten |>
    addDemographics(
      sex = TRUE,
      age = TRUE,
      priorObservation = FALSE,
      futureObservation = FALSE,
      name = "top_ten_chars"
    )
  cdm$top_ten_chars <- cdm$top_ten_chars |>
    addCategories(
      variable = "age",
      categories = list("age_group_narrow" = list(
        c(0, 4), c(5, 9), c(10, 14), c(15, 19),
        c(20, 29), c(30, 39), c(40, 49), c(50, 59),
        c(60, 69), c(70, 79),
        c(80, 150)
      ))
    ) |>
    addCategories(
      variable = "age",
      categories = list("age_group_broad" = list(
        c(0, 19),
        c(20, 64),
        c(65, 150)
      ))
    )

  results[["characteristics"]] <- cdm$top_ten_chars |>
    summariseCharacteristics(
      strata = list(
        "sex",
        "age_group_narrow",
        "age_group_broad"
      )
    )

  cli::cli_alert_info("- Getting large scale characteristics")
  results[["lsc"]] <- summariseLargeScaleCharacteristics(cdm$top_ten,
    eventInWindow = c(
      "condition_occurrence",
      "observation",
      "procedure_occurrence"
    ),
    window = list(c(-7, 0), c(0, 0))
  )

  cli::cli_alert_success("- Got large scale characteristics")
}
