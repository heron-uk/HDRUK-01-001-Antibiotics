# shiny is prepared to work with this resultList, please do not change them
resultList <- list(
  "summarise_omop_snapshot" = c(1L),
  "summarise_observation_period" = c(2L),
  "incidence" = c(3L, 4L, 5L, 6L, 7L, 8L, 9L, 10L, 11L, 12L, 13L, 14L),
  "incidence_attrition" = c(15L, 16L, 17L, 18L, 19L, 20L, 21L, 22L, 23L, 24L, 25L, 26L)
)

source(file.path(getwd(), "functions.R"))

result <- omopgenerics::importSummarisedResult(file.path(getwd(), "data"))
data <- prepareResult(result, resultList)
filterValues <- defaultFilterValues(result, resultList)

save(data, filterValues, file = file.path(getwd(), "data", "shinyData.RData"))

rm(result, filterValues, resultList, data)
