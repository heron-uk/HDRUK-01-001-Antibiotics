icd10_subchapters <- CodelistGenerator::getICD10StandardCodes(cdm, level = c("ICD10 SubChapter"),
                                                              type = "codelist_with_details")

icd10_hierarchy <- CodelistGenerator::getICD10StandardCodes(cdm, level = c("ICD10 Hierarchy"),
                                                            type = "codelist_with_details")

icd10_codes <- CodelistGenerator::getICD10StandardCodes(cdm, level = c("ICD10 Code"),
                                                            type = "codelist_with_details")

### Upper Respiratory Infections
resp_inf <- c(icd10_subchapters[grepl("j00_j06", names(icd10_subchapters), ignore.case = TRUE)],
              icd10_subchapters[grepl("j09_j18", names(icd10_subchapters), ignore.case = TRUE)],
              icd10_subchapters[grepl("j20_j22", names(icd10_subchapters), ignore.case = TRUE)]) %>%
  bind_rows() %>%
  distinct()

##### Antimicrobial resistance (bacterial only)

u82 <- icd10_hierarchy[grepl("u82_", names(icd10_hierarchy), ignore.case = TRUE)]

u83 <- icd10_hierarchy[grepl("u83_", names(icd10_hierarchy), ignore.case = TRUE)] 

amr <- c(u82, u83) %>%
  bind_rows() %>%
  mutate(name = "Antimicrobial Resistance") %>%
  unique()

##### Bacterial Infections

a49 <- icd10_hierarchy[grepl("a49_", names(icd10_hierarchy), ignore.case = TRUE)]

b96 <- icd10_hierarchy[grepl("b96_", names(icd10_hierarchy), ignore.case = TRUE)]

bacterial_infection <- c(a49, b96) %>%
  bind_rows() %>%
  mutate(name = "Bacterial Infection") %>%
  unique()

###### Care-related infections

y60_y69 <- icd10_subchapters[grepl("y60_y69", names(icd10_subchapters), ignore.case = TRUE)]

y83_y84 <- icd10_subchapters[grepl("y83_y84", names(icd10_subchapters), ignore.case = TRUE)]

y95 <- icd10_hierarchy[grepl("y95", names(icd10_hierarchy), ignore.case = TRUE)]

care_related_infections <- c(y60_y69, y83_y84, y95) %>%
  bind_rows() %>%
  mutate(name = "Care-related infections") %>%
  unique()

#### COPD exacerbation

copd <- icd10_hierarchy[grepl("j44_", names(icd10_hierarchy), ignore.case = TRUE)] %>%
  bind_rows() %>%
  mutate(name = "COPD") %>%
  unique()

#### Cystic Fibrosis

cystic_fibrosis <- icd10_hierarchy[grepl("e84_", names(icd10_hierarchy), ignore.case = TRUE)] %>%
  bind_rows() %>%
  mutate(name = "Cystic Fibrosis") %>%
  unique()

#### ENT Infections

ear_inf <- getDescendants(cdm, conceptId = c(4044878,4183452, 
                                             4103476)) %>%
  mutate(name = "Ear infections") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

##### Eye infections

eye_inf <- getDescendants(cdm, conceptId = 4134613) %>%
  mutate(name = "Eye infections") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

##### GI Infections
gi_inf <- getDescendants(cdm, conceptId = 37396146) %>%
  mutate(name = "GI infections") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

####### Neutropenia and agranuloctytosis

neutro_agran <- c(icd10_hierarchy[grepl("d70", names(icd10_hierarchy), ignore.case = TRUE)],
                  icd10_codes[grepl("p615", names(icd10_codes), ignore.case = TRUE)]) %>%
  bind_rows() %>%
  mutate(name = "Neutropenia and agranulocytosis") %>%
  unique()

##### Cardiac infections

peric <- getDescendants(cdm, conceptId = 4138837)

myoc <- getDescendants(cdm, conceptId = 314383)

endoc <- getDescendants(cdm, conceptId = 441589)

cardiac_inf <- bind_rows(peric, myoc, endoc) %>%
  mutate(name = "Cardiac infections") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

#####
sepsis <- c(icd10_hierarchy[grepl("a40", names(icd10_hierarchy), ignore.case = TRUE)],
            icd10_hierarchy[grepl("a41", names(icd10_hierarchy), ignore.case = TRUE)],
            icd10_hierarchy[grepl("p36", names(icd10_hierarchy), ignore.case = TRUE)])

shock <- icd10_codes[grepl("r572", names(icd10_codes), ignore.case = TRUE)] 

sepsis_and_shock <- c(sepsis, shock) %>%
  bind_rows() %>%
  mutate(name = "Sepsis and Septic Shock") %>%
  unique()

##### signs and infections

signs_and_symptoms <- c(icd10_codes[grepl("r579", names(icd10_codes), ignore.case = TRUE)],
                      icd10_hierarchy[grepl("r50", names(icd10_hierarchy), ignore.case = TRUE)],
                      icd10_codes[grepl("i959", names(icd10_codes), ignore.case = TRUE)],
                      icd10_hierarchy[grepl("r05", names(icd10_hierarchy), ignore.case = TRUE)],
                      icd10_hierarchy[grepl("r06", names(icd10_hierarchy), ignore.case = TRUE)],
                      icd10_hierarchy[grepl("r11", names(icd10_hierarchy), ignore.case = TRUE)],
                      icd10_hierarchy[grepl("r32", names(icd10_hierarchy), ignore.case = TRUE)],
                      icd10_hierarchy[grepl("r00", names(icd10_hierarchy), ignore.case = TRUE)],
                      icd10_hierarchy[grepl("f05", names(icd10_hierarchy), ignore.case = TRUE)]
                      ) %>%
  bind_rows() %>%
  mutate(name = "Signs and Symptoms") %>%
  unique()

##### skin infections

skin_inf <- getDescendants(cdm, conceptId = 201093) %>%
  mutate(name = "Skin and subcutaneous infections") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

##### UTI

uti <- icd10_hierarchy[grepl("n39", names(icd10_hierarchy), ignore.case = TRUE)] %>%
  bind_rows() %>%
  unique() %>%
  mutate(name = "Urinary tract infections")

#####

indications <- bind_rows(resp_inf, amr, bacterial_infection, care_related_infections, copd, cystic_fibrosis,
                         ear_inf, eye_inf, gi_inf, neutro_agran, cardiac_inf, sepsis_and_shock, 
                         signs_and_symptoms, skin_inf, uti)

indications <- indications %>% rename_at('name', ~'indication_category')

write.csv(indications, "Cohorts/indications_concepts.csv")
