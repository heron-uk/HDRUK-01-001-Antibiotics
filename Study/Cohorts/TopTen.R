ingredients <- read.csv(here("Cohorts", "ingredients.csv")) %>%
  select(-X)

ingredient_names <- ingredients %>%
  pull(ingredient_name) %>%
  unique()

# Create codelists for the antibiotics where only oral routes are considered.
  ingredient_code_lists_1 <- getDrugIngredientCodes(
    cdm = cdm,
    name = c("fosfomycin", "minocycline"),
    ingredientRange = c(1,1),
    routeCategory = c("oral")
  )

  # Create codelists for the antibiotics where only oral and parenteral routes are considered.  
  ingredient_code_lists_2 <- getDrugIngredientCodes(
  cdm = cdm,
  name = c("kanamycin", "rifamycin SV", "streptomycin", "vancomycin"),
  ingredientRange = c(1,1),
  routeCategory = c("oral", "injectable")
)

# Create a codelist for the antibiotics that are a combiantion of one or more ingredients.    
ingredient_code_lists_3 <- getDrugIngredientCodes(
  cdm = cdm,
  name = c("piperacillin", "imipenem"),
  ingredientRange = c(2, 2),
  type = "codelist_with_details"
)

# Filter to only include the combinations that are mentioned on the Watch List.
pip_tazo <- ingredient_code_lists_3[[1]] %>%
  filter(grepl("tazobactam", concept_name, ignore.case = TRUE))
imip_cila <- ingredient_code_lists_3[[2]] %>%
  filter(grepl("cilastatin", concept_name, ignore.case = TRUE))

routes <- getRouteCategories(cdm)

# Create codelists for the antibiotics where all routes excluding topical are considered.
ingredient_code_lists_4 <- getDrugIngredientCodes(
  cdm = cdm,
  name = ingredient_names[!ingredient_names %in% c("kanamycin", "rifamycin SV", "streptomycin", "vancomycin", "cilastatin", "imipenem", "fosfomycin", "minocycline")],
  ingredientRange = c(1, 1),
  routeCategory = routes[routes != "topical"]
)

# Combine codelists.
ingredient_code_lists <- c(ingredient_code_lists_1, ingredient_code_lists_2, ingredient_code_lists_4)

ingredient_code_lists[["8339_piperacillin"]] <- c(ingredient_code_lists_4[["8339_piperacillin"]], pip_tazo$concept_id)
ingredient_code_lists[["37617_tazobactam"]] <- c(ingredient_code_lists[["37617_tazobactam"]], pip_tazo$concept_id)
ingredient_code_lists[["5690_imipenem_2540_cilastatin"]] <- c(imip_cila$concept_id)


# Create a cohort for each antibiotic using the ingredient codelists.
cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = ingredient_code_lists, name = "watch_list") |>
  requireInDateRange(
    indexDate = "cohort_start_date",
    dateRange = c(as.Date(study_start), as.Date(maxObsEnd)) 
  )

# Get record counts for each antibiotic and filter the list to only include the 10
# most prescribed.
top_ten_drugs <- merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
  bind_rows(
    # Add a row for "imipenem"
    merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
      arrange(desc(number_records)) %>%
      mutate(ingredient_name = str_extract(cohort_name, "(?<=_).*")) %>%
      filter(ingredient_name == "imipenem_2540_cilastatin") %>%
      mutate(ingredient_name = "imipenem"),
    # Add a row for "cilastatin"
    merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
      arrange(desc(number_records)) %>%
      mutate(ingredient_name = str_extract(cohort_name, "(?<=_).*")) %>%
      filter(ingredient_name == "imipenem_2540_cilastatin") %>%
      mutate(ingredient_name = "cilastatin")) %>%
  arrange(desc(number_records)) %>%
  slice_head(n = 10) %>%
  mutate(ingredient_name = str_extract(cohort_name, "(?<=_).*"))

top_ten <- ingredient_code_lists[names(ingredient_code_lists) %in% top_ten_drugs$cohort_name]

top_ten_ingredients <- merge(ingredients, top_ten_drugs, by = "ingredient_name") %>%
  mutate(cohort_name = cohort_name.y) %>%
  select(c(cohort_name, ingredient_name, concept_id)) %>%
  distinct()
