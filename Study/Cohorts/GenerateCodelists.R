cli::cli_text("- GETTING CODELISTS ({Sys.time()})")

ingredients <- read_csv(here("Cohorts", "ingredients.csv"),
  col_types = list(
    concept_id = col_double(),
    ingredient_name = col_character(),
    cohort_name = col_character(),
    atc = col_character()
  )
)

ing_av <- cdm$concept %>%
  filter(
    domain_id == "Drug",
    concept_class_id == "Ingredient",
    standard_concept == "S",
    concept_id %in% ingredients$concept_id
  ) %>%
  pull("concept_id")

# Create a codelist for the antibiotics at ingredient level.

ingredient_desc <- getDrugIngredientCodes(
    cdm = cdm,
    name = ing_av,
    type = "codelist")

if(isTRUE(restrict_to_inpatient) & numberRecords(cdm$visit_occurrence) > 0){
cdm$inpatient_visit <- conceptCohort(
  cdm = cdm,
  conceptSet = list(inpatient = c(9201, 262)),
  name = "inpatient_visit"
) 
} else if (isTRUE(restrict_to_inpatient) & numberRecords(cdm$visit_occurrence) == 0) {
  
  cli::cli_text("No records in visit occurrence table - skip restriction to inpatients only")
}

###
# If there aren't any codelists in ing_all then the next steps are skipped.
if (isTRUE(restrict_to_inpatient) & numberRecords(cdm$visit_occurrence) > 0) {
  
  # Creates cohort for watch list antibiotics for outpatients. Only include records 
  # of drug exposure on day of outpatient visit.
  cdm$prelim_antibiotics <- conceptCohort(
    cdm = cdm,
    conceptSet = ingredient_desc,
    name = "prelim_antibiotics"
  ) %>%
    requireTableIntersect(
      tableName = "inpatient_visit",
      window = c(0, Inf),
      indexDate = "cohort_start_date"
    ) %>%
    requireTableIntersect(
      tableName = "inpatient_visit",
      window = c(-Inf, 0),
      indexDate = "cohort_end_date"
    ) %>%
    requireInDateRange(
      indexDate = "cohort_start_date",
      dateRange = study_period
    )
} else {
  cdm$prelim_antibiotics <- conceptCohort(
    cdm = cdm,
    conceptSet = ingredient_desc,
    name = "prelim_antibiotics"
  )  %>%
    requireInDateRange(
      indexDate = "cohort_start_date",
      dateRange = study_period
    )
}
  
  # Filter down to antibiotics with at least 100 records.
counts <- cohortCount(cdm$prelim_antibiotics) |>
    filter(number_records >= 100) %>%
    left_join(settings(cdm$prelim_antibiotics),
              by = "cohort_definition_id"
    )
  
  ingredient_desc <- ingredient_desc[names(ingredient_desc) %in%
                                           counts$cohort_name]
