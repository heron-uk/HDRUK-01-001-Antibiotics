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

concept_codes <- tibble(
  name = names(watch_list_codes),
  concept_id = sapply(watch_list_codes, toString)
)

write.csv(as.data.frame(concept_codes), here("Cohorts", "concept_codes.csv"))
