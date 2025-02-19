db_names <- unique(data[[1]]$cdm_name) 


db_list <- paste0("- ", db_names, collapse = "\n")


background_md <- glue::glue("
# Trends in the use of commonly used antibiotics associated with antimicrobial resistance

This Shiny app presents the results of analyses conducted on the following databases:

{db_list}

The analyses include:

- A snapshot of the CDM.

- Count of most prescribed antibiotics.

- Counts of missing data points.

- Results from drug utilisation.

- Characteristics of antibiotics users.

- Overlap between cohorts.

- Large scale characteristics of antibiotics users.

- Incidence rates of antibiotic use.



![](hdruk_logo.svg){width='100px'}
")
writeLines(background_md, "background.md")
