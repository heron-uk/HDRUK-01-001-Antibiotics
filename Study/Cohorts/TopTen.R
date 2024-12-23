atc_codes <- readxl::read_excel("Cohorts/WHO-MHP-HPS-EML-2023.04-eng.xlsx",
                                                    sheet = "Watch", skip = 3) %>%
  pull(`ATC code`) %>%
  paste(collapse = "|")

atc_code_list <- getATCCodes(cdm = cdm,
                             level = c("ATC 5th"),
                             type = "codelist") 

# Filter the list using the combined pattern
watch_list_atc <- atc_code_list[grepl(atc_codes, names(atc_code_list))]

cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = watch_list_atc, name = "watch_list") |>
  requireInDateRange(
    indexDate = "cohort_start_date",
    dateRange = studyPeriod
  )
  
top_ten_drugs <- merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
  arrange(desc(number_records)) %>%
  slice_head(n = 10) %>%
  mutate(cohort_name = sub("^([a-z0-9]+)_", "\\U\\1_", cohort_name, perl = TRUE)) %>%
  pull(cohort_name)

top_ten <- atc_code_list[names(atc_code_list) %in% top_ten_drugs]

top_ten_by_route <- stratifyByRouteCategory(top_ten, cdm, keepOriginal = TRUE)

### Get ingredient codes

top_ten_codes <- do.call(rbind, lapply(names(top_ten), function(drug) {
  data.frame(
    name = drug,
    concept_id = top_ten[[drug]],
    stringsAsFactors = FALSE
  )
}))

drug_ingredient_codes <- cdm$concept %>%
  filter(domain_id == "Drug") %>%
  filter(concept_class_id == "Ingredient") %>%
  filter(standard_concept == "S") %>%
  select(c("concept_id", "concept_name")) %>%
  collect()

top_ten_ingredients <- top_ten_codes %>%
  filter(concept_id %in% drug_ingredient_codes$concept_id)
  


