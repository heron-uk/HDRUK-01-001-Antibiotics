if (isTRUE(run_watch_list)) {
  cli::cli_text("- GETTING TOP TEN WATCH LIST ANTIBIOTICS ({Sys.time()})")

  # Create codelists for fosfomycin and/or minocycline for oral only (as specified in Watch List)
  # Only if these drugs are present in database.
  if ("956653" %in% ing_av | "1708880" %in% ing_av) {
    desc_code_lists_1 <- getDrugIngredientCodes(
      cdm = cdm,
      name = ing_av[ing_av %in% c("956653", "1708880")],
      ingredientRange = c(1, 1),
      routeCategory = c("oral"),
      nameStyle = "{concept_code}_{concept_name}"
    )
  } else {
    # Create empty list if no drugs in database to avoid errors later on.
    desc_code_lists_1 <- NULL
  }

  # Create codelists for drugs with oral and injectable routes only 
  # (as specified in Watch List)
  # Only if these drugs are present in database.
  if ("1784749" %in% ing_av || 
      "19035924" %in% ing_av ||
      "1836191" %in% ing_av || 
      "1707687" %in% ing_av) {
    desc_code_lists_2 <- getDrugIngredientCodes(
      cdm = cdm,
      name = ing_av[ing_av %in% c("1784749", "19035924", "1836191", "1707687")],
      ingredientRange = c(1, 1),
      routeCategory = c("oral", "injectable"),
      nameStyle = "{concept_code}_{concept_name}"
    )
  } else {
    # Create empty list if no drugs in database to avoid errors later on.
    desc_code_lists_2 <- NULL
  }

  # Create codelists for combination drugs only (as specified in Watch List)
  # Only if these drugs are present in database.
  # Create a codelist for the antibiotics that are a combiantion of two ingredients.
  if ("1746114" %in% ing_av | "1778262" %in% ing_av) {
    desc_code_lists_3 <- getDrugIngredientCodes(
      cdm = cdm,
      name = ing_av[ing_av %in% c("1746114", "1778262")],
      ingredientRange = c(2, 2),
      type = "codelist_with_details",
      nameStyle = "{concept_code}"
    )
  } else {
    # Create empty list if no drugs in database to avoid errors later on.
    desc_code_lists_3 <- NULL
  }

  # Filter to only include the combinations that are mentioned on the Watch List.
  # Filter code lists to only include combinations in Watch List.
  # i.e. piperacillin and tazobactam, imipenem and cilistatin.
  if (is.null(desc_code_lists_3[["8339"]]) == FALSE) {
    pip_tazo <- desc_code_lists_3[["8339"]] %>%
      filter(grepl("tazobactam", concept_name, ignore.case = TRUE))
  }

  if (is.null(desc_code_lists_3[["5690"]]) == FALSE) {
    imip_cila <- desc_code_lists_3[["5690"]] %>%
      filter(grepl("cilastatin", concept_name, ignore.case = TRUE))
  }

  # Get routes included in database
  routes <- getRouteCategories(cdm)

  # Create codelists for the antibiotics where all routes excluding topical are considered.
  # Sometimes routes are not in database. If this is the case, the cohort will be made without specified routes.
  if (length(routes) > 0) {
    desc_code_lists_4 <- getDrugIngredientCodes(
      cdm = cdm,
      name = ing_av[!ing_av %in% c("1784749", 
                                   "19035924", 
                                   "1836191", 
                                   "1707687",
                                   "1797258", 
                                   "1778262", 
                                   "956653", 
                                   "1708880")],
      ingredientRange = c(1, 1),
      routeCategory = routes[routes != "topical"],
      nameStyle = "{concept_code}_{concept_name}"
    )
  } else if (length(routes == 0)) {
    desc_code_lists_4 <- getDrugIngredientCodes(
      cdm = cdm,
      name = ing_av[!ing_av %in% c("1784749", 
                                   "19035924", 
                                   "1836191", 
                                   "1707687", 
                                   "1797258", 
                                   "1778262", 
                                   "956653", 
                                   "1708880")],
      nameStyle = "{concept_code}_{concept_name}"
    )
  } else {
    # Create empty list if no drugs in database to avoid errors later on.
    desc_code_lists_4 <- NULL
  }

  # Combine codelists.
  # Merge all descendent codelists.
  desc_code_lists <- c(desc_code_lists_1, desc_code_lists_2, desc_code_lists_4)

  # Add the concept codes for the combined antibiotics to the relevant codelists (if present).
  if (exists("pip_tazo") & nrow(pip_tazo) > 0) {
    desc_code_lists[["piperacillin_tazobactam"]] <- c(pip_tazo$concept_id)
  }

  if (exists("imip_cila") & nrow(imip_cila) > 0) {
    desc_code_lists[["imipenem_cilastatin"]] <- c(imip_cila$concept_id)
  }

  cli::cli_alert(paste0("Descendent codes found for ", 
                        length(desc_code_lists), " ingredients"))

  names(desc_code_lists) <- paste0(
    "wl_",
    omopgenerics::toSnakeCase(names(desc_code_lists))
  )

  # Create a cohort for each antibiotic using the ingredient codelists.
  cdm$watch_list <- conceptCohort(cdm = cdm, 
                                  conceptSet = desc_code_lists, 
                                  name = "watch_list") |>
    requireInDateRange(
      indexDate = "cohort_start_date",
      dateRange = study_period
    )

  # Get record counts for each antibiotic and filter the list to only include the 10
  # most prescribed.
  watch_list_antibiotics <- cohortCount(cdm$watch_list) |>
    filter(number_records > 0) %>%
    arrange(desc(number_records)) %>%
    slice_head(n = 10) |>
    left_join(settings(cdm$watch_list),
      by = "cohort_definition_id"
    )


  # Filter the codelists to only include the top ten.
  top_ten_watch_list <- desc_code_lists[names(desc_code_lists) %in%
    watch_list_antibiotics$cohort_name]

  sum_watch_list <- summariseCohortCount(cohort = cdm$watch_list) %>%
    filter(group_level %in% watch_list_antibiotics$cohort_name)

  results[["sum_watch_list"]] <- sum_watch_list
}
