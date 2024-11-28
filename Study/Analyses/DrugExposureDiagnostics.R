numeric_codes <- as.integer(unlist(codes_ten)[sapply(unlist(codes_ten), is.numeric)])

all_checks <- executeChecks(
  cdm = cdm,
  ingredients = numeric_codes,
  checks = c(
    "missing", "exposureDuration", "type", "route", "sourceConcept", "daysSupply",
    "verbatimEndDate", "dose", "sig", "quantity", "diagnosticsSummary"
  )
)

writeResultToDisk(all_checks,
                  databaseId = paste0(db_name),
                  outputFolder = here("DED_Results")
)

viewResults(
  here("DED_Results"),
  makePublishable = TRUE,
  publishDir = here("DED_Shiny"),
  overwritePublishDir = TRUE,
  launch.browser = FALSE
)

