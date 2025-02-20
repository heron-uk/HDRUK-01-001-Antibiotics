if (run_characterisation == TRUE) {
  cli::cli_alert_info("- Getting characteristics")
  
  characteristics <- cdm$top_ten |>
    addSex() |>
    addAge(
      ageGroup = list(c(0, 4),c(5, 9), c(10, 14), c(15,19),
                      c(20, 29),c(30, 39),c(40, 49),c(50, 59),
                      c(60, 69),c(70, 79),
                      c(80, 150))
    ) |>
    summariseCharacteristics(
      strata = list("sex", "age_group"))
  
  characteristics_broad <- cdm$top_ten |>
    addSex() |>
    addAge(
      ageGroup = list( c(0, 19),
                       c(20, 64),
                       c(65, 150))
    ) |>
    summariseCharacteristics(
      strata = list("sex", "age_group"))
  
  results[["characteristics"]] <- characteristics
  results[["characteristics_broad"]] <- characteristics_broad

  attrition <- summariseCohortAttrition(cdm$top_ten)
  
  results[["cohort_attrition"]] <- attrition

  overlap <- summariseCohortOverlap(cdm$top_ten)
  
  results[["cohort_overlap"]] <- overlap
  

  cli::cli_alert_info("- Getting large scale characteristics")

  top_ten_lsc <- CohortCharacteristics::summariseLargeScaleCharacteristics(cdm$top_ten,
    eventInWindow = c("condition_occurrence"
                      #add procedure and observation
                      ),
    window = list(c(-7, 0), c(0, 0))
  )
  
  results[["lsc"]] <- top_ten_lsc

  cli::cli_alert_success("- Got large scale characteristics")
}
