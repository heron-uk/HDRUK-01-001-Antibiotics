# Upper urinary tract infection
upp_res <- getDescendants(cdm, conceptId = 4181583) %>%
  mutate(name = "Upper respiratory tract infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Bacterial infections

bac_inf <- getDescendants(cdm, conceptId = 432545) %>%
  mutate(name = "Bacterial infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Care-related infections

care_inf <- getDescendants(cdm, conceptId = c(4193161, 442019)) %>%
  mutate(name = "Care-related infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# COPD exacerbation

copd <- getDescendants(cdm, conceptId = 255573)%>%
  mutate(name = "COPD") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Cystic fibrosis

cyst_fib <- getDescendants(cdm, conceptId = 441267) %>%
  mutate(name = "Cystic Fibrosis") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Ear infections

ear_inf <- getDescendants(cdm, conceptId = c(4044878, 4103476)) %>%
  mutate(name = "Ear infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Eye infections

eye_inf <-  getDescendants(cdm, conceptId = c(4134613, 379019, 376125)) %>%
  mutate(name = "Eye infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# GI infections

gi_inf <- getDescendants(cdm, conceptId = 37396146) %>%
  mutate(name = "GI infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Neutropenia / agranulocytosis

neut <- getDescendants(cdm, conceptId = 320073) %>%
  mutate(name = "Neutropenia") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Other respiratory infections

lower_resp_inf <- getDescendants(cdm, conceptId = c(4175297, 4170143)) %>%
  mutate(name = "Lower respiratory tract infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique() %>%
  filter(!concept_id %in% upp_res$concept_id)

# Cardiac infections

card_inf <- getDescendants(cdm, conceptId = 4029816) %>%
  mutate(name = "Cardiac infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Sepsis and septic shock

sepsis <- getDescendants(cdm, conceptId = c(132797, 196236)) %>%
  mutate(name = "Sepsis and septic shock") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# skin/subcutaneous infection

skin_inf <- getDescendants(cdm, conceptId = c(201093, 141095)) %>%
  mutate(name = "Skin infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Urinary tract infections

uti <- getDescendants(cdm, conceptId = 81902) %>%
  mutate(name = "Urinary tract infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# AMR

amr <- getDescendants(cdm, conceptId = 4249827) %>%
  mutate(name = "Infection caused by antimicrobial resistant bacteria") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

### signs and symptoms

shock <- getDescendants(cdm, conceptId = 201965) %>%
  mutate(name = "Shock") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique() %>%
  filter(!concept_id %in% sepsis$concept_id)

fever <- getDescendants(cdm, conceptId = 437663) %>%
  mutate(name = "Fever") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

hypotension <- getDescendants(cdm, conceptId = 317002) %>%
  mutate(name = "Low blood pressure") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

cough <- getDescendants(cdm, conceptId = 254761) %>%
  mutate(name = "Cough") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

ab_breathing <- getDescendants(cdm, conceptId = 4305080) %>%
  mutate(name = "Abnormal breathing") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

nausea <- getDescendants(cdm, conceptId = 31967) %>%
  mutate(name = "Nausea and vomiting") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

diarrhea <- getDescendants(cdm, conceptId = 196523) %>%
  mutate(name = "Diarrhea") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

urinary_inc <- getDescendants(cdm, conceptId = 197672) %>%
  mutate(name = "Urinary incontinence") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

norm_heart_rate <- getDescendants(cdm, conceptId = 4297303) %>%
  mutate(name = "Normal heart rate") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

ab_heart_rate <- getDescendants(cdm, conceptId = 4103189) %>%
  mutate(name = "Abnormal heart rate") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique() %>%
  filter(!concept_id %in% norm_heart_rate$concept_id)

delirium <- getDescendants(cdm, conceptId = 373995) %>%
  mutate(name = "Delirium") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

signs_sympts <- bind_rows(shock, fever, hypotension, cough, ab_breathing, nausea,
                          diarrhea, urinary_inc, ab_heart_rate, delirium) %>%
  mutate(name = "Signs and symptoms") %>%
  unique()
###

indications <- bind_rows(upp_res, bac_inf, care_inf, copd, cyst_fib,
                         ear_inf, eye_inf, gi_inf, neut, lower_resp_inf, card_inf, 
                         sepsis, skin_inf, uti, amr, signs_sympts)

indications <- indications %>% rename_at('name', ~'indication_category')

write.csv(indications, "Cohorts/indications_concepts.csv")
