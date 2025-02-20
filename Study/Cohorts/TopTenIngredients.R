cli::cli_text("- GETTING TOP TEN INGREDIENTS ({Sys.time()})")

ingredients <- readr::read_csv(here("Cohorts", "ingredients.csv"))

ing_av <- cdm$concept %>%
  filter(domain_id == "Drug") %>%
  filter(concept_class_id == "Ingredient") %>%
  filter(standard_concept == "S") %>%
  select(c("concept_id", "concept_name", "concept_code")) %>%
  filter(concept_id %in% ingredients$concept_id) %>%
  pull(concept_id)

cli::cli_alert(paste0("Ingredient level code for ",length(ing_av), " ingredients found"))

# Create a codelist for the antibiotics that are a combiantion of one or more ingredients.    
ingredient_desc <- getDrugIngredientCodes(
  cdm = cdm,
  name = ing_av,
  type = "codelist",
  nameStyle = "{concept_code}_{concept_name}"
)

cli::cli_alert(paste0("Descendent codes found for ",length(ingredient_desc), " ingredients"))

names(ingredient_desc) <- snakecase::to_snake_case(names(ingredient_desc))

# If there aren't any codelists in ing_all then the next steps are skipped.
if(length(ingredient_desc) > 0){
  # Creates cohort for all antibiotics
  cdm$ing_all <- conceptCohort(cdm = cdm, conceptSet = ingredient_desc, name = "ing_all") %>%
    requireInDateRange(
      indexDate = "cohort_start_date",
      dateRange = c(as.Date(study_start), as.Date(maxObsEnd)) 
    )
  
  # Gets top ten antibiotics using record counts.
  all_routes_counts <- merge(cohortCount(cdm$ing_all), settings(cdm$ing_all), by = "cohort_definition_id") %>%
    filter(number_records > 0) %>%
    arrange(desc(number_records)) %>%
    slice_head(n = 10)
  
  top_ten_ingredients <- ingredient_desc[names(ingredient_desc) %in% all_routes_counts$cohort_name]
    
   sum_ingredients <- summariseCohortCount(cohort = cdm$ing_all) %>%
     filter(group_level %in% all_routes_counts$cohort_name)
   
   results[["sum_ingredients"]] <- sum_ingredients
    
} else if(length(ing_all) == 0){
  cli::cli_abort("No ingredients or descendents found!")
  
}

# If there are no descendant codes (i.e. antibiotics only mapped to ingredient),
 # then go straight to DED.
if(length(ingredient_desc) == 0 ){
  cli::cli_alert("No descendent codes found. Ingredient level only.")
  run_watch_list <- FALSE
} else {
  run_watch_list <- TRUE
}


  