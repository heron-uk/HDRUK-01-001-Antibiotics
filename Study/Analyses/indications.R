if (run_indications == TRUE) {
  cli::cli_alert_info("- Getting indications")

  indications <- read_csv("Cohorts/indications_concepts.csv")[,-1]
  
  #####
  
  indications_grouped <- indications %>%
    group_by(indication_category) %>%
    summarise(concept_id_vector = list(concept_id), .groups = "drop")
  
  indications_list <- setNames(indications_grouped$concept_id_vector, indications_grouped$indication_category)
  
  cdm$indications <- conceptCohort(cdm = cdm,
                                   conceptSet = indications_list,
                                   name = "indications")
  
  indications_table <- cdm$antibiotics_chars |>
    summariseCharacteristics(
      cohortIntersectFlag = list(
        "Indication Flag" = list(
          targetCohortTable = "indications", window = c(-7, 7)
        )
      )
    )
  
  results[["summarise_indications"]] <- indications_table
  
  for(i in seq_along(indications_list)){
    results[[paste0("indication_code_use_", i)]] <- summariseCohortCodeUse(x = indications_list[i],
                                                    cdm = cdm,
                                                    cohortTable = "indications",
                                                    cohortId = i)
  }
  
  cli::cli_alert_info("- Got indications")
}