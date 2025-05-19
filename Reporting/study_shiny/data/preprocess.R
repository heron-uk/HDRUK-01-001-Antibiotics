# shiny is prepared to work with this resultList, please do not change them
resultList <- list(
  "summarise_omop_snapshot",
  "summarise_observation_period",
  "summarise_cohort_count",
  "cohort_code_use",
  "summarise_cohort_attrition",
  "summarise_characteristics",
  "summarise_large_scale_characteristics",
  "incidence",
  "incidence_attrition",
  "summarise_drug_utilisation"
)

source(file.path(getwd(), "functions.R"))

data_path <- file.path(getwd(), "data")
csv_files <- list.files(data_path, pattern = "\\.csv$", full.names = TRUE)

result <- purrr::map(csv_files, \(x){
  d <- omopgenerics::importSummarisedResult(x)  
  d
}) |> 
  omopgenerics::bind() |>
  omopgenerics::newSummarisedResult() |>
  dplyr::mutate(cdm_name = dplyr::case_when(
    cdm_name == "IDRIL_1" ~ "Lancashire",
    cdm_name == "LTHT" ~ "Leeds",
    cdm_name == "Barts Health" ~ "Barts",
    .default = cdm_name
  ))

result$additional_level <- gsub("&&&\\s*&&&", "&&& NULL &&&", result$additional_level)

resultList <- resultList |>
  purrr::map(\(x) {
    omopgenerics::settings(result) |>
      dplyr::filter(.data$result_type %in% .env$x) |>
      dplyr::pull(.data$result_id) }) |>
  rlang::set_names(resultList)

data <- prepareResult(result, resultList)

filterValues <- defaultFilterValues(result, resultList)

save(data, filterValues, file = file.path(getwd(), "data", "shinyData.RData"))

rm(result, filterValues, resultList, data)
