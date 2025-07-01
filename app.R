source('R/00_global.R')
source('R/helper_functions.R')
source('R/MixUp.R')
source('R/ui.R')
source('R/server.R')

shinyApp(ui, server)
