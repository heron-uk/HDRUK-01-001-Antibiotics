if(isTRUE(run_watch_list)) {
  cli::cli_text("- GETTING TOP TEN WATCH LIST ANTIBIOTICS ({Sys.time()})")
# Load csv file with ingredient information.  
ingredients <- read.csv(here("Cohorts", "ingredients.csv")) %>%
  select(-X)

# Get a table of ingredient names and concept id.
# ingredient name changed to all lower case for consistency
ingredient_codes <- ingredients %>%
  mutate(ingredient_name = tolower(ingredient_name)) %>%
  select(c(ingredient_name, concept_id)) %>%
  distinct()

# Create codelist with just ingredient codes.
ing_list <- setNames(as.list(ingredient_codes$concept_id), ingredient_codes$ingredient_name)

# Ingredient names might have different capiltalisations in different databases so I've made two columns.
# name is the ingredient name as written in the database
# ingredient_name is the name in all lower case. This column is used to merge with the ingredients.csv file.

ing_av <- tibble(
  name = availableIngredients(cdm)) %>%
  mutate(ingredient_name = tolower(name))

# Only include antibiotic ingredients that are present in the cdm.
ing_av <- merge(ingredient_codes, ing_av, by = "ingredient_name")

cli::cli_alert(paste0("Ingredient level code for ", nrow(ing_av), " ingredients found"))

# Create codelists for fosfomycin and/or minocycline for oral only (as specified in Watch List)
# Only if these drugs are present in database.
if("fosfomycin" %in%  ing_av$ingredient_name | "minocycline" %in%  ing_av$ingredient_name){
  desc_code_lists_1 <- getDrugIngredientCodes(
    cdm = cdm,
    name = ing_av$name[ing_av$ingredient_name %in% c("fosfomycin", "minocycline")],
    ingredientRange = c(1,1),
    routeCategory = c("oral"),
    nameStyle = "{concept_name}"
  )
} else {
  # Create empty list if no drugs in database to avoid errors later on.
  desc_code_lists_1 <- NULL
}

# Create codelists for drugs with oral and injectable routes only (as specified in Watch List)
# Only if these drugs are present in database.
if("kanamycin" %in% ing_av$ingredient_name | "rifamycin SV" %in% ing_av$ingredient_name | "streptomycin" %in% ing_av$ingredient_name | "vancomycin" %in% ing_av$ingredient_name){
  desc_code_lists_2 <- getDrugIngredientCodes(
  cdm = cdm,
  name = ing_av$name[ing_av$ingredient_name %in% c("kanamycin", "rifamycin SV", "streptomycin", "vancomycin")],
  ingredientRange = c(1,1),
  routeCategory = c("oral", "injectable"),
  nameStyle = "{concept_name}"
  )} else {
    # Create empty list if no drugs in database to avoid errors later on.
    desc_code_lists_2 <- NULL
}

# Create codelists for combination drugs only (as specified in Watch List)
# Only if these drugs are present in database.
# Create a codelist for the antibiotics that are a combiantion of two ingredients.    
if("piperacillin" %in% ing_av$ingredient_name | "imipenem" %in% ing_av$ingredient_name){
  desc_code_lists_3 <- getDrugIngredientCodes(
  cdm = cdm,
  name =  ing_av$name[ing_av$ingredient_name %in% c("piperacillin", "imipenem")],
  ingredientRange = c(2, 2),
  type = "codelist_with_details",
  nameStyle = "{concept_name}"
  )}else{
    # Create empty list if no drugs in database to avoid errors later on.
  desc_code_lists_3 <- NULL
}

# Filter to only include the combinations that are mentioned on the Watch List.
# Filter code lists to only include combinations in Watch List.
# i.e. piperacillin and tazobactam, imipenem and cilistatin.
if(is.null(desc_code_lists_3[["piperacillin"]]) == FALSE){
pip_tazo <- desc_code_lists_3[["piperacillin"]] %>%
  filter(grepl("tazobactam", concept_name, ignore.case = TRUE))
}

if(is.null(desc_code_lists_3[["imipenem"]]) == FALSE){
imip_cila <- desc_code_lists_3[["imipenem"]] %>%
  filter(grepl("cilastatin", concept_name, ignore.case = TRUE))
}

# Get routes included in database
routes <- getRouteCategories(cdm)

# Create codelists for the antibiotics where all routes excluding topical are considered.
# Sometimes routes are not in database. If this is the case, the cohort will be made without specified routes.
if(length(routes) > 0){
desc_code_lists_4 <- getDrugIngredientCodes(
  cdm = cdm,
  name = ing_av$name[!ing_av$ingredient_name %in% c("kanamycin", "rifamycin SV", "streptomycin", "vancomycin", "cilastatin", "imipenem", "fosfomycin", "minocycline")],
  ingredientRange = c(1, 1),
  routeCategory = routes[routes != "topical"],
  nameStyle = "{concept_name}"
)} else if(length(routes == 0)){
desc_code_lists_4 <- getDrugIngredientCodes(
  cdm = cdm,
  name = ing_av$name[!ing_av$ingredient_name %in% c("kanamycin", "rifamycin SV", "streptomycin", "vancomycin", "cilastatin", "imipenem", "fosfomycin", "minocycline")],
  nameStyle = "{concept_name}"
)} else {
  # Create empty list if no drugs in database to avoid errors later on.
  desc_code_lists_4 <- NULL
}

# Combine codelists.
# Merge all descendent codelists.
desc_code_lists <- c(desc_code_lists_1, desc_code_lists_2, desc_code_lists_4)

# Add the concept codes for the combined antibiotics to the relevant codelists (if present).
if("pipercillin" %in% ing_av$ingredient_name){
desc_code_lists[["piperacillin"]] <- c(desc_code_lists_4[["piperacillin"]], pip_tazo$concept_id)
}
if("tazobactam" %in% ing_av$ingredient_name){
desc_code_lists[["tazobactam"]] <- c(desc_code_lists[["tazobactam"]], pip_tazo$concept_id)
}

cli::cli_alert(paste0("Descendent codes found for ", length(desc_code_lists), " ingredients"))

ing_desc <- list()

for(i in ing_av$ingredient_name){
  ing_desc[[i]] <- c(desc_code_lists[[i]],ing_list[[i]])
  ing_desc[[i]] <- unique(ing_desc[[i]])
}

if("imipenem" %in% ing_av$ingredient_name & "cilastatin" %in% ing_av$ingredient_name){
ing_desc[["imipenem_cilastatin"]] <- unique(c(imip_cila$concept_id, ing_list[["imipenem"]], ing_list[["cilastatin"]]))
}

# Create a cohort for each antibiotic using the ingredient codelists.
cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = ing_desc, name = "watch_list") |>
  requireInDateRange(
    indexDate = "cohort_start_date",
    dateRange = c(as.Date(study_start), as.Date(maxObsEnd))
  )

