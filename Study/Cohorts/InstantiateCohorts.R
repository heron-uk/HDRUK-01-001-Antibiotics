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
    sex = c("Both", "Male", "Female"),
    daysPriorObservation = 0,
    requirementInteractions = FALSE
  )
}

# Patient visit cohorts
if(isTRUE(restrict_to_inpatient) & numberRecords(cdm$visit_occurrence) > 0){
  cdm$inpatient_visit <- conceptCohort(
    cdm = cdm,
    conceptSet = list(inpatient = c(9201, 262, 9203)),
    name = "inpatient_visit"
  ) 
} else if (isTRUE(restrict_to_inpatient) & numberRecords(cdm$visit_occurrence) == 0) {
  
  cli::cli_text("No records in visit occurrence table - skip restriction to inpatients only")
}

# ingredient cohorts ------
cli::cli_alert_info("- Creating ingredient cohorts")
# will always get top 10 ingredients
if(isTRUE(restrict_to_inpatient)){
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
    requirePriorDrugWashout(days = 30,
                            name = "antibiotics") |>
    requireTableIntersect(
      tableName = "inpatient_visit",
      window = c(0, Inf),
      indexDate = "cohort_start_date"
    ) |>
    requireTableIntersect(
      tableName = "inpatient_visit",
      window = c(-Inf, 0),
      indexDate = "cohort_end_date"
    ) |>
    requireInDateRange(study_period)
} else {
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
    requirePriorDrugWashout(days = 30,
                            name = "antibiotics") |>
    requireInDateRange(study_period) 
}

antibiotics_count <- merge(cohortCount(cdm$antibiotics), settings(cdm$antibiotics), by = "cohort_definition_id") %>%
  filter(number_subjects > 100)

ingredient_desc <- ingredient_desc[names(ingredient_desc) %in% antibiotics_count$cohort_name]

cdm$antibiotics <- cdm$antibiotics |>
  subsetCohorts(cohortId = antibiotics_count$cohort_definition_id)

for(i in seq_along(ingredient_desc)){
  working_cohort_id <- getCohortId(cohort = cdm$antibiotics, cohortName = names(ingredient_desc)[i])
  results[[paste0("code_use_", i)]] <- summariseCohortCodeUse(ingredient_desc[i], 
                                                                                    cdm = cdm, 
                                                                                    cohortId = working_cohort_id,
                                                                                    cohortTable = "antibiotics")
  
sum_antibiotics <- summariseCohortCount(cohort = cdm$antibiotics)

results[["sum_antibiotics"]] <- sum_antibiotics
}

##### Indications
indications <- read_csv("Cohorts/indications_concepts.csv")[,-1]

indications_grouped <- indications %>%
  group_by(indication_category) %>%
  summarise(concept_id_vector = list(concept_id), .groups = "drop")

indications_list <- setNames(indications_grouped$concept_id_vector, toSnakeCase(indications_grouped$indication_category))

cdm$indications <- conceptCohort(cdm = cdm,
                                 conceptSet = indications_list,
                                 name = "indications")

##### Access Antibiotics

cdm$access_antibiotics <- conceptCohort(cdm = cdm,
                                        conceptSet = acc_ingredient_desc,
                                        name = "access_antibiotics")

cli::cli_alert_success("- Created cohort set")
