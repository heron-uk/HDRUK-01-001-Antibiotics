# ADD NECESSARY PACKAGES

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
                password = "...")

cdm_schema <- "..."
write_schema <- "..."

# Table prefix -----
# any tables created in the database during the analysis will start with this prefix
# we provide the default here but you can change it
# note, any existing tables in your write schema starting with this prefix may
# be dropped during running this analysis
study_prefix <- "..."

# create cdm reference -----
cdm <- CDMConnector::cdm_from_con(con = db,
                                  cdm_schema = cdm_schema,
                                  write_schema = c(schema = write_schema,
                                                   prefix = study_prefix),
                                  cdm_name = db_name)

study_start <- "..."

run_drug_exposure_diagnostics <- TRUE
run_drug_utilisation <- TRUE
run_incidence <- TRUE
run_characterisation <- TRUE

# Run the study
source(here("RunStudy.R"))

# after the study is run you should have a zip folder in your output folder to share
cli::cli_alert_success("Study finished")
