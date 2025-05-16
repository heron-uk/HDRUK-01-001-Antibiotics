atc_codes <- readxl::read_excel("Cohorts/WHO-MHP-HPS-EML-2023.04-eng.xlsx",
                                sheet = "Access", skip = 3) %>%
  pull(`ATC code`) %>%
  paste(collapse = "|")

access_names <- readxl::read_excel("Cohorts/WHO-MHP-HPS-EML-2023.04-eng.xlsx",
                                   sheet = "Access", skip = 3) %>%
  select(Antibiotic) %>%
  mutate(Antibiotic = sub("/.*", "", Antibiotic)) %>%
  mutate(Antibiotic = sub("_.*", "", Antibiotic)) %>%
  mutate(Antibiotic = tolower(Antibiotic)) %>%
  mutate(Antibiotic = case_when(
    Antibiotic == "cefalexin" ~ "cephalexin",
    Antibiotic == "cefaloridine" ~ "cephaloridine",
    Antibiotic == "cefalotin" ~ "cephalothin",
    Antibiotic == "cefapirin" ~ "cephapirin",
    Antibiotic == "cefradine" ~ "cephradine",
    Antibiotic == "pivmecillinam" ~ "amdinocillin pivoxil",
    Antibiotic == "benzylpenicillin" ~ "penicillin G",
    Antibiotic == "phenoxymethylpenicillin" ~ "penicillin V",
    Antibiotic == "ceftezole" ~ "ceftezole sodium",
    Antibiotic == "metampicillin" ~ "methampicillin",
    Antibiotic == "flucloxacillin" ~ "floxacillin",
    Antibiotic == "mecillinam" ~ "amdinocillin",
    Antibiotic == "meticillin" ~ "methicillin",
    Antibiotic == "sulfadimidine" ~ "sulfamethazine",
    Antibiotic == "sulfafurazole" ~ "sulfisoxazole",
    Antibiotic == "sulfaisodimidine" ~ "sulfisomidine",
    Antibiotic == "sulfathiourea" ~ "urea",
    .default = Antibiotic
  )) %>%
  pull()
  

# Create codelists based on ATC codes.

atc_code_list <- getATCCodes(
  cdm = cdm,
  level = c("ATC 5th"),
  type = "codelist"
)

# Filter the list to only include antibiotics on watch list.
access_list_atc <- atc_code_list[grepl(atc_codes, names(atc_code_list))]

access_list_codes <- do.call(rbind, lapply(names(access_list_atc), function(drug) {
  data.frame(
    name = drug,
    concept_id = access_list_atc[[drug]],
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
    drug_name = concept_name
  ) %>%
  collect()

ingredients <- merge(drug_ingredient_codes, access_list_codes, by = "concept_id")

missing_ingredient <- names(access_list_atc)[!names(access_list_atc) %in% ingredients$name]

missing_ingredient_names <- names(access_list_atc)[!names(access_list_atc) %in% ingredients$name] %>%
  str_extract("(?<=_)[a-zA-Z]+(?=_)") %>%
  toupper()

# Extract the ingredient names from `missing_ingredient` to match with `missing_ingredient_names`
extracted_ingredient_names <- str_extract(missing_ingredient, "(?<=_)[a-zA-Z]+(?=_)") %>%
  toupper() # Convert to uppercase to match `missing_ingredient_names`

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

####
ingredients <- rbind(ingredients, missing_ingredient_codes) %>%
  mutate(drug_name = tolower(drug_name)) %>%
  mutate(drug_name = case_when(
    drug_name == "penicillin g" ~ "penicillin G",
    drug_name == "penicillin v" ~ "penicillin V",
    .default = drug_name
  )) %>%
  filter(drug_name %in% access_names)

missing_filt <- access_names[!access_names %in% ingredients$drug_name]

ing_filt <- ingredients %>%
  select(concept_id, drug_name) %>%
  distinct()
  
ingredients <- ingredients %>%
  mutate(atc = str_extract(name, "^[^_]+"))

colnames(ingredients)[colnames(ingredients) == "name"] <- "cohort_name"
colnames(ingredients)[colnames(ingredients) == "drug_name"] <- "ingredient_name"

# Every ATC code has one ingredient except for antibiotics which are combinations, in which case there are two.
ingredient_counts <- ingredients %>%
  group_by(cohort_name) %>%
  summarise(n = n())

write.csv(ingredients, here("Cohorts", "access_ingredients.csv"))
