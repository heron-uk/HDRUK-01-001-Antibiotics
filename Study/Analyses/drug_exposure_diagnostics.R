cli::cli_alert_info("- Running drug exposure diagnostics")

ingredient_codes <- unlist(ingredient_codes)

drug_diagnostics <- executeChecks(
  cdm = cdm,
  ingredients = ingredient_codes,
  checks = c(
    "missing",
    "exposureDuration",
    "sourceConcept"
  ),
  earliestStartDate = "2012-01-01"
)

for(i in seq_along(drug_diagnostics)){
  write.csv(drug_diagnostics[[i]] %>%
              mutate(cdm_name = !!db_name),
            here("Results", paste0(
              names(drug_diagnostics)[i], "_" ,cdmName(cdm), ".csv"
            )))
  
}

cli::cli_alert_success("- Finished drug exposure diagnostics")
