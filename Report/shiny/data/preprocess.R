# shiny is prepared to work with this resultList, please do not change them
resultList <- list(
  "summarise_omop_snapshot" = c(1L),
  "summarise_observation_period" = c(2L),
  "summarise_drug_utilisation" = c(3L),
  "summarise_characteristics" = c(4L),
  "summarise_cohort_attrition" = c(5L, 6L, 7L, 8L, 9L, 10L, 11L, 12L, 13L, 14L),
  "summarise_cohort_overlap" = c(15L),
  "summarise_large_scale_characteristics" = c(16L),
  "incidence" = c(17L, 18L, 19L, 20L, 21L, 22L, 23L, 24L, 25L, 26L, 27L, 28L, 29L, 30L, 31L, 32L, 33L, 34L, 35L, 36L, 37L, 38L, 39L, 40L),
  "incidence_attrition" = c(41L, 42L, 43L, 44L, 45L, 46L, 47L, 48L, 49L, 50L, 51L, 52L, 53L, 54L, 55L, 56L, 57L, 58L, 59L, 60L, 61L, 62L, 63L, 64L)
)

source(file.path(getwd(), "functions.R"))

result <- omopgenerics::importSummarisedResult(file.path(getwd(), "data"))
data <- prepareResult(result, resultList)
filterValues <- defaultFilterValues(result, resultList)

save(data, filterValues, file = file.path(getwd(), "data", "shinyData.RData"))

rm(result, filterValues, resultList, data)
