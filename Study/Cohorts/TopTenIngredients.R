cli::cli_text("- GETTING TOP TEN INGREDIENTS ({Sys.time()})")

ingredients <- read.csv(here("Cohorts", "ingredients.csv")) %>%
  select(-X)

# Get a table of ingredient names and concept id.
# ingredient name changed to all lower case for consistency
ingredient_codes <- ingredients %>%
  select(ingredient_name, concept_id) %>%
  mutate(ingredient_name = stringr::str_to_lower(ingredient_name)) %>%
  distinct()
  
# Create codelist with just ingredient codes.
ing_list <- setNames(as.list(ingredient_codes$concept_id), ingredient_codes$ingredient_name)

ing_av <- tibble(
  name = availableIngredients(cdm)) %>%
  mutate(ingredient_name = stringr::str_to_lower(name))

# Only include antibiotic ingredients that are present in the cdm.
ing_av <- merge(ingredient_codes, ing_av, by = "ingredient_name")

cli::cli_alert(paste0("Ingredient level code for ",nrow(ing_av), " ingredients found"))

# Create a codelist for the antibiotics that are a combiantion of one or more ingredients.    
ingredient_desc <- getDrugIngredientCodes(
  cdm = cdm,
  name = ing_av$name,
  type = "codelist",
  nameStyle = "{concept_name}"
)

cli::cli_alert(paste0("Descendent codes found for ",length(ingredient_desc), " ingredients"))

# Merge ingredient and descendent codelists, ensuring that concept ids are not repeated.
ing_all <- list()
for(i in ing_av$ingredient_name){
    ing_all[[i]] <- c(ingredient_desc[[i]],ing_list[[i]])
    ing_all[[i]] <- unique(ing_all[[i]])
}

# If there aren't any codelists in ing_all then the next steps are skipped.
if(length(ing_all) > 0){
  # Creates cohort for all antibiotics
  cdm$all_concepts <- conceptCohort(cdm = cdm, conceptSet = ing_all, name = "all_concepts") %>%
    requireInDateRange(
      indexDate = "cohort_start_date",
      dateRange = c(as.Date(study_start), as.Date(maxObsEnd)) 
    )
  
  # Gets top ten antibiotics using record counts.
  all_concepts_counts <- merge(cohortCount(cdm$all_concepts), settings(cdm$all_concepts), by = "cohort_definition_id") %>%
    filter(number_records > 0) %>%
    arrange(desc(number_records)) %>%
    slice_head(n = 10) %>%
    rename(ingredient_name = cohort_name)
  
  top_ten_ingredients <- ing_all[names(ing_all) %in% all_concepts_counts$ingredient_name]
  
  if(nrow(all_concepts_counts) > 0){
    suppressed_table <- merge(all_concepts_counts, ingredient_codes, by = "ingredient_name") %>%
      mutate(number_records = ifelse(number_records < min_cell_count, paste("< ", min_cell_count), number_records)) %>%
      mutate(number_subjects = ifelse(number_subjects < min_cell_count,  paste("< ", min_cell_count), number_subjects)) %>%
      mutate(type = "ingredient_level")
    
    write.csv(suppressed_table, here(resultsFolder, paste0("top_ten_ingredients_", db_name, ".csv")))
  }
} else if(length(ing_all) == 0){
  cli::cli_abort("No ingredients or descendents found!")
  
}

# If there are no descendant codes (i.e. antibiotics only mapped to ingredient),
 # then go straight to DED.
if(length(ingredient_desc) == 0 ){
  cli::cli_alert("No descendent codes found. DED performed at ingredient level only.")
  run_watch_list <- FALSE
} else {
  run_watch_list <- TRUE
}


  