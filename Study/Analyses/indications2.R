### Respiratory infections

icd10 <- CodelistGenerator::getICD10StandardCodes(cdm, 
                                                  level = c("ICD10 SubChapter")
                                                  )

icd10_hierarchy <- CodelistGenerator::getICD10StandardCodes(cdm, 
                                                  level = c("ICD10 Hierarchy")
)

resp_inf_1 <- icd10[grepl("respiratory_infections", names(icd10), ignore.case = TRUE)]
  
resp_inf_2 <- icd10[grepl("pneumonia", names(icd10), ignore.case = TRUE)]

resp_inf <- c(resp_inf_1, resp_inf_2)

### Complications after surgery

#comp_proc_1 <- CodelistGenerator::getICD10StandardCodes(cdm, level = c("ICD10 SubChapter"),
 #                                                     name = c("complications of medical and surgical care misadventures to patients during surgical and medical care"))

#comp_proc_2 <- CodelistGenerator::getICD10StandardCodes(cdm, level = c("ICD10 SubChapter"),
  #                                                    name = c("complications of surgical and medical care, not elsewhere classified"))

#comp_proc_3 <- CodelistGenerator::getICD10StandardCodes(cdm, level = c("ICD10 SubChapter"),
#                                                        name = c("complications of labour and delivery"))

#comp_proc <- c(comp_proc_1, comp_proc_2, comp_proc_3)

#### Sepsis

sepsis <- icd10_hierarchy[grepl("sepsis", names(icd10_hierarchy), ignore.case = TRUE)]

#####

uti_1 <- icd10_hierarchy[grepl("other_disorders_of_urinary", names(icd10_hierarchy), ignore.case = TRUE)]

uti_2 <- icd10_hierarchy[grepl("urethritis", names(icd10_hierarchy), ignore.case = TRUE)]

uti_3 <- icd10_hierarchy[grepl("n30_cystitis", names(icd10_hierarchy), ignore.case = TRUE)]

uti <- c(uti_1, uti_2, uti_3)

######

sepsis_symptoms_1 <- icd10_hierarchy[grepl("hypotension", names(icd10_hierarchy), ignore.case = TRUE)]
sepsis_symptoms_2 <- icd10_hierarchy[grepl("r50_fever", names(icd10_hierarchy), ignore.case = TRUE)]

sepsis_symptoms <- c(sepsis_symptoms_1, sepsis_symptoms_2)

######

indications <- c(resp_inf, sepsis, uti, sepsis_symptoms)

cdm$indications <- conceptCohort(cdm = cdm,
                                 conceptSet = indications,
                                 name = "indications")

indications_table <- cdm$antibiotics |>
  summariseCharacteristics(
    cohortIntersectFlag = list(
      "Indication Flag" = list(
        targetCohortTable = "indications", window = c(-7, 7)
      )
    )
  )

sum_ind_code_use <- list()
for(i in seq_along(indications)){
sum_ind_code_use[[i]] <- summariseCohortCodeUse(x = indications[i],
                                           cdm = cdm,
                                           cohortTable = "indications",
                                           cohortId = i)
}
