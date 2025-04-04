#if (run_indications == TRUE) {
  cli::cli_alert_info("- Getting indications")

  indications <- c(
    "sepsis",
    "musculoskeletal infective disorder",
    "endocarditis",
    "infective disorder of head",
    "genital infection",
    "gastrointestinal infection",
    "respiratory infection",
    "skin infection",
    "urinary tract infectious disease",
    "postprocedural infection",
    "infectious disease"
  )

indication_codelists <- list()

for(i in seq_along(indications)){
    # Dynamically create the name and store the result in the list
    indication_codelists[[indications[i]]] <- getCandidateCodes(
      cdm,
      keywords = c(indications[i]),
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
  
  code_use <- list()
  for(i in seq_along(names_list)){
    code_use[[names(names_list)[i]]] <- summariseCohortCodeUse(names_list[i], 
                                                              cdm = cdm, 
                                                              cohortId = i,
                                                                cohortTable = "indications")
  }

  indications_table <- cdm$antibiotics |>
    summariseCharacteristics(
      cohortIntersectFlag = list(
        "Indication Flag" = list(
          targetCohortTable = "indications", window = c(-7, 7)
        )
      )
    )

  results[["indications"]] <- indications_table

  cli::cli_alert_success("- Got indications")
#}
  
#### Procedures
  
procedures <- c("cardiovascular surgical procedure")

procedure_codelists <- list()

for(i in seq_along(procedures)){
  # Dynamically create the name and store the result in the list
  procedure_codelists[[procedures[i]]] <- getCandidateCodes(
    cdm,
    keywords = c(procedures[i]),
    exclude = NULL,
    domains = "Procedure",
    standardConcept = "Standard",
    searchInSynonyms = FALSE,
    searchNonStandard = FALSE,
    includeDescendants = TRUE,
    includeAncestor = FALSE
  ) %>%
    mutate(name = procedures[i])
}

p_all_codes <- do.call(rbind, procedure_codelists)

rownames(p_all_codes) <- NULL

p_all_codes_grouped <- p_all_codes %>%
  group_by(name) %>%
  summarise(
    codes = list(concept_id),
    code_count = n(),
    .groups = "drop"
  )

p_names_list <- setNames(p_all_codes_grouped$codes, p_all_codes_grouped$name)

cdm$procedures <- conceptCohort(
  cdm = cdm,
  conceptSet = p_names_list,
  name = "procedures"
)

procedures_table <- cdm$antibiotics |>
  summariseCharacteristics(
    cohortIntersectFlag = list(
      "Indication Flag" = list(
        targetCohortTable = "procedures", window = c(-7, 7)
      )
    )
  )

#### Symptoms

symptoms <- c("fever",
                "cough",
                "nausea")

symptom_codelists <- list()

for(i in seq_along(symptoms)){
  # Dynamically create the name and store the result in the list
  symptom_codelists[[symptoms[i]]] <- getCandidateCodes(
    cdm,
    keywords = c(symptoms[i]),
    exclude = NULL,
    domains = "Condition",
    standardConcept = "Standard",
    searchInSynonyms = FALSE,
    searchNonStandard = FALSE,
    includeDescendants = TRUE,
    includeAncestor = FALSE
  ) %>%
    mutate(name = symptoms[i])
}

s_all_codes <- do.call(rbind, symptom_codelists)

rownames(s_all_codes) <- NULL

s_all_codes_grouped <- s_all_codes %>%
  group_by(name) %>%
  summarise(
    codes = list(concept_id),
    code_count = n(),
    .groups = "drop"
  )

s_names_list <- setNames(s_all_codes_grouped$codes, s_all_codes_grouped$name)

cdm$symptoms <- conceptCohort(
  cdm = cdm,
  conceptSet = s_names_list,
  name = "symptoms"
)

symptoms_table <- cdm$antibiotics |>
  summariseCharacteristics(
    cohortIntersectFlag = list(
      "Indication Flag" = list(
        targetCohortTable = "symptoms", window = c(-7, 7)
      )
    )
  )
