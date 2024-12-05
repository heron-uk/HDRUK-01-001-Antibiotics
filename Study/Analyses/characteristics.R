cli::cli_alert_info("- Getting characteristics")

characteristics <- summariseCharacteristics(cdm$top_ten,
  ageGroup = list(c(0, 17),c(18, 59), c(60, 150)))

attrition <- summariseCohortAttrition(cdm$top_ten)

overlap <- summariseCohortOverlap(cdm$top_ten)

write.csv(characteristics, here("Results", paste0(
  "characteristics_", cdmName(cdm), ".csv"
)))

write.csv(attrition, here("Results", paste0(
  "attrition_", cdmName(cdm), ".csv"
)))

write.csv(overlap, here("Results", paste0(
  "overlap_", cdmName(cdm), ".csv"
)))


route_characteristics <- summariseCharacteristics(cdm$top_ten_routes,
                                            ageGroup = list(c(0, 17), c(18, 59), c(60, 150))) %>%
  mutate(route = sub(".*_", "", group_level),
         group_level = sub("_[^_]+$", "", group_level))

routes <- route_characteristics %>%
  filter(!grepl("^j", route)) %>%
  pull(route)

if(length(unique(routes)) > 1) {
  
  stratify_by_route <- TRUE
  
route_attrition <- summariseCohortAttrition(cdm$top_ten_routes) %>%
  mutate(route = sub(".*_", "", group_level),
         group_level = sub("_[^_]+$", "", group_level))

route_overlap <- summariseCohortOverlap(cdm$top_ten_routes) %>%
  mutate(route = sub(".*_", "", group_level),
         group_level = sub("_[^_]+$", "", group_level))

write.csv(route_characteristics, here("Results", paste0(
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

if(stratify_by_route == FALSE){

top_ten_lsc <- CohortCharacteristics::summariseLargeScaleCharacteristics(cdm$top_ten,
                                                                     eventInWindow = c("condition_occurrence"),
                                                                     window = list(c(-7, -1), c(0, 0)))

cohortCount(cdm$condition_occurrence)
write.csv(top_ten_lsc,
          here("Results", paste0(
            "lsc_summary_", cdmName(cdm), ".csv"
          )))

} else if(stratify_by_route == TRUE) {
  top_ten_lsc_routes <- CohortCharacteristics::summariseLargeScaleCharacteristics(cdm$top_ten_routes,
                                                                           eventInWindow = c("condition_occurrence"),
                                                                           window = list(c(-7, -1), c(0, 0)))
  
  write.csv(top_ten_lsc_routes,
            here("Results", paste0(
              "lsc_routes_summary_", cdmName(cdm), ".csv"
            )))
  
}

cli::cli_alert_info("- Getting large scale characteristics")



cli::cli_alert_success("- Got large scale characteristics")
