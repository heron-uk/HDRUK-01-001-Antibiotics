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

care_inf <- getDescendants(cdm, conceptId = c(4193161, 318445, 4123283, 
                                              43021974, 4201387, 442019)) %>%
  mutate(name = "Care-related infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# COPD exacerbation

copd <- getDescendants(cdm, conceptId = 255573)%>%
  mutate(name = "Exacerbation of chronic obstructive pulmonary disease") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Cystic fibrosis

cyst_fib <- getDescendants(cdm, conceptId = 441267) %>%
  mutate(name = "Exacerbation of cystic fibrosis") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Ear infections

ear_inf <- getDescendants(cdm, conceptId = c(4044878, 4103476)) %>%
  mutate(name = "Ear infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Eye infections

eye_inf <-  getDescendants(cdm, conceptId = c(4134613, 379019, 376125,
                                              4080696)) %>%
  mutate(name = "Eye infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# GI infections

gi_inf <- getDescendants(cdm, conceptId = c(37396146, 4043371, 4272162,
                                            201618)) %>%
  mutate(name = "GI infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Neutropenia / agranulocytosis

neut <- getDescendants(cdm, conceptId = c(320073, 440689)) %>%
  mutate(name = "Neutropenia and agranulocytosis") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Other respiratory infections

lower_resp_inf <- getDescendants(cdm, conceptId = c(4175297, 4147117, 4306082,
                                                    256449, 4170143)) %>%
  mutate(name = "Lower respiratory tract infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique() %>%
  filter(!concept_id %in% upp_res$concept_id)

# Cardiac infections

card_inf <- getDescendants(cdm, conceptId = c(4164489, 318772, 319825)) %>%
  mutate(name = "Cardiac infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Sepsis and septic shock

sepsis <- getDescendants(cdm, conceptId = c(132797, 196236)) %>%
  mutate(name = "Sepsis and septic shock") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# skin/subcutaneous infection

skin_inf <- getDescendants(cdm, conceptId = c(201093, 197304, 135333,
                                              4029295, 141095)) %>%
  mutate(name = "Skin infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Urinary tract infections

uti <- getDescendants(cdm, conceptId = 81902) %>%
  mutate(name = "Urinary tract infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# AMR

amr <- getDescendants(cdm, conceptId = c(4249827, 37017452, 44806682)) %>%
  mutate(name = "Infection caused by antimicrobial resistant bacteria") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

###

indications <- bind_rows(upp_res, bac_inf, care_inf, copd, cyst_fib,
                         ear_inf, eye_inf, gi_inf, neut, lower_resp_inf, card_inf, 
                         sepsis, skin_inf, uti, amr)

### signs and symptoms
normal <- getDescendants(cdm, conceptId = c(4297303,603104,4058999,
                                            4252103,4234554, 4065875,
                                            37311170, 44809158, 4155882)) %>%
  unique()

signs_sympts <- getDescendants(cdm, conceptId = c(201965, 437663, 254761,
                                                  4305080, 31967, 441408,
                                                  196523, 257907, 4052554,
                                                  197672, 4103189, 373995,
                                                  4024567, 320136, 
                                                  433595,
                                                  321689, 253321, 200528,
                                                  435517, 4128820,435515,
                                                  440795, 4214962, 44784217,
                                                  4181064)) %>%
  mutate(name = "Signs and symptoms") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique() %>%
  filter(!concept_id %in% normal$concept_id) %>%
  filter(!concept_id %in% indications$concept_id)

###

indications <- bind_rows(upp_res, bac_inf, care_inf, copd, cyst_fib,
                         ear_inf, eye_inf, gi_inf, neut, lower_resp_inf, card_inf, 
                         sepsis, skin_inf, uti, amr, signs_sympts)

indications <- indications %>% rename_at('name', ~'indication_category')

write.csv(indications, "Cohorts/indications_concepts.csv")
