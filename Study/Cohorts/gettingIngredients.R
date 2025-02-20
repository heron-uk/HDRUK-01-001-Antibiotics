atc_codes <- readxl::read_excel("Cohorts/WHO-MHP-HPS-EML-2023.04-eng.xlsx",
                                sheet = "Watch", skip = 3) %>%
  pull(`ATC code`) %>%
  paste(collapse = "|")

# Create codelists based on ATC codes.

atc_code_list <- getATCCodes(cdm = cdm,
                             level = c("ATC 5th"),
                             type = "codelist")

# Filter the list to only include antibiotics on watch list.
watch_list_atc <- atc_code_list[grepl(atc_codes, names(atc_code_list))]

watch_list_codes <- do.call(rbind, lapply(names(watch_list_atc), function(drug) {
  data.frame(
    name = drug,
    concept_id = watch_list_atc[[drug]],
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

ingredients <- merge(drug_ingredient_codes, watch_list_codes, by = "concept_id") 

missing_ingredient <- names(watch_list_atc)[!names(watch_list_atc) %in% ingredients$name] 

missing_ingredient_names <- names(watch_list_atc)[!names(watch_list_atc) %in% ingredients$name] %>%
  str_extract("(?<=_)[a-zA-Z]+(?=_)") %>%
  toupper()

# Extract the ingredient names from `missing_ingredient` to match with `missing_ingredient_names`
extracted_ingredient_names <- str_extract(missing_ingredient, "(?<=_)[a-zA-Z]+(?=_)") %>%
  toupper()  # Convert to uppercase to match `missing_ingredient_names`

# Create a data frame that associates each ingredient name with its drug code (from `missing_ingredient`)
ingredient_code_mapping <- data.frame(
  ingredient_name = extracted_ingredient_names,
  drug_code = missing_ingredient
)

# Now, use this mapping to join with your `drug_ingredient_codes` table
missing_ingredient_codes <- drug_ingredient_codes %>%
  filter(drug_name %in% missing_ingredient_names) %>%
  left_join(ingredient_code_mapping, by = c("drug_name" = "ingredient_name")) %>%
  mutate(name = ifelse(!is.na(drug_code), drug_code, NA)) %>%
  select(concept_id, drug_name, name)

########

no_atc <- drug_ingredient_codes %>%
  filter(drug_name %in% c("micronomicin", "CEFOSELIS")) %>%
  mutate(name = drug_name)
           
####
ingredients <- rbind(ingredients, missing_ingredient_codes)
ingredients <- rbind(ingredients, no_atc)

ingredients <- ingredients %>%
  mutate(atc = str_extract(name, "^[^_]+")) %>%
  mutate(atc = ifelse(atc %in% c("micronomicin", "CEFOSELIS"), "NO ATC", atc)) %>%
  filter(drug_name != "sodium chloride")

colnames(ingredients)[colnames(ingredients) == "name"] <- "cohort_name"
colnames(ingredients)[colnames(ingredients) == "drug_name"] <- "ingredient_name"

ingredients <- ingredients %>%
  # Use samne ingredient for rifamycin as DARWIN study.
  filter(!ingredient_name %in% "rifamycins") %>%
  filter(
    cohort_name != "J01CR05_piperacillin_and_beta_lactamase_inhibitor_parenteral" |
      (cohort_name == "J01CR05_piperacillin_and_beta_lactamase_inhibitor_parenteral" & 
         ingredient_name %in% c("piperacillin", "tazobactam"))
  ) %>%
  filter(
    cohort_name != "J01DH51_imipenem_and_cilastatin_parenteral" |
      (cohort_name == "J01DH51_imipenem_and_cilastatin_parenteral" & 
         ingredient_name %in% c("imipenem", "cilastatin"))
  ) %>%
  
  filter(
    cohort_name != "J01DH55_panipenem_and_betamipron_parenteral" |
      (cohort_name == "J01DH55_panipenem_and_betamipron_parenteral" & 
         ingredient_name %in% c("panipenem"))
  ) %>%
  # Change ingredient for tosufloxacin to match ingredient used in DARWIN study.
  mutate(ingredient_name = ifelse(cohort_name == "J01MA22_tosufloxacin_systemic", "TOSUFLOXACIN", ingredient_name)) %>%
  mutate(concept_id = ifelse(ingredient_name == "TOSUFLOXACIN", 36857682, concept_id)) %>%
  distinct()

# Every ATC code has one ingredient except for antibiotics which are combinations, in which case there are two.
ingredient_counts <- ingredients %>%
  group_by(cohort_name) %>%
  summarise(n = n())

    write.csv(ingredients, here("Cohorts", "ingredients.csv"))

         