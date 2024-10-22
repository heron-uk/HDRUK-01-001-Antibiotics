# create logger
log_file <- paste0(output_folder, "/log.txt")
logger <- create.logger()
logfile(logger) <- log_file
level(logger) <- "INFO"

# if SIDIAP filter cdm$drug_exposure
if (db_name == "SIDIAP") {
  info(logger, "FILTER DRUG EXPOSURE TABLE")
  cdm$drug_exposure <- cdm$drug_exposure %>%
    filter(drug_type_concept_id == 32839) %>%
    compute()
}

# generate table names
info(logger, "GENERATE TABLE NAMES")
indication_table_name <- paste0(stem_table, "_indication")

# instantiate necessary cohorts
## generate indication cohorts
info(logger, "INSTANTIATE INDICATION COHORTS")
indicationCohorts <- readCohortSet(
  path = here("InstantiateCohorts", "IndicationCohorts")
)
cdm <- generateCohortSet(
  cdm = cdm,
  cohortSet = indicationCohorts,
  name = indication_table_name,
  overwrite = TRUE
)

info(logger, "PART 1 - ALL ANTIBIOTICS, NO STRATIFICATION")

conceptPathAll <- here("InstantiateCohorts", "PopulationDUSConceptSets")

# Population level DUS
info(logger, "GENERATE POPULATION LEVEL DUS COHORTS")
cdm$dus_pop_level_all <- generateDrugUtilisationCohort(
  cdm = cdm,
  ingredientConceptId = NULL,
  conceptSetPath = conceptPathAll,
  studyStartDate = NULL,
  studyEndDate = NULL,
  summariseMode = "AllEras",
  daysPriorHistory = NULL,
  gapEra = 7,
  imputeDuration = "eliminate",
  durationRange = c(1, NA)
)
populationLevelAttritionAll <- attr(cdm$dus_pop_level_all, "attrition")
conceptSetsAll <- attr(cdm$dus_pop_level_all, "cohortSet")

info(logger, "GENERATE DENOMINATOR COHORTS")
cdm$denominator_all <- generateDenominatorCohortSet(
  cdm = cdm,
  startDate = as.Date("2012-01-01"),
  endDate = as.Date("2022-12-31"),
  sex = c("Both"),
  ageGroup = list(c(0,150)),
  daysPriorHistory = 365
)

info(logger, "ESTIMATE INCIDENCE BY YEAR")
inc_all <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator_all",
  outcomeTable = "dus_pop_level_all",
  outcomeCohortId = conceptSetsAll$cohortId,
  interval = c("years","overall"),
  repeatedEvents = TRUE,
  outcomeWashout = 30,
  completeDatabaseIntervals = TRUE,
  minCellCount = minimum_counts,
  verbose = TRUE
)

info(logger, "GET INDICATIONS")
indicationList <- getIndication(
  cdm = cdm,
  targetCohortName = "dus_pop_level_all",
  targetCohortDefinitionIds = NULL,
  indicationCohortName = indication_table_name,
  indicationDefinitionSet = indicationCohorts,
  indicationGap = c(7,30),
  unknownIndicationTables = c("condition_occurrence", "observation")
)

