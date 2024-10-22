# ADD NECESSARY PACKAGES

library(CDMConnector)
library(DBI)
library(log4r)
library(dplyr)
library(here)

# database metadata and connection details
# The name/ acronym for the database
dbName <- "..."

# Database connection details
# In this study we also use the DBI package to connect to the database
# set up the dbConnect details below
# https://darwin-eu.github.io/CDMConnector/articles/DBI_connection_examples.html 
# for more details.
# you may need to install another package for this 
# eg for postgres 
# db <- dbConnect(
#   RPostgres::Postgres(), 
#   dbname = server_dbi, 
#   port = port, 
#   host = host, 
#   user = user,
#   password = password
# )
db <- dbConnect("...")

# The name of the schema that contains the OMOP CDM with patient-level data
cdmSchema <- "..."

# A prefix for all permanent tables in the database
writePrefix <- "..."

# The name of the schema where results tables will be created 
writeSchema <- c(schema = "...", prefix = writePrefix)

# The name of the schema that contains the results from running Achilles package
# it can be removed if Achilles stables are not needed.
achillesSchema <- "..."

# minimum counts that can be displayed according to data governance
minCellCount <- 5

# Run the study
source(here("RunStudy.R"))

# after the study is run you should have a zip folder in your output folder to share
cli::cli_alert_success("Study finished")
