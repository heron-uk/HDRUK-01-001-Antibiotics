# Manage project dependencies ------
# the following will prompt you to install the various packages used in the study
# install.packages("renv")
# renv::activate()
renv::restore()

library(CDMConnector)
library(DBI)
library(log4r)
library(DrugUtilisation)
library(IncidencePrevalence)
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

# database metadata and connection details
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
                bigint = c("numeric"))

# Set database details ----- 

# The name of the schema that contains the OMOP CDM with patient-level data 
cdm_schema <- "..."

# The name of the schema where results tables will be created  
write_schema <- "..."

# Table prefix -----
# any tables created in the database during the analysis will start with this prefix
study_prefix <- "..."

# create cdm reference -----
cdm <- CDMConnector::cdmFromCon(con = db,
                                cdmSchema = cdm_schema,
                                writeSchema = write_schema,
                                cdmName = db_name,
                                writePrefix = study_prefix)

# Study start date -----
# The earliest start date for this study "2012-01-01".
# Please put the study start date as "2012-01-01 if you have usable data from 2012 onwards.
# If you do not have data from 2012 onwards please put the earliest date possible for your data.
# For example if you only have usable data from 2015 you would put 2015-01-01.
study_start <- "2012-01-01"

# Minimum cell count
# This is the minimum counts that can be displayed according to data governance.
min_cell_count <- 5

# Run the study ------
# For now please leave only run_cdm_snapshot and run_drug_exposure_diagnostics as TRUE, and keep 
# run_main_study as FALSE. 
run_cdm_snapshot <- TRUE
run_instantiate_cohorts <- TRUE
run_drug_exposure_diagnostics <- TRUE
run_drug_utilisation <- FALSE
run_characterisation <- FALSE
run_incidence <- FALSE


# Run the study
source(here("RunStudy.R"))

# after the study is run you should have a zip folder in your output folder to share
cli::cli_alert_success("Study finished")