info(logger, "GET DURATION INFORMATION")
durationSummary <- cdm$dus_pop_level_all %>%
  mutate(duration = !!datediff("cohort_start_date", "cohort_end_date") + 1) %>%
  group_by(cohort_definition_id) %>%
  summarise(
    observations_count = as.numeric(n()),
    subjects_count = as.numeric(n_distinct(subject_id)),
    duration_min = min(duration, na.rm = TRUE),
    duration_max = max(duration, na.rm = TRUE),
    duration_q25 = quantile(duration, 0.25, na.rm = TRUE),
    duration_q75 = quantile(duration, 0.5, na.rm = TRUE),
    duration_median = median(duration, na.rm = TRUE),
    duration_mean = mean(duration, na.rm = TRUE),
    duration_std = sd(duration, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  collect() %>%
  pivot_longer(
    cols = !cohort_definition_id,
    names_to = c("variable", "estimate"),
    names_sep = "_",
    values_to = "value"
  )

info(logger, "SUMMARISE INDICATION TABLE")
indicationSummary <- summariseDoseIndicationTable(
  cdm = cdm,
  strataCohortName = "dus_pop_level_all",
  indicationList = indicationList,
  minimumCellCounts = minimum_counts
)

info(logger, "GET TOP10 LARGE SCALE CHARACTERIZATION")
lsc <- largeScaleCharacterization(
  cdm = cdm,
  targetCohortName = "dus_pop_level_all",
  temporalWindows = list(c(-30, -1), c(0, 0)),
  tablesToCharacterize = "condition_occurrence",
  overlap = FALSE
)
top10covariates <- lsc$characterization %>%
  filter(concept_id > 0) %>%
  group_by(cohort_definition_id, window_id, table_id) %>%
  arrange(desc(counts)) %>%
  slice(1:10) %>%
  ungroup() %>%
  left_join(
    cdm$concept %>% select("concept_id", "concept_name") %>% collect(),
    by = "concept_id"
  )

info(logger, "PART 2 - ANTIBIOTIC CLASSES, STRATIFICATION BY AGE AND SEX")

conceptPathClasses <- here("InstantiateCohorts", "PopulationDUSConceptSetsIngredientClasses")

# Population level DUS
info(logger, "GENERATE POPULATION LEVEL DUS COHORTS")
cdm$dus_pop_level_age_sex <- generateDrugUtilisationCohort(
  cdm = cdm,
  ingredientConceptId = NULL,
  conceptSetPath = conceptPathClasses,
  studyStartDate = NULL,
  studyEndDate = NULL,
  summariseMode = "AllEras",
  daysPriorHistory = NULL,
  gapEra = 7,
  imputeDuration = "eliminate",
  durationRange = c(1, NA)
)
populationLevelAttritionAgeSex <- attr(cdm$dus_pop_level_age_sex, "attrition")
conceptSetsAgeSex <- attr(cdm$dus_pop_level_age_sex, "cohortSet")

cdm$denominator_age_sex <- generateDenominatorCohortSet(
  cdm = cdm,
  startDate = as.Date("2012-01-01"),
  endDate = as.Date("2022-12-31"),
  sex = c("Both", "Male","Female"),
  ageGroup = list(c(0,1),
                  c(2,11),
                  c(12,17),
                  c(18,29),
                  c(30,39),
                  c(40,49),
                  c(50,59),
                  c(60,69),
                  c(70,79),
                  c(80,150)),
  daysPriorHistory = 365
)

info(logger, "ESTIMATE INCIDENCE BY AGE AND SEX")
inc_age_sex <- estimateIncidence(
  cdm = cdm,
  denominatorTable = "denominator_age_sex",
  outcomeTable = "dus_pop_level_age_sex",
  outcomeCohortId = conceptSetsAgeSex$cohortId,
  interval = c("overall"),
  repeatedEvents = TRUE,
  outcomeWashout = 30,
  completeDatabaseIntervals = TRUE,
  minCellCount = minimum_counts,
  verbose = TRUE
)


## Write DUS results and zip them
info(logger, "GATHERING RESULTS")
study_results <- gatherIncidencePrevalenceResults(
  cdm = cdm,
  resultList = list(inc_all, inc_age_sex),
  databaseName = db_name
)
study_results <- c(
  study_results,
  list(
    concept_sets = conceptSetsAll %>% mutate(db_name = db_name),
    duration_summary = durationSummary %>% mutate(db_name = db_name),
    indication_summary = indicationSummary %>% mutate(db_name = db_name),
    population_level_attrition = populationLevelAttritionAll %>% mutate(db_name = db_name),
    top10_covariates = top10covariates %>% mutate(db_name = db_name),
    large_scale_denominator = lsc$denominator %>% mutate(db_name = db_name),
    large_scale_tempporal_windows = lsc$temporalWindows %>% mutate(db_name = db_name)
  )
)

info(logger, "WRITING CSV FILES")
lapply(names(study_results), function(x) {
  result <- study_results[[x]]
  utils::write.csv(
    result, file = paste0(output_folder, "/", x, ".csv"), row.names = FALSE
  )
})
info(logger, "ZIPPING RESULTS")
output_folder <- basename(output_folder)
zip(
  zipfile = file.path(paste0(output_folder, "/C1_003_AntibioticsDUS_", db_name,Sys.Date(), ".zip")),
  files = list.files(output_folder, full.names = TRUE)
)
