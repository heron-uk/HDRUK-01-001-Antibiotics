if (run_characterisation == TRUE) {
  cli::cli_alert_info("- Getting characteristics")
  
  cdm$antibiotics_chars <- cdm$antibiotics |>
    PatientProfiles::addDemographics(
      sex = TRUE,
      age = TRUE,
      priorObservation = FALSE,
      futureObservation = FALSE,
      name = "antibiotics_chars"
    )
  
  cdm$antibiotics_chars <- cdm$antibiotics_chars |>
    mutate(
      age_group_narrow = case_when(
        age >= 0 & age <= 4 ~ '0 to 4',
        age >= 5 & age <= 9 ~ '5 to 9',
        age >= 10 & age <= 14 ~ '10 to 14',
        age >= 15 & age <= 18 ~ '15 to 18',
        age >= 19 & age <= 29 ~ '19 to 29',
        age >= 30 & age <= 39 ~ '30 to 39',
        age >= 40 & age <= 49 ~ '40 to 49',
        age >= 50 & age <= 59 ~ '50 to 59',
        age >= 60 & age <= 69 ~ '60 to 69',
        age >= 70 & age <= 79 ~ '70 to 79',
        age >= 80 & age <= 150 ~ '80 to 150',
        TRUE ~ 'None'  
      ),
      age_group_broad = case_when(
        age >= 0 & age <= 18 ~ '0 to 18',
        age >= 19 & age <= 64 ~ '19 to 64',
        age >= 65 & age <= 150 ~ '65 to 150',
        TRUE ~ 'None'  
      )
    )
  
  cdm$antibiotics_chars <- cdm$antibiotics_chars |>
    requireInDateRange(dateRange = c(as.Date("2022-01-01"), as.Date(NA)))

  results[["characteristics"]] <- cdm$antibiotics_chars |>
    summariseCharacteristics(cohortIntersectFlag = list(
      "Antibiotics (-90 to -15)" = list(
        targetCohortTable = "access_antibiotics", window = c(-90,-15)
      ), "Antibiotics (-14 to -1)" = list(
        targetCohortTable = "access_antibiotics", window = c(-14,-1)
      ),"Indication Flag" = list(
        targetCohortTable = "indications", window = c(-14,14)
      )), strata = list(c("age_group_broad")
      )
    )
  
  for(i in seq_along(indications_list)){
    results[[paste0("indication_code_use_", i)]] <- summariseCohortCodeUse(x = indications_list[i],
                                                                           cdm = cdm,
                                                                           cohortTable = "indications",
                                                                           cohortId = i)
  }
  
  for(i in seq_along(acc_ingredient_desc)){
    results[[paste0("access_antibiotic_code_use_", i)]] <- summariseCohortCodeUse(x = acc_ingredient_desc[i],
                                                                           cdm = cdm,
                                                                           cohortTable = "access_antibiotics",
                                                                           cohortId = i)
  }
  
  cli::cli_alert_info("- Got characteristics")

  cli::cli_alert_info("- Getting large scale characteristics")
  results[["lsc"]] <- summariseLargeScaleCharacteristics(cdm$antibiotics_chars,
    eventInWindow = c(
      "condition_occurrence",
      "observation",
      "procedure_occurrence",
      "drug_exposure"
    ),
    window = list(c(-14,14))
  )

  cli::cli_alert_success("- Got large scale characteristics")
}
