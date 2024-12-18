cli::cli_alert_info("- Creating cohort set")

cdm$top_ten <- conceptCohort(
  cdm = cdm,
  name = "top_ten",
  conceptSet = top_ten
)

cdm$top_ten |>
  requireInDateRange(dateRange = studyPeriod)

cdm$top_ten_by_route <- conceptCohort(
  cdm = cdm,
  name = "top_ten_by_route",
  conceptSet = top_ten_by_route
)

cdm$top_ten_by_route |>
  requireInDateRange(dateRange = studyPeriod)

cli::cli_alert_success("- Created cohort set")
