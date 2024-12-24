cli::cli_alert_info("- Creating cohort set")

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten",
  conceptSet = top_ten,
  gapEra = 7
)

cdm$top_ten <- cdm$top_ten |>
  requirePriorDrugWashout(days = 30) |>
  requireObservationBeforeDrug(days = 30) |>
  requireDrugInDateRange(
    dateRange = studyPeriod)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten_by_route",
  conceptSet = top_ten_by_route,
  gapEra = 7
)

cdm$top_ten_by_route <- cdm$top_ten_by_route |>
  requirePriorDrugWashout(days = 30) |>
  requireObservationBeforeDrug(days = 30) |>
  requireDrugInDateRange(
    dateRange = studyPeriod)


cli::cli_alert_success("- Created cohort set")
