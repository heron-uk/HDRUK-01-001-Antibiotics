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

top_ten_by_route <- stratifyByRouteCategory(top_ten, cdm, keepOriginal = FALSE)

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

ingredient_cohorts <- merge(settings(cdm$top_ten), top_ten_ingredients, by = "cohort_name")

cli::cli_alert_success("- Created cohort set")
