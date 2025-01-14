cli::cli_alert_info("- Creating cohort set")

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten",
  conceptSet = top_ten,
  gapEra = 7
)

cdm$top_ten <- cdm$top_ten |>
  requireDrugInDateRange(
    dateRange = studyPeriod)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten_by_route",
  conceptSet = top_ten_by_route,
  gapEra = 7
)

cdm$top_ten_by_route <- cdm$top_ten_by_route |>
  requireDrugInDateRange(
    dateRange = studyPeriod) 

route_counts <- cohortCount(cdm$top_ten_by_route) %>%
  filter(number_records > 0) %>%
  pull(cohort_definition_id)

cdm$top_ten_by_route <- cdm$top_ten_by_route |>
  subsetCohorts(cohortId = route_counts)

cli::cli_alert_success("- Created cohort set")
