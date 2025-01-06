if (run_characterisation == TRUE) {
  cli::cli_alert_info("- Getting characteristics")
  
  characteristics <- cdm$top_ten_by_route |>
    addSex() |>
    addAge(
      ageGroup = list(c(0, 4),c(5, 9), c(10, 14), c(15,19),
                      c(20, 29),c(30, 39),c(40, 49),c(50, 59),
                      c(60, 69),c(70, 79),
                      c(80, 150))
    ) |>
    summariseCharacteristics(
      strata = list("sex", "age_group"))

  results[["characteristics"]] <- characteristics

  attrition <- summariseCohortAttrition(cdm$top_ten)

  results[["characteristics_attrition"]] <- attrition

  overlap <- summariseCohortOverlap(cdm$top_ten)

  results[["characteristics_overlap"]] <- overlap

  write.csv(characteristics, here("Results", paste0(
    "characteristics_", cdmName(cdm), ".csv"
  )))

  write.csv(attrition, here("Results", paste0(
    "attrition_", cdmName(cdm), ".csv"
  )))

  write.csv(overlap, here("Results", paste0(
    "overlap_", cdmName(cdm), ".csv"
  )))


  cli::cli_alert_info("- Getting large scale characteristics")

  top_ten_lsc <- CohortCharacteristics::summariseLargeScaleCharacteristics(cdm$top_ten_by_route,
    eventInWindow = c("condition_occurrence"),
    window = list(c(-7, -1), c(0, 0))
  )

  results[["lsc"]] <- top_ten_lsc

  write.csv(
    top_ten_lsc,
    here("Results", paste0(
      "lsc_summary_", cdmName(cdm), ".csv"
    ))
  )

  cli::cli_alert_success("- Got large scale characteristics")
}
