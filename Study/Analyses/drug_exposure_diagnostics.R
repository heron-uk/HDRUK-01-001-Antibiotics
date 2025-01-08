if (run_drug_exposure_diagnostics == TRUE) {
  cli::cli_alert_info("- Running drug exposure diagnostics")

    drug_diagnostics <- executeChecks(
    cdm = cdm,
    ingredients = top_ten_ingredients$concept_id,
    checks = c(
      "missing",
      "exposureDuration",
      "sourceConcept",
      "route",
      "dose",
      "quantity"
    ),
    earliestStartDate = "2012-01-01"
  )

  for (i in seq_along(drug_diagnostics)) {
    write.csv(
      drug_diagnostics[[i]] %>%
        mutate(cdm_name = !!db_name),
      here("Results", "DED", paste0(
        names(drug_diagnostics)[i], "_", cdmName(cdm), ".csv"
      ))
    )
  }
    
    files_to_zip_ded <- list.files(here("Results", "DED"))
    files_to_zip_ded <- files_to_zip_ded[stringr::str_detect(
      files_to_zip_ded,
      db_name
    )]
    files_to_zip_ded <- files_to_zip_ded[stringr::str_detect(
      files_to_zip_ded,
      ".csv"
    )]
    
    zip::zip(
      zipfile = file.path(paste0(
        here("Results", "DED"), "/DED_Results_", db_name, ".zip"
      )),
      files = files_to_zip_ded,
      root = here("Results", "DED")
    )

  cli::cli_alert_success("- Finished drug exposure diagnostics")
}