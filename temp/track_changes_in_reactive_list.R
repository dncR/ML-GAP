library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Track Changes in Reactive Values"),
  
  numericInput("num_param", "Numeric Parameter", value = 10),
  checkboxInput("checkbox_param", "Checkbox Parameter", value = TRUE),
  
  verbatimTextOutput("change_status")
)

# Define server
server <- function(input, output, session) {
  
  # Reactive values to hold the parameters
  params <- reactiveValues(
    num_param = 10,
    checkbox_param = TRUE
  )
  
  # Keep a record of the original values
  original_values <- list(
    num_param = 10,
    checkbox_param = TRUE
  )
  
  # Update params when inputs change
  observe({
    params$num_param <- input$num_param
    params$checkbox_param <- input$checkbox_param
  })
  
  # Track changes by comparing current values to original values
  changes <- reactive({
    list(
      num_param_changed = params$num_param != original_values$num_param,
      checkbox_param_changed = params$checkbox_param != original_values$checkbox_param
    )
  })
  
  # Display change status
  output$change_status <- renderPrint({
    changes_status <- changes()
    
    if (any(unlist(changes_status))) {
      "Changes detected in parameters!"
    } else {
      "No changes detected."
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
