#if (run_indications == TRUE) {
  cli::cli_alert_info("- Getting indications")

  indications <- c(
    "respiratory infection",
    "urinary tract infection",
    "skin infection",
    "soft tissue infection",
    "ear infection",
    "eye infection",
    "gastrointestinal infection",
    "oral infection",
    "sexually transmitted infectious disease",
    "bone infection",
    "infectious disorder of joint",
    "sepsis",
    "meningitis",
    "postprocedural infection"
  )

  indication_codelists <- list()

  for (i in seq_along(indications)) {
    # Dynamically create the name and store the result in the list
    indication_codelists[[paste0("codelist_", indications[i])]] <- getCandidateCodes(
      cdm,
      keywords = indications[i],
      exclude = NULL,
      domains = "Condition",
      standardConcept = "Standard",
      searchInSynonyms = FALSE,
      searchNonStandard = FALSE,
      includeDescendants = TRUE,
      includeAncestor = FALSE
    ) %>%
      mutate(name = indications[i])
  }

  # Combine the list of data frames into one large data frame
  all_codes <- do.call(rbind, indication_codelists)

  rownames(all_codes) <- NULL

  all_codes_grouped <- all_codes %>%
    group_by(name) %>%
    summarise(
      codes = list(concept_id),
      code_count = n(),
      .groups = "drop"
    )

  names_list <- setNames(all_codes_grouped$codes, all_codes_grouped$name)

  #######

  cdm$indications <- conceptCohort(
    cdm = cdm,
    conceptSet = names_list,
    name = "indications"
  )

  indications_table <- cdm$antibiotics |>
    DrugUtilisation::summariseIndication(
      indicationCohortName = "indications",
      unknownIndicationTable = "condition_occurrence",
      indicationWindow = list(c(-7, 0), c(0, 0), c(0, 7)),
      mutuallyExclusive = FALSE
    ) %>%
    filter(estimate_name == "percentage",
           estimate_value >= 0.5)

  results[["indications"]] <- indications_table

  cli::cli_alert_success("- Got indications")
#}
