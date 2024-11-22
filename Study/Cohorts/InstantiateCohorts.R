# instantiate cancer cohorts
cli::cli_alert_info("- Getting watch list antibiotics")

# get concept sets from cohorts----

codes <- codesFromConceptSet(here::here("Cohorts", "WatchList"), cdm)

# instantiate the cohorts with no prior history 

cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = codes, name = "watch_list") |>
  requireInDateRange(indexDate = "cohort_start_date",
                     dateRange = studyPeriod)

cli::cli_alert_success("- Got watch list antibiotics")

cli::cli_alert_info("- Getting top ten antibiotics")

count_settings <- merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
  arrange(desc(number_records)) %>%
  slice_head(n = 10)

top_10 <- count_settings %>%
  pull(cohort_definition_id)

cdm$watch_list |> subsetCohorts(cohortId = top_10)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "top_ten",
  conceptSet = codes_ten
)

cdm$top_ten <- cdm$top_ten |>
  requireDrugInDateRange(
    dateRange = studyPeriod)

cli::cli_alert_success("- Got top ten antibiotics")