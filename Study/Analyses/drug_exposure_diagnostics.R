cli::cli_alert_info("- Running drug exposure diagnostics")

top_ten_names <- top_ten

 if("rifampicin" %in% top_ten_names) {
   top_ten_names[top_ten_names == "rifampicin"] <- "rifampin"
 }

drug_ingredients <- cdm$concept %>%
  filter(standard_concept == "S") %>%
  filter(domain_id == "Drug") %>%
  filter(concept_name %in% local(top_ten_names)) %>%
  filter(concept_class_id=="Ingredient")    %>%
  filter(standard_concept =="S") %>%
  select(c("concept_id", "concept_name")) %>%
  collect()

drug_ingredients_names <- drug_ingredients %>%
  pull(concept_name)

drug_ingredients_codes <- drug_ingredients %>%
  pull(concept_id)

drug_diagnostics <- executeChecks(
  cdm = cdm,
  ingredients = drug_ingredients_codes,
  checks = c(
    "missing",
    "exposureDuration",
    "sourceConcept"
  )
)

for(i in seq_along(drug_diagnostics)){
  write.csv(drug_diagnostics[[i]] %>%
              mutate(cdm_name = !!db_name),
            here("Results", paste0(
              names(drug_diagnostics)[i], "_" ,cdmName(cdm), ".csv"
            )))
  
}

cli::cli_alert_success("- Finished drug exposure diagnostics")
