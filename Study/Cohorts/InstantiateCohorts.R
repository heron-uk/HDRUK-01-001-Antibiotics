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
  
sum_antibiotics <- summariseCohortCount(cohort = cdm$antibiotics)

results[["sum_antibiotics"]] <- sum_antibiotics
}
} else {
  for(i in seq_along(ingredient_desc)){
    
    sum_antibiotics <- summariseCohortCount(cohort = cdm$antibiotics)
    
    results[["sum_antibiotics"]] <- sum_antibiotics
  } 
}
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

info(logger, "GOT ACCESS COHORT")
cli::cli_alert_success("- Created cohort set")


# cli::cli_alert_info(" - Running cohort checks")
# 
# cohort_count <- CohortConstructor::cohortCount(cdm$antibiotics)
# cohort_settings <- settings(cdm$antibiotics)
# 
# number_cohorts <- cohort_count %>%
#   summarise(n = n_distinct(cohort_definition_id)) %>%
#   pull(n)
# 
# cli::cli_alert_info("There are {number_cohorts} cohorts included in the study.")
# if(number_cohorts > 0){
#   
#   cohort_names <- merge(cohort_count, cohort_settings, by = "cohort_definition_id") %>%
#     pull(cohort_name)
#   
#   cli::cli_alert_info("Antibiotics included: {cohort_names}")
# }
# 
# num_zero_cohorts <- cohort_count %>%
#   filter(number_records == 0) %>%
#   summarise(n = n_distinct(cohort_definition_id)) %>%
#   pull(n)
# 
# cli::cli_alert_info("There are {num_zero_cohorts} cohorts with 0 records.")
# 
# if(num_zero_cohorts > 0){
#   num_zero_cohorts <- cohort_count %>%
#     filter(number_records == 0) %>%
#     pull(cohort_definition_id)
#   
#   cohort_settings_zero <- cohort_settings %>%
#     filter(cohort_definition_id %in% num_zero_cohorts) %>%
#     pull(cohort_name)
#   
#   cli::cli_alert_info("Cohorts with 0 records: {cohort_settings_zero}")
# }
# 
# num_zero_cohorts_ind <- cohort_count %>%
#   filter(number_subjects == 0) %>%
#   summarise(n = n_distinct(cohort_definition_id)) %>%
#   pull(n)
# 
# cli::cli_alert_info("There are {num_zero_cohorts_ind} cohorts with 0 subjects.")
# 
# if(num_zero_cohorts_ind > 0){
#   num_zero_cohorts_ind <- cohort_count %>%
#     filter(number_records == 0) %>%
#     pull(cohort_definition_id)
#   
#   cohort_settings_zero_ind <- cohort_settings %>%
#     filter(cohort_definition_id %in% num_zero_cohorts_ind) %>%
#     pull(cohort_name)
#   
#   cli::cli_alert_info("Cohorts with 0 subjects: {cohort_settings_zero_ind}")
# }
# 
# cohort_settings <- settings(cdm$antibiotics)
# 
# cli::cli_alert_info(" - Cohort checks finished")

