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
if(length(validateConceptSetArgument(top_ten_ingredients)) > 0){
cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten_outcomes",
  conceptSet = top_ten_ingredients,
  gapEra = 7
)
cdm$top_ten <- cdm$top_ten_outcomes |>
  requirePriorObservation(
    indexDate = "cohort_start_date",
    minPriorObservation = 30,
    name = "top_ten"
  ) |>
  requireInDateRange(study_period) |>
  requireAge(c(0, 150))

for(i in seq_along(top_ten_ingredients)){
working_cohort_id <- getCohortId(cohort = cdm$top_ten, cohortName = names(top_ten_ingredients)[i])
results[[paste0("code_use_top_ten_ingredients_", i)]] <- summariseCohortCodeUse(top_ten_ingredients[i], 
                         cdm = cdm, 
                         cohortId = working_cohort_id,
                         cohortTable = "top_ten")
}
} else {
  cli::cli_alert_info("Empty concept set (top_ten_ingredients) - skip")
}

# watch list cohorts ------
if (isTRUE(run_watch_list)) {
  cli::cli_alert_info("- Creating watch list cohort")
  if(length(validateConceptSetArgument(top_ten_watch_list)) > 0){
  cdm <- generateDrugUtilisationCohortSet(
    cdm = cdm,
    name = "top_ten_wl_outcomes",
    conceptSet = top_ten_watch_list,
    gapEra = 7
  )
  cdm <- bind(cdm$top_ten_outcomes,
    cdm$top_ten_wl_outcomes,
    name = "top_ten_outcomes"
  )

  cdm$top_ten_wl <- cdm$top_ten_wl_outcomes |>
    requirePriorObservation(
      indexDate = "cohort_start_date",
      minPriorObservation = 30,
      name = "top_ten_wl"
    ) |>
    requireInDateRange(study_period) |>
    requireAge(c(0, 150))
  
  for(i in seq_along(top_ten_watch_list)){
    working_cohort_id <- getCohortId(cohort = cdm$top_ten_wl, cohortName = names(top_ten_watch_list)[i])
    results[[paste0("code_use_top_ten_watch_list_", i)]] <- summariseCohortCodeUse(top_ten_watch_list[i], 
                                                                                    cdm = cdm, 
                                                                                    cohortId = working_cohort_id,
                                                                                    cohortTable = "top_ten_wl")
  }
  
  cdm <- bind(cdm$top_ten,
    cdm$top_ten_wl,
    name = "top_ten"
  )
  }
} else {
  cli::cli_alert_info("Empty concept set (top_ten_watch_list) - skip")
}
# watch list cohorts stratified by route ------
if(length(validateConceptSetArgument(top_ten_watch_list)) > 0){
if (isTRUE(run_watch_list) && length(routes) > 0) {
  top_ten_by_route <- stratifyByRouteCategory(top_ten_watch_list,
    cdm,
    keepOriginal = FALSE
  )
  # route watch list: names start with rwl
  names(top_ten_by_route) <- paste0("r", names(top_ten_by_route))
  cdm <- generateDrugUtilisationCohortSet(
    cdm = cdm,
    name = "top_ten_rwl_outcomes",
    conceptSet = top_ten_by_route,
    gapEra = 7
  )

  cdm <- bind(cdm$top_ten_outcomes,
    cdm$top_ten_rwl_outcomes,
    name = "top_ten_outcomes"
  )

  cdm$top_ten_rwl <- cdm$top_ten_rwl_outcomes |>
    requirePriorObservation(
      indexDate = "cohort_start_date",
      minPriorObservation = 30,
      name = "top_ten_rwl"
    ) |>
    requireInDateRange(study_period) |>
    requireAge(c(0, 150))

  for(i in seq_along(top_ten_by_route)){
    working_cohort_id <- getCohortId(cohort = cdm$top_ten_rwl, cohortName = names(top_ten_by_route)[i])
    # only get code counts for those with subjects
    if(nrow(cohortCount(cdm$top_ten_rwl) |> 
      dplyr::filter(cohort_definition_id == working_cohort_id) |> 
      filter(number_records > 0))){
    results[[paste0("code_use_top_ten_by_route_", i)]] <- summariseCohortCodeUse(top_ten_by_route[i], 
                                                                                   cdm = cdm, 
                                                                                   cohortId = working_cohort_id,
                                                                                   cohortTable = "top_ten_rwl")
    }
  }
  
  cdm <- bind(cdm$top_ten,
    cdm$top_ten_rwl,
    name = "top_ten"
  )
}
} else {
  cli::cli_alert_info("Empty concept set (top_ten_watch_list) - skip")
  run_watch_list <- FALSE
}

cli::cli_alert_success("- Created cohort set")

# keep only cohorts with minimum count ------
top_ten_to_keep <- cohortCount(cdm$top_ten) |>
  filter(number_subjects > 0) |>
  pull("cohort_definition_id")
cdm$top_ten <- subsetCohorts(
  cohort = cdm$top_ten,
  cohortId = top_ten_to_keep,
  name = "top_ten"
)

top_ten_outcomes_to_keep <- cohortCount(cdm$top_ten_outcomes) |>
  filter(number_subjects > 0) |>
  pull("cohort_definition_id")
cdm$top_ten_outcomes <- subsetCohorts(
  cohort = cdm$top_ten_outcomes,
  cohortId = top_ten_outcomes_to_keep,
  name = "top_ten_outcomes"
)
