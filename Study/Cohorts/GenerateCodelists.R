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
    type = "codelist",
    nameStyle = "{concept_name}")

if(isTRUE(primary_care) & numberRecords(cdm$visit_occurrence) > 0){
cdm$patient_visit <- conceptCohort(
  cdm = cdm,
  conceptSet = list(outpatient = 9202, outpatient_er = 9203, outpatient_hospital = 8756),
  name = "patient_visit"
)
} else if(isTRUE(secondary_care) & numberRecords(cdm$visit_occurrence) > 0){
cdm$patient_visit <- conceptCohort(
  cdm = cdm,
  conceptSet = list(inpatient = 9201, inpatient_er = 262),
  name = "patient_visit"
) 
} else if (numberRecords(cdm$visit_occurrence) == 0) {
  cdm$patient_visit <- cdm$visit_occurrence |>
    compute(name = "patient_visit", temporary = FALSE)
}

###
# If there aren't any codelists in ing_all then the next steps are skipped.
if (length(ingredient_desc) > 0 & numberRecords(cdm$patient_visit) > 0) {
  
  # Creates cohort for watch list antibiotics for outpatients. Only include records 
  # of drug exposure on day of outpatient visit.
  cdm$prelim_antibiotics <- conceptCohort(
    cdm = cdm,
    conceptSet = ingredient_desc,
    name = "prelim_antibiotics"
  ) %>%
    requireTableIntersect(
      tableName = "patient_visit",
      window = c(0, 0)
    ) %>%
    requireInDateRange(
      indexDate = "cohort_start_date",
      dateRange = study_period
    )
  
  # Gets top ten antibiotics using record counts
  counts <- cohortCount(cdm$prelim_antibiotics) |>
    filter(number_records > min_cell_count) %>%
    left_join(settings(cdm$prelim_antibiotics),
              by = "cohort_definition_id"
    )
  
  ingredient_desc <- ingredient_desc[names(ingredient_desc) %in%
                                           counts$cohort_name]
  
  sum_ingredients <- summariseCohortCount(cohort = cdm$prelim_antibiotics) %>%
    filter(group_level %in% counts$cohort_name)
  
  results[["sum_ingredients"]] <- sum_ingredients
  
} else if (numberRecords(cdm$patient_visit) == 0) {
  
  cdm$prelim_antibiotics <- conceptCohort(
    cdm = cdm,
    conceptSet = ingredient_desc,
    name = "prelim_antibiotics"
  ) %>%
    requireInDateRange(
      indexDate = "cohort_start_date",
      dateRange = study_period
    )
  
  # Gets top ten antibiotics using record counts
  counts <- cohortCount(cdm$prelim_antibiotics) |>
    filter(number_records > min_cell_count) %>%
    left_join(settings(cdm$prelim_antibiotics),
              by = "cohort_definition_id"
    )
  
  ingredient_desc <- ingredient_desc[names(ingredient_desc) %in%
                                       counts$cohort_name]
  
  sum_ingredients <- summariseCohortCount(cohort = cdm$prelim_antibiotics) %>%
    filter(group_level %in% counts_out$cohort_name)
  
  results[["sum_prelim_ingredients"]] <- sum_ingredients
  
}
