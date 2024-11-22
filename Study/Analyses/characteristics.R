# Characteristics

characteristics <- summariseCharacteristics(cdm$top_ten,
  ageGroup = list(c(0, 17), c(18, 59), c(60, 150))) |>
  bind(summariseCohortAttrition(cdm$top_ten)) |>
  bind(summariseCohortOverlap(cdm$top_ten))

write.csv(characteristics, here("Results", paste0(
  "characteristics_", cdmName(cdm), ".csv"
)))
