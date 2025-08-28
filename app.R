# Global Options (Shiny App)
options(shiny.maxRequestSize = 30 * (1024^2))  # Max upload size is 30 MB. 

# Load required libraries
library(shiny)
library(dplyr)
library(DT)
library(ggplot2)
library(Rtsne)
# library(DESeq2)
library(forcats)
library(bslib)

# Load local R files
## Ensure static files under `www/` are served at `/www/...` paths
shiny::addResourcePath(prefix = "www", directoryPath = "www")

source('R/00_global.R')
source('R/helper_functions.R')
source('R/MixUp.R')
source('R/ui.R')
source('R/server.R')

# Run Shiny App
shinyApp(ui, server)
