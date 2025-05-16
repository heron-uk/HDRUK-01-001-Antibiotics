# Manage project dependencies ------
# the following will prompt you to install the various packages used in the study
# install.packages("renv")
# renv::activate()
renv::restore()

library(CDMConnector)
library(DBI)
library(log4r)
library(readr)
library(DrugUtilisation)
library(IncidencePrevalence)
library(OmopSketch)
library(dplyr)
library(here)
library(tidyr)
library(CodelistGenerator)
library(CohortConstructor)
library(CohortCharacteristics)
library(PatientProfiles)
library(DrugExposureDiagnostics)
library(omopgenerics)
library(stringr)
library(RPostgres)
library(odbc)

# database metadata and connection details -----
# The name/ acronym for the database

db_name <- "..."

# Database connection details
# In this study we also use the DBI package to connect to the database
# set up the dbConnect details below
# https://darwin-eu.github.io/CDMConnector/articles/DBI_connection_examples.html
# for more details.
# you may need to install another package for this
# eg for postgres

db <- dbConnect("...",
  dbname = "...",
  port = "...",
  host = "...",
  user = "...",
  password = "...",
  bigint = c("integer")
)

# Set database details -----

# The name of the schema that contains the OMOP CDM with patient-level data
cdm_schema <- "..."

# The name of the schema where results tables will be created
write_schema <- "..."

# Table prefix -----
# any tables created in the database during the analysis will start with this prefix
study_prefix <- "..."

# create cdm reference -----
cdm <- CDMConnector::cdmFromCon(
  con = db,
  cdmSchema = cdm_schema,
  writeSchema = write_schema,
  cdmName = db_name,
  writePrefix = study_prefix
)

# Study start date -----

# The earliest start date for this study "2012-01-01".
# Please put the study start date as "2012-01-01 if you have usable data from 2012 onwards.
# Hospital databases should set the start date as "2022-01-01". 
study_start <- "2022-01-01"

# Minimum cell count -----
# This is the minimum counts that can be displayed according to data governance.
min_cell_count <- 5

### Database settings
# Hospital databases should set the restrict_to_inpatient flag to TRUE.
restrict_to_inpatient <- FALSE

# Databases that only include paediatric data should set the restrict_to_paediatric to TRUE. 
restrict_to_paediatric <- FALSE

# analyses to run -----
# setting to FALSE will skip analysis
run_characterisation <- TRUE
run_incidence <- TRUE

#Only set run_drug_exposure_diagnostics as TRUE if you are running the code for the first time.
run_drug_exposure_diagnostics <- FALSE

# Run the study
source(here("RunStudy.R"))

# Study Results to share ---
# After the study is run you should have the following files to share in your results folder:
# 1) log file of study
# 2) results.csv containing the main results of the study
