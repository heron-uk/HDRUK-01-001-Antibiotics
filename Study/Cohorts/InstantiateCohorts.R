cli::cli_alert_info("- Creating cohort set")

if(isTRUE(run_watch_list)){

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten",
  conceptSet = top_ten_watch_list,
  gapEra = 7
) 

cdm$top_ten <- cdm$top_ten |>
  requirePriorObservation(indexDate = "cohort_start_date",
                          minPriorObservation = 30)

} else {
  
  cdm <- generateDrugUtilisationCohortSet(
    cdm = cdm,
    name = "top_ten",
    conceptSet = top_ten_ingredients,
    gapEra = 7
  ) 
  
  cdm$top_ten <- cdm$top_ten |>
    requirePriorObservation(indexDate = "cohort_start_date",
                            minPriorObservation = 30)
}

if(isTRUE(run_watch_list) & length(routes) > 0) {

top_ten_by_route <- stratifyByRouteCategory(top_ten_watch_list, cdm, keepOriginal = FALSE)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten_by_route",
  conceptSet = top_ten_by_route,
  gapEra = 7
)

top_ten_by_route <- stratifyByRouteCategory(top_ten_watch_list, cdm, keepOriginal = FALSE)

cdm$top_ten_by_route <- cdm$top_ten_by_route |>
  requirePriorObservation(indexDate = "cohort_start_date",
                          minPriorObservation = 30)

route_counts <- cohortCount(cdm$top_ten_by_route) |>
  filter(number_records > 0) |>
  pull(cohort_definition_id)

cdm$top_ten_by_route <- cdm$top_ten_by_route |>
  subsetCohorts(cohortId = route_counts)

}

cli::cli_alert_success("- Created cohort set")
