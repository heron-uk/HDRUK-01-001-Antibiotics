# denominator cohorts ------
info(logger, "GET DENOMINATOR COHORT")
if (run_incidence == TRUE) {
  cli::cli_alert_info("- Getting denominator cohorts")
  cdm <- generateDenominatorCohortSet(
    cdm = cdm,
    name = "denominator",
    ageGroup = list(
      c(0, 150),
      c(0, 4),
      c(5, 9),
      c(10, 14),
      c(15, 17),
      c(18, 29),
      c(30, 39),
      c(40, 49),
      c(50, 59),
      c(60, 69),
      c(70, 79),
      c(80, 150),
      c(0, 17),
      c(18, 64),
      c(65, 150)
    ),
    cohortDateRange = study_period,
    sex = c("Both", "Male", "Female"),
    daysPriorObservation = 0,
    requirementInteractions = FALSE
  )
}
info(logger, "GOT DENOMINATOR COHORT")



if(isTRUE(restrict_to_inpatient)){
  info(logger, "GET INPATIENT COHORT")
if(isFALSE(isTableEmpty(cdm$visit_occurrence))){
  cdm$inpatient_visit <- conceptCohort(
    cdm = cdm,
    conceptSet = list(inpatient = c(9201, 262, 9203)),
    name = "inpatient_visit"
  ) 
  info(logger, "GOT INPATIENT COHORT")
} else if(isTRUE(isTableEmpty(cdm$visit_occurrence))) {
  
  cli::cli_text("No records in visit occurrence table - skip restrictions on visit type")
}
}

# ingredient cohorts ------
info(logger, "GET WATCH COHORT")
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

if(isTRUE(run_code_use)){
for(i in seq_along(ingredient_desc)){
  working_cohort_id <- getCohortId(cohort = cdm$antibiotics, cohortName = names(ingredient_desc)[i])
  results[[paste0("code_use_", i)]] <- summariseCohortCodeUse(ingredient_desc[i], 
                                                                                    cdm = cdm, 
                                                                                    cohortId = working_cohort_id,
                                                                                    cohortTable = "antibiotics")
}
} 


sum_watch_antibiotics <- summariseCohortCount(cohort = cdm$antibiotics)
    
results[["sum_watch_antibiotics"]] <- sum_watch_antibiotics

info(logger, "GOT WATCH COHORT")

##### Indications
info(logger, "GET INDICATION COHORT")
indications <- read_csv("Cohorts/indications_concepts.csv")[,-1]

indications_grouped <- indications %>%
  group_by(indication_category) %>%
  summarise(concept_id_vector = list(concept_id), .groups = "drop")

indications_list <- setNames(indications_grouped$concept_id_vector, toSnakeCase(indications_grouped$indication_category))

cdm$indications <- conceptCohort(cdm = cdm,
                                 conceptSet = indications_list,
                                 name = "indications") |>
  requireTableIntersect(tableName = "antibiotics",
                        indexDate = "cohort_start_date", 
                        window = c(-Inf, Inf), 
                        name = "indications")

if(isTRUE(run_code_use)){
  for(i in seq_along(indications_list)){
    working_cohort_id <- getCohortId(cohort = cdm$indications, cohortName = names(indications_list)[i])
    results[[paste0("code_use_", i)]] <- summariseCohortCodeUse(indications_list[i], 
                                                                cdm = cdm, 
                                                                cohortId = working_cohort_id,
                                                                cohortTable = "indications")
  }
}
    
    
sum_indications <- summariseCohortCount(cohort = cdm$indications)
    
results[["sum_indications"]] <- sum_indications

info(logger, "GOT INDICATION COHORT")

##### Access Antibiotics
info(logger, "GET ACCESS COHORT")

cdm$access_antibiotics <- conceptCohort(cdm = cdm,
                                        conceptSet = acc_ingredient_desc,
                                        name = "access_antibiotics") |>
  requireTableIntersect(tableName = "antibiotics",
                        indexDate = "cohort_start_date", 
                        window = c(-Inf, Inf), 
                        name = "access_antibiotics")

access_antibiotics_count <- merge(cohortCount(cdm$access_antibiotics), settings(cdm$access_antibiotics), by = "cohort_definition_id") %>%
  filter(number_subjects > 100)

acc_ingredient_desc <- acc_ingredient_desc[names(acc_ingredient_desc) %in% access_antibiotics_count$cohort_name]

cdm$access_antibiotics <- cdm$access_antibiotics |>
  subsetCohorts(cohortId = access_antibiotics_count$cohort_definition_id)

if(isTRUE(run_code_use)){
  for(i in seq_along(acc_ingredient_desc)){
    working_cohort_id <- getCohortId(cohort = cdm$access_antibiotics, cohortName = names(acc_ingredient_desc)[i])
    results[[paste0("code_use_", i)]] <- summariseCohortCodeUse(acc_ingredient_desc[i], 
                                                                cdm = cdm, 
                                                                cohortId = working_cohort_id,
                                                                cohortTable = "access_antibiotics")
  }
} 

sum_access_antibiotics <- summariseCohortCount(cohort = cdm$access_antibiotics)
    
results[["sum_access_antibiotics"]] <- sum_access_antibiotics


info(logger, "GOT ACCESS COHORT")
cli::cli_alert_success("- Created cohort set")
