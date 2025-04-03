# denominator cohorts ------
if (run_incidence == TRUE) {
  cli::cli_alert_info("- Getting denominator cohorts")
  cdm <- generateDenominatorCohortSet(
    cdm = cdm,
    name = "denominator",
    ageGroup = list(
      c(0, 150),
      c(0, 4),
      c(5, 9),
      c(10, 19),
      c(20, 29),
      c(30, 39),
      c(40, 49),
      c(50, 59),
      c(60, 69),
      c(70, 79),
      c(80, 150),
      c(0, 19),
      c(20, 64),
      c(65, 150)
    ),
    cohortDateRange = study_period,
    sex = c("Male", "Female", "Both"),
    daysPriorObservation = c(0, 30)
  )
}
# ingredient cohorts ------
cli::cli_alert_info("- Creating ingredient cohorts")
# will always get top 10 ingredients
if(isTRUE(primary_care)){
# outpatient cohorts ------
cli::cli_alert_info("- Creating outpatient cohorts")
  cdm <- generateDrugUtilisationCohortSet(
    cdm = cdm,
    name = "antibiotics_outcomes",
    conceptSet = ingredient_desc,
    gapEra = 7
  )

  cdm$antibiotics <- cdm$antibiotics_outcomes |>
    requirePriorObservation(
      indexDate = "cohort_start_date",
      minPriorObservation = 30,
      name = "antibiotics"
    ) |>
    requireTableIntersect(
      tableName = "patient_visit",
      window = c(0, 0)
    ) |>
    requireInDateRange(study_period)
  
  for(i in seq_along(ingredient_desc)){
    working_cohort_id <- getCohortId(cohort = cdm$antibiotics, cohortName = names(ingredient_desc)[i])
    results[[paste0("code_use_", i)]] <- summariseCohortCodeUse(ingredient_desc[i], 
                                                                                    cdm = cdm, 
                                                                                    cohortId = working_cohort_id,
                                                                                    cohortTable = "antibiotics")
    
    antibiotics_counts <- cohortCount(cdm$antibiotics) |>
      filter(number_records > 500) %>%
      left_join(settings(cdm$antibiotics),
                by = "cohort_definition_id"
      )
    
    sum_antibiotics <- summariseCohortCount(cohort = cdm$antibiotics) %>%
      filter(group_level %in% antibiotics_counts$cohort_name)
    
    results[["sum_antibiotics"]] <- sum_antibiotics
  }
  }

# inpatient cohorts ------
cli::cli_alert_info("- Creating inpatient cohorts")
if(isTRUE(secondary_care)){
  cdm <- generateDrugUtilisationCohortSet(
    cdm = cdm,
    name = "antibiotics_outcomes",
    conceptSet = ingredient_desc,
    gapEra = 7
  )
  
  cdm$antibiotics <- cdm$antibiotics_outcomes |>
    requirePriorObservation(
      indexDate = "cohort_start_date",
      minPriorObservation = 30,
      name = "ing_inpat"
    ) |>
    requireTableIntersect(
      tableName = "patient_visit",
      window = c(-7, 7)
    ) |>
    requireInDateRange(study_period)
  
  for(i in seq_along(ingredient_desc)){
    working_cohort_id <- getCohortId(cohort = cdm$antibiotics, cohortName = names(ingredient_desc)[i])
    results[[paste0("code_use_", i)]] <- summariseCohortCodeUse(ingredient_desc[i], 
                                                                cdm = cdm, 
                                                                cohortId = working_cohort_id,
                                                                cohortTable = "antibiotics")
    
    antibiotics_counts <- cohortCount(cdm$antibiotics) |>
      filter(number_records > 500) %>%
      left_join(settings(cdm$antibiotics),
                by = "cohort_definition_id"
      )
    
    sum_antibiotics <- summariseCohortCount(cohort = cdm$antibiotics) %>%
      filter(group_level %in% antibiotics_counts$cohort_name)
    
    results[["sum_antibiotics"]] <- sum_antibiotics
  }
} 

cli::cli_alert_success("- Created cohort set")

# keep only cohorts with minimum count ------
antibiotics_to_keep <- cohortCount(cdm$antibiotics) |>
  filter(number_subjects > min_cell_count) |>
  pull("cohort_definition_id")

cdm$antibiotics <- subsetCohorts(
  cohort = cdm$antibiotics,
  cohortId = antibiotics_to_keep,
  name = "antibiotics"
)
