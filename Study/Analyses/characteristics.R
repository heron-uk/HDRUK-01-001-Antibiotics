if (run_characterisation == TRUE) {
  cli::cli_alert_info("- Getting characteristics")

  characteristics <- summariseCharacteristics(cdm$watch_list,
    ageGroup = list(c(0, 17), c(18, 59), c(60, 150))
  )

  results[["characteristics"]] <- characteristics

  attrition <- summariseCohortAttrition(cdm$watch_list)

  results[["characteristics_attrition"]] <- attrition

  overlap <- summariseCohortOverlap(cdm$watch_list)

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


  route_characteristics <- summariseCharacteristics(cdm$by_route,
    ageGroup = list(c(0, 17), c(18, 59), c(60, 150))
  ) %>%
    mutate(
      route = sub(".*_", "", group_level),
      group_level = sub("_[^_]+$", "", group_level)
    )

  routes <- route_characteristics %>%
    filter(!grepl("^j", route)) %>%
    pull(route)

  if (length(unique(routes)) > 1) {
    stratify_by_route <- TRUE

    characteristics_by_route <- summariseCharacteristics(cdm$by_route,
      ageGroup = list(c(0, 17), c(18, 59), c(60, 150))
    )

    route_attrition <- summariseCohortAttrition(cdm$by_route)

    route_overlap <- summariseCohortOverlap(cdm$by_route)

    results[["characteristics_by_route"]] <- characteristics_by_route
    results[["characteristics_attrition_by_route"]] <- route_attrition
    results[["characteristics_overlap_by_route"]] <- route_overlap

    write.csv(characteristics_by_route, here("Results", paste0(
      "routes_characteristics_", cdmName(cdm), ".csv"
    )))

    write.csv(route_attrition, here("Results", paste0(
      "route_attrition_", cdmName(cdm), ".csv"
    )))

    write.csv(route_overlap, here("Results", paste0(
      "route_overlap_", cdmName(cdm), ".csv"
    )))
  } else {
    stratify_by_route <- FALSE
  }

  cli::cli_alert_success("- Got characteristics")

  cli::cli_alert_info("- Getting large scale characteristics")

  top_ten_lsc <- CohortCharacteristics::summariseLargeScaleCharacteristics(cdm$watch_list,
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

  if (stratify_by_route == TRUE) {
    top_ten_lsc_routes <- CohortCharacteristics::summariseLargeScaleCharacteristics(cdm$by_route,
      eventInWindow = c("condition_occurrence"),
      window = list(c(-7, -1), c(0, 0))
    )

    results[["lsc_by_route"]] <- top_ten_lsc_routes

    write.csv(
      top_ten_lsc_routes,
      here("Results", paste0(
        "lsc_routes_summary_", cdmName(cdm), ".csv"
      ))
    )
  }

  cli::cli_alert_success("- Got large scale characteristics")
}
