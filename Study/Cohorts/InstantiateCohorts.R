cli::cli_alert_info("- Creating cohort set")

if(isTRUE(run_watch_list)){
  
top_ten_by_route <- stratifyByRouteCategory(top_ten_watch_list, cdm, keepOriginal = FALSE)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten",
  conceptSet = top_ten_by_route,
  gapEra = 7
)

cdm$top_ten <- cdm$top_ten |>
  requireDrugInDateRange(
    dateRange = studyPeriod)

route_counts <- cohortCount(cdm$top_ten) |>
  filter(number_records > 0) |>
  pull(cohort_definition_id)

cdm$top_ten <- cdm$top_ten |>
  subsetCohorts(cohortId = route_counts)

} else 
  
  cdm <- generateDrugUtilisationCohortSet(
    cdm = cdm,
    name = "top_ten",
    conceptSet = top_ten_ingredients,
    gapEra = 7
  )

cli::cli_alert_success("- Created cohort set")
