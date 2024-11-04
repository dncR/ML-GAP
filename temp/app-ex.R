shinyApp(
  ui = basicPage(
    actionButton("go", "Go 100"),
    numericInput("from", "From", min = 1, value = 1),
    numericInput("to", "To", min = 1, value = 10),
    uiOutput("warning"),
    DTOutput("data"),
    verbatimTextOutput("console")
  ),
  
  server = function(input, output, session) {
    
    rVals <- reactiveValues(from = NA, to = NA)
    
    dataM <- reactive({
      mtcars
    })
    
    showWarning <- function(){
      div(
        style = "margin-top: 10px; margin-bottom: 10px; border: 1px solid #aeaeae;",
        span(
          tags$p(
            style = "color: red; padding: 10px 5px; margin: 0px;",
            tags$b("Warning: "),
            "'from' value cannot be greater than 'to' value"
          )
        )
      )
    }
    
    # Store values from UI to reactive values list.
    observe({
      value <- input$from
      
      if (!is.na(value)){
        if (!is.numeric(value)){
          value <- NA
        }
      } else {
        if (is.null(value)){
          value <- NA
        }
      }
      
      rVals$from <- value
    }) %>% 
      bindEvent(input$from)
    
    observe({
      value <- input$to
      
      if (!is.na(value)){
        if (!is.numeric(value)){
          value <- NA
        }
      } else {
        if (is.null(value)){
          value <- NA
        }
      }
      
      rVals$to <- value
    }) %>% 
      bindEvent(input$to)
    
    # Sync reactive values and input values concurrently.
    # Reactive values are imported from input elements.
    # Inputs are updated using the values from reactive list.
    observe({
      updateNumericInput(inputId = "from", value = rVals$from)
    }) %>% 
      bindEvent(rVals$from)
    
    observe({
      updateNumericInput(inputId = "to", value = rVals$to)
    }) %>% 
      bindEvent(rVals$to)
    
    # Control minimum and maximum values of numeric inputs.
    observe({
      if (!is.na(rVals$from)){
        if (rVals$from < 1){
          rVals$from <- 1
        }
      }
    }) %>% 
      bindEvent(rVals$from)
    
    observe({
      if (!is.na(rVals$to)){
        DF <- dataM()
        nCol <- ncol(DF)
        
        if (nCol > 1){
          updateNumericInput(inputId = "to", max = nCol)
          if (rVals$to > nCol){
            rVals$to <- nCol
          }
        }
      }
    }) %>% 
      bindEvent(rVals$to)
    
    # Input value of "from" can not be equal or greater than the value of "to"
    observe({
      if (all(!is.na(rVals$to), !is.na(rVals$from))){
        if (rVals$from >= rVals$to){
          value <- rVals$to - 1
          
          if (value <= 0){
            rVals$to <- rVals$to + 1
          } else {
            rVals$from <- value
          }
        }
      }
    })
    
    observe({
      rVals$to <- 100
    }) %>% 
      bindEvent(input$go, ignoreInit = TRUE)
    
    output$data <- renderDT({
      if (all(!is.na(rVals$to), !is.na(rVals$from))){
        if (rVals$to > rVals$from){
          dataM()[,rVals$from:rVals$to]  
        } else {
          NULL
        }
      } else {
        NULL
      }
    })
    
    output$console <- renderPrint({
      list(
        from = input$from, to = input$to, 
        fromRV = rVals$from, toRV = rVals$to
      )
    })
    
    output$warning <- renderUI({
      showWarning()
    })
  }
)


