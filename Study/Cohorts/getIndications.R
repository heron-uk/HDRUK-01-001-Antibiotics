# Upper respiratory infection
upp_res <- getDescendants(cdm, conceptId = c(4181583, #Upper respiratory infection
                          4234533) #tonsillitis
                          ) %>%
  mutate(name = "Upper respiratory tract infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Care-related infections

care_inf <- getDescendants(cdm, conceptId = c(4193161, #Disorder following clinical procedure 
                                              318445, #Post cardiac operation functional disturbance - only one subsume (postcardiotomy syndrome), 
                                              4123283, #disorder of stoma
                                              43021974, #Complication associated with device
                                              4201387, #Tracheostomy present
                                              442019 #complication of procedure
                                              )) %>%
  mutate(name = "Care-related infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# COPD exacerbation

copd <- getDescendants(cdm, conceptId = c(
  255573,# COPD - exacerbation sometimes just recorded as COPD so include this.
  257004 # Acute exacerbation of chronic obstructive pulmonary disease
  ))%>%
  mutate(name = "Exacerbation of chronic obstructive pulmonary disease") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Cystic fibrosis

cyst_fib <- getDescendants(cdm, conceptId = c(441267, # Cystic fibrosis
                                              44808532) # Exacerbation of cystic fibrosis
                           ) %>% 
  mutate(name = "Exacerbation of cystic fibrosis") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Ear infections

ear_inf <- getDescendants(cdm, conceptId = c(4044878, # Infection of ear
                                             380731 # otitis externa
                                             #4103476 Pain of ear
                                             )) %>%
  mutate(name = "Ear infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Eye infections

eye_inf <-  getDescendants(cdm, conceptId = c(4134613, # Eye infection
                                              # 379019, conjunctivitis
                                              # 376125, disorder of eyelid - too broad?
                                              37160823 # Infection of eyelid caused by Mycobacterium leprae
                                              # 4080696 - discharge from eye
                                              )) %>%
  mutate(name = "Eye infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# GI infections

gi_inf <- getDescendants(cdm, conceptId = c(37396146, # Gastrointestinal infection
                                            # 4043371 - Inflammatory disorder of digestive tract - too broad?
                                            44783254, # Infection of masticator space
                                            # 4272162 - Diverticula of intestine - symptom?
                                            #201618 # Disorder ot intestine - too broad?
                                            198678, #intestinal infectious disease
                                            198337 #Infectious diarrheal disease
                                            )) %>%
  mutate(name = "GI infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Neutropenia / agranulocytosis

neut <- getDescendants(cdm, conceptId = c(320073, #neutropneia 
                                          440689)) %>% # Agranulocytosis
  mutate(name = "Neutropenia and agranulocytosis") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Other respiratory infections

lower_resp_inf <- getDescendants(cdm, conceptId = c(4175297, #Lower respiratory tract infection
                                                    4133224, #lobar pneumonia
                                                    #4147117, Non-standard
                                                    #4306082, Aspiration pneumonitis
                                                    #256449 - bronchiectasis - too broad
                                                    618954 # Exacerbation of bronchiectasis caused by infection
                                                    #4170143 - respratory tract infection - too broad?
                                                    )) %>% 
  mutate(name = "Lower respiratory tract infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Cardiac infections

card_inf <- getDescendants(cdm, conceptId = c(314383, # myocarditis 
                                              4138837,  # pericarditis
                                              441589 #endocarditis
                                              # 318772 - disorder of pericardium - too broad - infections covered by above
                                              # 319825 - rheumetic heart disease - too broad?
                                              )) %>%
  mutate(name = "Cardiac infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Sepsis and septic shock

sepsis <- getDescendants(cdm, conceptId = c(132797, #sepsis
                                            196236 # septic shock
                                            )) %>%
  mutate(name = "Sepsis and septic shock") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# skin/subcutaneous infection

skin_inf <- getDescendants(cdm, conceptId = c(201093, # Infection of skin and/or subcutaneous tissue
                                              # 197304 - ulcher of lower extremity - symptom?
                                              # 135333 - pressure ulcer - non standard,
                                              # 4029295 - Folliculitis - symptom?
                                              141095 # acne
                                              )) %>%
  mutate(name = "Skin infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# Urinary tract infections

uti <- getDescendants(cdm, conceptId = 81902) %>% # Urinary tract infectious disease
  mutate(name = "Urinary tract infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

# AMR

amr <- getDescendants(cdm, conceptId = c(4249827, # Infection caused by antimicrobial resistant bacteria
                                         37017452, # Drug resistance to antibacterial agent
                                         44806682) # Infection resistant to multiple antibiotics
                      ) %>%
  mutate(name = "Infection caused by antimicrobial resistant bacteria") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique()

###

indications <- bind_rows(upp_res,ear_inf, eye_inf, gi_inf, lower_resp_inf, card_inf, 
                         sepsis, skin_inf, uti)

indications <- indications |>
  filter(!concept_id %in% care_inf$concept_id,
         !concept_id %in% copd$concept_id, 
         !concept_id %in% cyst_fib$concept_id,
         !concept_id %in% neut$concept_id,
         !concept_id %in% amr$concept_id)

indications <- bind_rows(indications, care_inf, copd, cyst_fib, neut, amr)

### signs and symptoms
normal <- getDescendants(cdm, conceptId = c(4297303,603104,4058999,
                                            4252103,4234554, 4065875,
                                            37311170, 44809158, 4155882)) %>%
  unique()

signs_sympts <- getDescendants(cdm, conceptId = c(201965,  #shock
                                                  437663, #fever
                                                  254761, #cough
                                                  4305080, #abnormal breathing
                                                  31967, #nausea
                                                  441408, #vomiting
                                                  196523, #diarrhea
                                                 # 257907 - disorder of lung - too broad?
                                                 # 4052554 - disorder of pleura and pleural vacity - too broad?
                                                  254061, #pleural effusion
                                                  197672, #Urinary incontinence
                                                  4103189, #finding of heart rate - normal concepts will be excluded
                                                  373995, #delirium
                                                  #4024567 - respiratory finding - too broad?
                                                  #320136 - disorder of respiratory system - too broad?
                                                  433595, # edema
                                                  321689, #apnea
                                                  253321, #stridor
                                                  200528, #ascites
                                                  435517, #acidosis
                                                  4128820, #feeding finding
                                                  435515, #Hypo-osmolality and or hyponatremia
                                                  # 440795 - Complication occurring during labor and delivery - too broad
                                                  4214962, # blood pressure finding
                                                  44784217 # cardiac arrhythmia
                                                  # 4181064 - Inflammatory disorder of extremity - too broad?
                                                 )) %>%
  mutate(name = "Signs and symptoms") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique() %>%
  filter(!concept_id %in% normal$concept_id) %>%
  filter(!concept_id %in% indications$concept_id)

###

indications <- bind_rows(indications, signs_sympts)
# Other infections
other_inf <- getDescendants(cdm, conceptId = 432545) %>% # bacterial infectious disease
  mutate(name = "Other infection") %>%
  select(c(name, concept_id, concept_code, concept_name, domain_id, vocabulary_id)) %>%
  unique() |>
  filter(!concept_id %in% indications$concept_id) |>
  filter(domain_id == "Condition")


indications <- bind_rows(indications, other_inf) 

exclude <- getDescendants(cdm, conceptId = c(440029, #viral disease
                                             433701, #mycosis (fungal infection)
                                             432251 #parisitic disease
))

indications <- indications %>% 
  filter(!concept_id %in% exclude$concept_id) |>
  rename_at('name', ~'indication_category')

write.csv(indications, "Cohorts/indications_concepts.csv")