# Get record counts for each antibiotic and filter the list to only include the 10
# most prescribed.
top_ten_drugs <- merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
  # Need to add rows for imipenem_2540_cilastatin since this was not included in the ingredients csv file.
  bind_rows(
    # Add a row for "imipenem"
    merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
      filter(cohort_name == "imipenem_cilastatin") %>%
      mutate(cohort_name = "imipenem"),
    # Add a row for "cilastatin"
    merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
      filter(cohort_name == "imipenem_cilastatin") %>%
      mutate(cohort_name = "cilastatin")) %>%
  # Arrange the table in descending order based on the number of records and then filter to only include
  # the 10 most prescribed antibiotics.
  filter(number_records > 0) %>%
  arrange(desc(number_records)) %>%
  slice_head(n = 10) %>%
  mutate(ingredient_name = cohort_name)

# Filter the codelists to only include the top ten.
top_ten_watch_list <- ing_desc[names(ing_desc) %in% top_ten_drugs$cohort_name]

top_ten_drugs <- merge(top_ten_drugs, ingredients, by = c("ingredient_name")) %>%
  select(c(ingredient_name, cohort_definition_id, number_records, number_subjects, cdm_version,vocabulary_version,concept_id)) %>%
  distinct()

# Export a suppressed summary table with the counts for top ten antibiotics.
suppressed_table <- top_ten_drugs %>%
  mutate(number_records = ifelse(number_records < min_cell_count, paste("< ", min_cell_count), number_records)) %>%
  mutate(number_subjects = ifelse(number_subjects < min_cell_count,  paste("< ", min_cell_count), number_subjects)) %>%
  mutate(type = "watch_list_level")

write.csv(suppressed_table, here(resultsFolder, paste0("top_ten_watch_list_",db_name, ".csv")))
}
