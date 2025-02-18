cli::cli_text("- GETTING TOP TEN INGREDIENTS ({Sys.time()})")

ingredients <- readr::read_csv(here("Cohorts", "ingredients.csv"))

ing_av <- cdm$concept %>%
  filter(domain_id == "Drug") %>%
  filter(concept_class_id == "Ingredient") %>%
  filter(standard_concept == "S") %>%
  select(c("concept_id", "concept_name", "concept_code")) %>%
  filter(concept_id %in% ingredients$concept_id) %>%
  collect()

ing_list <- setNames(as.list(ing_av$concept_id), paste0(ing_av$concept_code, "_", stringr::str_to_lower(ing_av$concept_name)))

cli::cli_alert(paste0("Ingredient level code for ",nrow(ing_av), " ingredients found"))

# Create a codelist for the antibiotics that are a combiantion of one or more ingredients.    
ingredient_desc <- getDrugIngredientCodes(
  cdm = cdm,
  name = ing_av$concept_name,
  type = "codelist",
  nameStyle = "{concept_code}_{concept_name}"
)

cli::cli_alert(paste0("Descendent codes found for ",length(ingredient_desc), " ingredients"))

# Merge ingredient and descendent codelists, ensuring that concept ids are not repeated.
ing_all <- list()
for(i in names(ing_list)){
    ing_all[[i]] <- c(ingredient_desc[[i]],ing_list[[i]])
    ing_all[[i]] <- unique(ing_all[[i]])
}

names(ing_all) <- snakecase::to_snake_case(names(ing_all))

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
    slice_head(n = 10)
  
  top_ten_ingredients <- ing_all[names(ing_all) %in% all_concepts_counts$cohort_name]
    
   sum_ingredients <- summariseCohortCount(cohort = cdm$all_concepts) %>%
     filter(group_level %in% all_concepts_counts$cohort_name)
   
   results[["sum_ingredients"]] <- sum_ingredients
   
   omopgenerics::exportSummarisedResult(sum_ingredients, minCellCount = min_cell_count, path =  here("Results", db_name),
                                        fileName = paste0("top_ten_ingredients_", db_name))
    
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


  