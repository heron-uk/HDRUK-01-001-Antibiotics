atc_codes <- readxl::read_excel("Cohorts/WHO-MHP-HPS-EML-2023.04-eng.xlsx",
                                sheet = "Watch", skip = 3) %>%
  pull(`ATC code`) %>%
  paste(collapse = "|")

#

atc_code_list <- getATCCodes(cdm = cdm,
                             level = c("ATC 5th"),
                             type = "codelist")

# Create codelists based on ingredients for antibiotics without ATC codes.

ingredient_code_list <- getDrugIngredientCodes(cdm = cdm,
                                               name = c("cefoselis", "micronomicin"))

# Filter the list using the combined pattern
watch_list_atc <- atc_code_list[grepl(atc_codes, names(atc_code_list))]
watch_list_codes <- c(watch_list_atc, ingredient_code_list)

# Create a cohort for each antibiotic.
cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = watch_list_codes, name = "watch_list") |>
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

top_ten <- watch_list_codes[names(watch_list_codes) %in% top_ten_drugs]


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