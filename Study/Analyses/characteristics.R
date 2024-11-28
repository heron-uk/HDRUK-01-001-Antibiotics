# Characteristics

characteristics <- summariseCharacteristics(cdm$top_ten,
  ageGroup = list(c(0, 17), c(18, 59), c(60, 150)))

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

if(length(unique(route_characteristics$route)) > 1) {
  
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


