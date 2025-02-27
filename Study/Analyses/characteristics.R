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
    mutate(
      age_group_narrow = case_when(
        age >= 0 & age <= 4 ~ '0 to 4',
        age >= 5 & age <= 9 ~ '5 to 9',
        age >= 10 & age <= 14 ~ '10 to 14',
        age >= 15 & age <= 19 ~ '15 to 19',
        age >= 20 & age <= 29 ~ '20 to 29',
        age >= 30 & age <= 39 ~ '30 to 39',
        age >= 40 & age <= 49 ~ '40 to 49',
        age >= 50 & age <= 59 ~ '50 to 59',
        age >= 60 & age <= 69 ~ '60 to 69',
        age >= 70 & age <= 79 ~ '70 to 79',
        age >= 80 & age <= 150 ~ '80 to 150',
        TRUE ~ 'None'  
      ),
      age_group_broad = case_when(
        age >= 0 & age <= 19 ~ '0 to 19',
        age >= 20 & age <= 64 ~ '20 to 64',
        age >= 65 & age <= 150 ~ '65 to 150',
        TRUE ~ 'None'  
      )
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
