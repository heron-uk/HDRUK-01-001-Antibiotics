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

cdm_schema <- "..."
write_schema <- "..."

# Table prefix -----
# any tables created in the database during the analysis will start with this prefix
# we provide the default here but you can change it
# note, any existing tables in your write schema starting with this prefix may
# be dropped during running this analysis
study_prefix <- "..."

# create cdm reference -----
cdm <- CDMConnector::cdmFromCon(con = db,
                                cdmSchema = cdm_schema,
                                writeSchema = c(schema = write_schema,
                                                prefix = study_prefix),
                                cdmName = db_name,
                                writePrefix = study_prefix)

study_start <- "..."

run_cdm_snapshot <- TRUE
run_drug_exposure_diagnostics <- TRUE
run_instantiate_cohorts <- FALSE
run_drug_utilisation <- FALSE
run_incidence <- FALSE
run_characterisation <- FALSE
run_indications <- FALSE
export_results <- FALSE

# Run the study
source(here("RunStudy.R"))

# after the study is run you should have a zip folder in your output folder to share
cli::cli_alert_success("Study finished")
