atc_codes <- readxl::read_excel("Cohorts/WHO-MHP-HPS-EML-2023.04-eng.xlsx",
                                                    sheet = "Watch", skip = 3) %>%
  pull(`ATC code`) %>%
  paste(collapse = "|")

atc_code_list <- getATCCodes(cdm = cdm,
                             level = c("ATC 5th"),
                             type = "codelist") 

# Filter the list using the combined pattern
watch_list_atc <- atc_code_list[grepl(atc_codes, names(atc_code_list))]
  
count <- summariseCodeUse(
  x = watch_list_atc,
  cdm = cdm,
  countBy = "record",
  byConcept = TRUE,
  byYear = TRUE
) 
  
top_ten_drugs <- count %>% 
  mutate(estimate_value = as.numeric(estimate_value)) %>%
  filter(strata_level >= 2012,
         strata_name == "year",
         variable_name == "overall") %>%
  group_by(group_level) %>%
  summarise(count = sum(estimate_value)) %>% 
  arrange(desc(count)) %>%
  slice_head(n = 10) %>%
  pull(group_level)

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
  


