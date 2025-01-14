# Trends in the use of commonly used antibiotics associated with antimicrobial resistance
<img src="https://img.shields.io/badge/Study%20Status-Started-blue.svg" alt="Study Status: Started">

## Overview

- **Study title**: Trends in the use of commonly used antibiotics associated with antimicrobial resistance
- **Study leads**:
- **ShinyApp**:
- **Publications**:

---

### Prerequisites

-   **R** and **RStudio** are required to run the code.
-   Ensure that you have access to the database and necessary credentials to connect.

### Setup Instructions

1.  **Download the Repository**\
    Download this repository:

    -   Either download as a ZIP file using `Code -> Download ZIP`, then unzip.
    -   Or, use GitHub Desktop to clone the repository.

2.  **Open the R Project**

    -   Navigate to the `Study` folder and open the project file `Study.Rproj` in RStudio.
    -   You should see the project name in the top-right corner of your RStudio session.

3.  **Run the Analysis Code**

    -   Open the `CodeToRun.R` file. This is the main script you’ll use.
    -   Follow the instructions within the file to add your database-specific information.
    -   Run the code as directed. This will generate a `Results` folder containing the outputs, including a ZIP file with the results for sharing.

4.  **OPTIONAL: Visualize Results in Shiny**

    -   Navigate to the `Report` folder, then the `DED_shiny` folder, and open the project file `DrugExposureDiagnosticsShiny.Rproj` in RStudio.
    -   You should see the project name in the top-right corner of your RStudio session.
    -   Copy the generated result file (in .zip format) into the `data` folder located within the `DED_shiny` folder.
    -   Open the `global.R` script in the `DED_shiny` folder.
    -   Click the *Run App* button in RStudio to launch the local Shiny app for interactive exploration of the results.
---
This repo is organized as follows:
- [Study](https://github.com/oxford-pharmacoepi/HDRUK-01-001-Antibiotics/blob/main/Study/): please find there the relevant code to obtain the study results.
- [Report](https://github.com/oxford-pharmacoepi/HDRUK-01-001-Antibiotics/blob/main/Report/): please find there the code to visualise the results with the shiny app and generate the report with the plots and tables.
