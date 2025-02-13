if(isTRUE(run_watch_list)) {
  cli::cli_text("- GETTING TOP TEN WATCH LIST ANTIBIOTICS ({Sys.time()})")
  
# Create codelists for fosfomycin and/or minocycline for oral only (as specified in Watch List)
# Only if these drugs are present in database.
if("fosfomycin" %in%  ing_av$ingredient_name | "minocycline" %in%  ing_av$ingredient_name){
  desc_code_lists_1 <- getDrugIngredientCodes(
    cdm = cdm,
    name = unique(ing_av$name[ing_av$ingredient_name %in% c("fosfomycin", "minocycline")]),
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
  name = unique(ing_av$name[ing_av$ingredient_name %in% c("kanamycin", "rifamycin SV", "streptomycin", "vancomycin")]),
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
  name =  unique(ing_av$name[ing_av$ingredient_name %in% c("piperacillin", "imipenem")]),
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
  name = unique(ing_av$name[!ing_av$ingredient_name %in% c("kanamycin", "rifamycin SV", "streptomycin", "vancomycin", "cilastatin", "imipenem", "fosfomycin", "minocycline")]),
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

names(ing_desc) <- snakecase::to_snake_case(names(ing_desc))

# Create a cohort for each antibiotic using the ingredient codelists.
cdm$watch_list <- conceptCohort(cdm = cdm, conceptSet = ing_desc, name = "watch_list") |>
  requireInDateRange(
    indexDate = "cohort_start_date",
    dateRange = c(as.Date(study_start), as.Date(maxObsEnd))
  )

# Get record counts for each antibiotic and filter the list to only include the 10
# most prescribed.
top_ten_antibiotics <- merge(cohortCount(cdm$watch_list), settings(cdm$watch_list), by = "cohort_definition_id") %>%
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
top_ten_watch_list <- ing_desc[names(ing_desc) %in% top_ten_antibiotics$cohort_name]

top_ten_antibiotics <- merge(top_ten_antibiotics, ingredients, by = c("ingredient_name")) %>%
  select(c(ingredient_name, cohort_definition_id, number_records, number_subjects, cdm_version,vocabulary_version,concept_id)) %>%
  distinct() %>%
  mutate(type = "watch_list_level")

sum_watch_list <- summariseCohortCount(cohort = cdm$watch_list) %>%
  filter(group_level %in% top_ten_antibiotics$ingredient_name)

results[["sum_watch_list"]] <- sum_watch_list

omopgenerics::exportSummarisedResult(sum_watch_list, minCellCount = min_cell_count, path =  here("Results", db_name),
                                     fileName = paste0("top_ten_watch_list_", db_name))
}
