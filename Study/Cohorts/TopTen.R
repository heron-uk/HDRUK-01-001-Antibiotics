# Load the concept codes for each antibiotic.
concept_codes <- read.csv(here("Cohorts", "concept_codes.csv"))[,2:3]

concept_codes$concept_id <- lapply(concept_codes$concept_id, function(x) {
  as.numeric(unlist(strsplit(x, ",\\s*")))
})

concept_list <- setNames(concept_codes$concept_id, concept_codes$name)

# Create a cohort for each antibiotic.
cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = concept_list, name = "watch_list") |>
  requireInDateRange(
    indexDate = "cohort_start_date",
    dateRange = c(as.Date(study_start), as.Date(maxObsEnd)) 
  )

# Get record counts for each antibiotic and filter the list to only include the 10
# most prescribed.
top_ten_drugs <- merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
  arrange(desc(number_records)) %>%
  slice_head(n = 10) %>%
  mutate(cohort_name = sub("^([a-z0-9]+)_", "\\U\\1_", cohort_name, perl = TRUE)) %>%
  pull(cohort_name)

top_ten <- concept_list[names(concept_list) %in% top_ten_drugs]

### Get ingredient codes
top_ten_codes <- do.call(rbind, lapply(names(top_ten), function(drug) {
  data.frame(
    name = drug,
    concept_id = top_ten[[drug]],
    stringsAsFactors = FALSE
  )
}))

# Load all the ingredient codes in the CDM.
drug_ingredient_codes <- cdm$concept %>%
  filter(domain_id == "Drug") %>%
  filter(concept_class_id == "Ingredient") %>%
  filter(standard_concept == "S") %>%
  select(c("concept_id", "concept_name")) %>%
  rename(
    drug_name = concept_name) %>%
  collect()

# Filter to only get the ingredients in the top ten antibiotics.
top_ten_ingredients <- top_ten_codes %>%
  filter(concept_id %in% drug_ingredient_codes$concept_id)