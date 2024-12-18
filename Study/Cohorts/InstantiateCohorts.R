# instantiate cancer cohorts
cli::cli_alert_info("- Getting top ten watch list antibiotics")

# get concept sets from cohorts----

codes <- codesFromConceptSet(here::here("Cohorts", "WatchList"), cdm)

# instantiate the cohorts with no prior history

cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = codes, name = "watch_list") |>
  requireInDateRange(
    indexDate = "cohort_start_date",
    dateRange = studyPeriod
  )

cli::cli_alert_success("- Got top ten watch list antibiotics")

cli::cli_alert_info("- Getting routes of top ten antibiotics")

top_ten_cohorts <- merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
  arrange(desc(number_records)) %>%
  slice_head(n = 10) %>%
  pull(cohort_definition_id) %>%
  as.vector()

cdm$watch_list <- cdm$watch_list |>
  subsetCohorts(cohortId = top_ten_cohorts)

#### Get top ten by route

top_ten_names <- settings(cdm$watch_list) %>%
  mutate(cohort_name = sub("_[^_]+$", "", cohort_name)) %>%
  pull(cohort_name)

if ("rifampicin" %in% top_ten_names) {
  top_ten_names[top_ten_names == "rifampicin"] <- "rifampin"
}

drug_ingredients <- getDrugIngredientCodes(
  cdm = cdm,
  name = top_ten_names
)

codes_routes <- stratifyByRouteCategory(drug_ingredients, cdm, keepOriginal = FALSE)

cdm <- generateDrugUtilisationCohortSet(
  cdm = cdm,
  name = "by_route",
  conceptSet = codes_routes
)

# filter so that only oral minocycline is included.
if ("minocycline" %in% top_ten_names) {
  min_routes <- settings(cdm$by_route) %>%
    filter(grepl("minocycline", cohort_name)) %>%
    filter(!grepl("oral", cohort_name))

  min_oral <- settings(cdm$by_route) %>%
    filter(!cohort_definition_id %in% min_routes$cohort_definition_id) %>%
    pull(cohort_definition_id)

  cdm$by_route |>
    subsetCohorts(cohortId = min_oral)
}

routes_counts <- cohortCount(cdm$by_route) %>%
  filter(number_records > 0)

cdm$by_route <- cdm$by_route |>
  subsetCohorts(cohortId = routes_counts$cohort_definition_id)

cdm$by_route <- cdm$by_route |>
  requireDrugInDateRange(
    dateRange = studyPeriod
  )

cli::cli_alert_success("- Got routes of top ten antibiotics")