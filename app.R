# UI SECTION ----
# UI with fluidPage
{ui <- fluidPage(
  # Custom CSS definitions
  # Include the custom CSS file from the css folder
  # tags$head(
  #   tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css")
  # ),
  includeCSS(path = "www/css/styles.css"),
  
  conditionalPanel(
    condition = "!input.startAnalysis",
    div(
      id = "Introduction",
      class = "intro-page",
      
      # Application title
      h2("ML-GAP2: A Machine Learning-Enhanced Genomic Analysis Pipeline Using Data Augmentation with GANs and MixUp!"),
      
      HTML('<p>Leveraging the power of machine learning and data augmentation, our workflow efficiently handles large-scale 
        RNA-seq data for molecular insights in diseases like pulmonary hypertension. RNA-seq analysis is fundamental in 
        modern medicine, offering deep molecular profiling. However, dealing with high-dimensional, low-sample datasets 
        presents unique challenges in both binary and multiclass classification problems.</p>'),
      
      HTML('<p align="justify">In response, we developed an intuitive and robust framework. This approach integrates state-of-the-art 
        augmentation techniques, explainable AI models, and advanced statistical controls to generate reliable, 
        interpretable outcomes. Through this platform, users can perform RNA-seq analysis with ease, gaining critical 
        insights into gene expression and disease mechanisms, while enhancing their machine learning capabilities.</p>'),
      
      div(
        class = "centered",
        img(src = "figure/Capture.PNG", width = 300, height = 300, style = "max-width: 100%; height: auto;"),
        style = "margin-top: 20px!important"
      )
    ),
    
    div(
      class = "centered",
      actionButton("startAnalysis", label = "Start ML-GAP", class = "btn-success", 
                   icon = icon("play-circle", lib = "glyphicon", style="margin-right: 5px;"), 
                   style = "font-size: 16px!important;border-radius: 8px;"),
      style = "margin-top: 20px!important; margin-bottom: 20px!important"
    )
  ),
  
  conditionalPanel(
    condition = "input.startAnalysis",
    div(
      # class = "bordered-div",
      # style = "margin-top: 10px!important;",
      titlePanel(
        title = "ML-GAP2: A Machine Learning-Enhanced Genomic Analysis Pipeline Using Data Augmentation with GANs and MixUp",
        windowTitle = "ML-GAP2"
      )
    ),
    
    sidebarLayout(
      # Sidebar Panel ----
      sidebarPanel(
        width = 3,
        
        ## Data Upload ----
        conditionalPanel(
          "input.tabs1 == 'Data Upload'",
          radioButtons(
            inputId = "selectData", 
            label = "Choose data:",
            choices = c(
              "Example data" = "example",
              "Upload data" = "upload"
            ), 
            inline = TRUE,
            selected = "example"
          ),
          
          conditionalPanel(
            "input.selectData == 'example'",
            selectizeInput(
              inputId = "exampleDataSets", 
              label = "Select Data:", 
              choices = c(
                "Iris" = "1", 
                'mtcars' = "2",
                "Cervical cancer" = "3"
              ), selected = 2,
              width = "100%"
            )
          ),
          
          conditionalPanel(
            "input.selectData == 'upload'",
            HTML('<br>'),
            # h5("Upload a delimited text file (max. 30MB)"),
            fileInput("upload", "Upload a delimited text file (max. 30MB)", multiple = FALSE),
            radioButtons(
              inputId = "fileSepDF", 
              label = "Delimiter:", 
              choices = list("Comma" = 1, "Tab" = 2, "Semicolon" = 3),
              selected = 1
            ),
            
            conditionalPanel(
              condition = "input.fileSepDF != '1'",
              checkboxInput(inputId = "decimal", label = "Use comma as decimal mark", value = FALSE)
            ),
            
            checkboxInput("rowNamesIncluded", label = "First column includes row names", value = FALSE),
            
            HTML('<br>'),
            HTML('<p>You can upload your data (<strong>.txt</strong> or <strong>.csv</strong>) separated by comma, tab, or semicolon.</p>'),
            HTML('<p><b>Note</b>: By default, first row must be the header including the variable names.</p>')
          )
        ),
        
        ## Analysis ----
        conditionalPanel(
          condition = "input.tabs1 == 'Analysis'",
          checkboxGroupInput(
            inputId = "featureSelectionMethod",
            label = "Feature Selection (DE Genes):", 
            choiceNames = list("DESeq", "PCA"),
            choiceValues = list("deseq", "pca"),
            selected = "deseq"
          ),
          
          checkboxGroupInput(
            inputId = "statisticalCheckMethod", 
            label = "Statistical Check (Augmented Data):", 
            choiceNames = list("Deming regression", "Concordance Correlation Coefficient"),
            choiceValues = list("deming", "ccc"),
            selected = "deming"
          ),
          
          div(style = "margin-top: 30px;"),
          
          fluidRow(
            column(
              width = 12,
              div(
                actionButton("analysisOptionsModal", "Options", 
                             icon = icon(name = "cog", lib = "glyphicon", style="margin-right: 5px;")),
                style = "float: left;"
              )
            )
          ),
          hr(style = "border-color: #bebebe"),
          
          fluidRow(
            column(
              width = 12,
              div(
                style = "float: right; margin: 0px 10px 0px 0px!important;",
                span(
                  icon("question-sign", lib = "glyphicon", style="margin-right: 0px;"), 
                  tags$a(href = "about:blank", "Manual", target = "_blank")
                ),
                actionButton("resetAnalysisInputs", "Reset", style = "margin-left: 10px;"),
                actionButton("runAnalysis", "Run", class = "btn-success")
              )
            )
          ),
          
          div(
            uiOutput(outputId = "alertBoxForRunButton", inline = FALSE)
          )
        )
      ),
      
      # Main Panel ----
      mainPanel(
        width = 9,
        tabsetPanel(
          id = "tabs1", 
          type = "pills",
          
          ## Data Upload ----
          tabPanel(
            title = "Data Upload",
            HTML('<br>'),
            navbarPage(
              title = '',
              tabPanel(
                'Data', 
                uiOutput("colSelectorContainer", inline = FALSE),
                DTOutput('RawData'),
                verbatimTextOutput("reactive")
              )
            )
          ),
          
          ## Analysis ----
          tabPanel(
            title = "Analysis",
            downloadButton("downloadROCStats", "Download t-SNE statistics as txt-file"),
            navbarPage(
              id = "navbarAnalysis",
              title = '',
              tabPanel(
                'PCA/t-SNE Figure', 
                
                # Container for the PCA and t-SNE analysis results.
                uiOutput(outputId = "analysis_tableContainer1", inline = FALSE),
                
                # Container for the PCA and t-SNE plots.
                uiOutput(outputId = "analysis_plotContainer1", inline = FALSE)
              ),
              
              tabPanel(
                title = 'Augmentation Results',
                DTOutput('Augmentationcoordinates')
              ),
              
              tabPanel('Statistical Check', DTOutput('Statisticalcomparisons')),
              tabPanel('Dimension Reduction', DTOutput('Dimensioncomparisons'))
            )
          ),
          
          ## Gene Ontology ----
          tabPanel(
            title = "Gene Ontology",
            h4(""),
            HTML('<p> </p>')
          ),
          
          ## Manual ----
          tabPanel(
            title = "Manual",
            img(src = "figure/manuel.PNG", width = 1000, height = 600)
          )
        ),
        
        div(style = "margin-top:50px!important;"),
        h3("Inputs:"),
        verbatimTextOutput("params")
      )
    )
  )
)}


# SERVER SECTION ----
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#
# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  current_AnalysisOptionsModal <- reactiveValues(
    PCA_tSNE_plots = analysisOptionsModalDefaults$PCA_tSNE_plots,
    Augmentation = analysisOptionsModalDefaults$Augmentation,
    FeatureSelection = analysisOptionsModalDefaults$FeatureSelection
  )
  
  # Controllers -----
  # Define List of controllers (Reactive Values)
  # Global controllers
  ctrl_Global <- reactiveValues(
    data = FALSE
  )
  
  # Controllers for "Analysis" tab
  ctrl_Analysis <- reactiveValues(
    tSNEplotSucess = TRUE, 
    PCAplotSucess = TRUE,
    update = FALSE
  )
  
  # Controllers for "Data Upload" tab
  ctrl_DataUpload <- reactiveValues(
    colFrom = NA, 
    colTo = NA
  )
  
  cervicalCancerData <- reactive({
    read.table("data/CervicalCO.txt", header = TRUE, sep = "\t", row.names = 1)
  })
  
  # Upload/Load (example) data matrix
  dataM <- reactive({  ## Data input.
    if (input$selectData == "example"){  ## Load example data.
      data <- switch(
        input$exampleDataSets,
        '1' = iris,
        '2' = mtcars,
        '3' = cervicalCancerData()
      )
    } else if (input$selectData == "upload"){  ## Upload data.
      inFile <- input$upload
      mySep <- switch(input$fileSepDF, '1'=",",'2'="\t",'3'=";", '4'="")
      
      if (is.null(input$upload)){
        return(NULL)
      }
      
      if (file.info(inFile$datapath)$size <= 31457280){
        data <- try({
          read.table(inFile$datapath, sep = mySep, header = TRUE, fill = TRUE, 
                     dec = ifelse(input$decimal, ",", "."))
        })
        
        if (inherits(data, "try-error")){
          return(NULL)
        }
        
        if (!is.data.frame(data) | !(ncol(data) >= 1)){
          return(NULL)
        }
        
        if (input$rowNamesIncluded){
          if (ncol(data) > 1){
            data_tmp <- data[ ,-1]
            rownames(data_tmp) <- data[[1]]
            data <- data_tmp
            rm(data_tmp)
          } else {
            data <- NULL
          }
        }
      } else {
        data <- NULL
      }
    }
    
    return(data)   
  })
  
  # Triggering dataM() reactive and validating if data is valid or not.
  # getData() is used globally to bring active dataset (i.e., either example or uploaded data)
  getData <- function(){
    DF <- dataM()
    
    if (is.null(DF)){
      ctrl_Global$data <- FALSE
    } else {
      ctrl_Global$data <- TRUE
    }
    
    return(DF)
  }
  

  # Observers controlling the values of "colTo" and "colFrom" under Data Upload tab
  {# Assign default values to colFrom and colTo at start.
    observe({
      DF <- getData()
      nC <- ncol(DF)
      
      if (!is.null(nC) & nC > 1){
        ctrl_DataUpload$colFrom <- 1
        if (nC > 10){
          nC <- 10  
        }
        ctrl_DataUpload$colTo <- nC
      }
    }) %>% 
      bindEvent(input$startAnalysis, once = TRUE)
    
    # Store values from UI to reactive values list.
    observe({
      value <- input$colFrom

      if (!is.na(value)){
        if (!is.numeric(value)){
          value <- NA
        }
      } else {
        if (is.null(value)){
          value <- NA
        }
      }
      
      ctrl_DataUpload$colFrom <- value
    }) %>% 
      bindEvent(input$colFrom)
    
    observe({
      value <- input$colTo
      
      if (!is.na(value)){
        if (!is.numeric(value)){
          value <- NA
        }
      } else {
        if (is.null(value)){
          value <- NA
        }
      }
      
      ctrl_DataUpload$colTo <- value
    }) %>% 
      bindEvent(input$colTo)
    
    # Control minimum and maximum values of numeric inputs.
    observe({
      if (!is.na(ctrl_DataUpload$colFrom)){
        if (ctrl_DataUpload$colFrom < 1){
          ctrl_DataUpload$colFrom <- 1
        }
      }
    }) %>% 
      bindEvent(ctrl_DataUpload$colFrom)
    
    observe({
      if (!is.na(ctrl_DataUpload$colTo)){
        DF <- getData()
        nCol <- ncol(DF)
        
        if (nCol > 1){
          updateNumericInput(inputId = "colTo", max = nCol)
          if (ctrl_DataUpload$colTo > nCol){
            ctrl_DataUpload$colTo <- nCol
          }
        }
      }
    }) %>% 
      bindEvent(ctrl_DataUpload$colTo)
    
    # Input value of "from" can not be equal or greater than the value of "to"
    observe({
      if (all(!is.na(ctrl_DataUpload$colTo), !is.na(ctrl_DataUpload$colFrom))){
        if (ctrl_DataUpload$colFrom >= ctrl_DataUpload$colTo){
          value <- ctrl_DataUpload$colTo - 1
          
          if (value <= 0){
            ctrl_DataUpload$colTo <- ctrl_DataUpload$colTo + 1
          } else {
            ctrl_DataUpload$colFrom <- value
          }
        }
      }
    })
    
    # Sync reactive values and input values concurrently.
    # Reactive values are imported from input elements.
    # Inputs are updated using the values from reactive list.
    observe({
      updateNumericInput(inputId = "colFrom", value = ctrl_DataUpload$colFrom)
    }) %>% 
      bindEvent(ctrl_DataUpload$colFrom)
    
    observe({
      updateNumericInput(inputId = "colTo", value = ctrl_DataUpload$colTo)
    }) %>% 
      bindEvent(ctrl_DataUpload$colTo)}
  
  # Observers controlling the "Run" button under analysis tab, related warnings and update behaviors.
  {# If clicked on "Run" button under analysis tab, button label reset to ""Run".
    observe({
      updateActionButton(inputId = "runAnalysis", label = "Run", disabled = TRUE)
      ctrl_Analysis$update <- FALSE
    }) %>% 
      bindEvent(input$runAnalysis, ignoreInit = TRUE)
    
    observe({
      # Disable Run button after results are updated.
      if (ctrl_Analysis$update){
        updateActionButton(inputId = "runAnalysis", disabled = FALSE)
      }
      
      # Activate Run button if data is changed.
      observe({
        ctrl_Analysis$update <- TRUE
      }) %>% 
        bindEvent(input$selectData, ignoreInit = TRUE)
      
      observe({
        ctrl_Analysis$update <- TRUE
      }) %>% 
        bindEvent(input$exampleDataSets, ignoreInit = TRUE)
    })
    
    observe({
      ctrl_Analysis$update <- TRUE
    }) %>% 
      bindEvent(input$featureSelectionMethod, ignoreInit = TRUE, ignoreNULL = FALSE)
    
    output$alertBoxForRunButton <- renderUI({
      if (ctrl_Analysis$update){
        alertBox(
          style = "margin-left: 0px!important; margin-right: 0px!important; font-size: 85%!important;",
          type = "warning",
          'Input(s) have changed. Please re-run the analysis.'
        )
      } else {
        div()
      }
    }) %>% 
      bindEvent(ctrl_Analysis$update)}
  
  
  # Render UI to show Note text above data table which informs the researchers about the number of columns.
  output$colSelectorContainer <- renderUI({
    setWidthDTcolumns <- function(x){
      w <- if (x < 10){
        "50px"
      } else if (x >= 10 & x < 100){
        "70px"
      } else  if (x >= 100 & x < 1000){
        "90px"
      } else {
        "120px"
      }
      return(w)
    }
    
    DF <- getData()
    numCol <- ncol(DF)
    
    if (all(!is.null(numCol), numCol > 10)){
      tagList(
        div(
          style = "border: 1px solid #aeaeae; padding: 10px; margin-bottom: 20px; background: #fbfbfb;",
          div(
            style = "margin-bottom: 10px;",
            span(
              tags$b("Note: ", style = "color:red;"), 
              'Your data may have too many columns (e.g., >10) to fit page width. ',
              'If not specified otherwise, below table shows first 10 columns of complete data by default. ',
              'Change column range to show in the table.'
            )
          ),
          
          div(
            tags$b(paste0("Show Columns (max. ", numCol, ")")),
            div(
              style = "display: flex; align-items: center;",  # Flexbox for horizontal alignment
              numericInput("colFrom", "From", value = 1, min = 1, max = numCol - 1, width = setWidthDTcolumns(numCol)),
              span(style = "margin-right: 20px;", ""),
              numericInput("colTo", "To", value = 10, min = 2, max = numCol, width = setWidthDTcolumns(numCol))
            )
          )
        )
      )
    } else {
      div()
    }
  })
  
  output$analysis_tableContainer1 <- renderUI({
    tagList(
      h4("> Principal Components Analysis Results:", style = "margin-bottom: 20px; font-weight: 900"),
      if (ctrl_Global$data){
        div(
          style = "margin-bottom: 20px!important;",
          DTOutput('PCA_ImportanceResults'),
          uiOutput(outputId = "PCA_ImportanceResults_Notes", inline = FALSE)
        )
      } else {
        alertBox(
          type = "error",
          'Retrieving data is not successfull.', 
          'Please check your data is correctly loaded/uploaded.'
        )
      }
    )
  }) %>% 
    bindEvent(input$runAnalysis)
  
  output$analysis_plotContainer1 <- renderUI({
    tagList(
      h4("> Plots", style = "margin-bottom: 20px!important; margin-top: 20px!important; font-weight: 900"),  
      if (ctrl_Global$data){
        div(
          fluidRow(
            column(
              class = "add-right-margin",
              width = 6,
              uiOutput("analysis_plotContainer1_PCA")
            ),
            column(
              width = 6,
              uiOutput("analysis_plotContainer1_tSNE")
            )
          )
        )
      } else {
        alertBox(
          type = "error",
          'Cannot draw PCA and/or t-SNE plots.',
          'Please check your active dataset if there is (are)',
          'unexpected situations that lead to a failure in plots.'
        )
      }
    )
  }) %>% 
    bindEvent(input$runAnalysis)
  
  # Render UI for PCA plot area if PCA plot is successful.
  observe({
    output$analysis_plotContainer1_PCA <- renderUI({
      if (ctrl_Analysis$PCAplotSucess){
        plotOutput("pcaPlot")
      } else {
        alertBox(
          class = "alert-box", 
          type = "error",
          'Cannot draw PCA plot.'
        )
      }
    })
  }) %>% 
    bindEvent(ctrl_Analysis$PCAplotSucess)
  
  # Render UI for t-SNE plot area if t-SNE plot is successful.
  observe({
    output$analysis_plotContainer1_tSNE <- renderUI({
      if (ctrl_Analysis$tSNEplotSucess){
        plotOutput("tSNEplot")
      } else {
        alertBox(
          type = "error",
          'Cannot draw t-SNE plot.'
        )
      }
    })
  }) %>% 
    bindEvent(ctrl_Analysis$tSNEplotSucess)
  
  # Return the UI for a modal dialog with data selection input. If 'failed' is
  # TRUE, then display a message that the previous value was invalid.
  analysisOptionsModal <- function(){
    modalDialog(
      span('Please choose options for selected analysis methods.'),
      div(style="margin-bottom:15px;"),
      selectInput(
        inputId = "chooseAnalysisOptionsFromModal", 
        label = "Show options for:", 
        choices = list(
          "Dimension Reduction" = "dimReduction",
          "Augmentation" = "augmentation",
          "Feature Selection" = "featureSelect"
        )
      ),
      
      conditionalPanel(
        condition = 'input.chooseAnalysisOptionsFromModal == "dimReduction"',
        div(
          class = "bordered-div",
          fluidRow(
            column(
              width = 6,
              blockTitle("Parameters (t-SNE)"),
              div(
                style = "margin-top: 10px!important; ",
                div(
                  style = "margin-left: 10px!important;",
                  numericInput(inputId = "initialDimsPCA_tSNE", label = "Initial dimensions (PCA)", value = current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$initialDimsPCA_tSNE, min = 1),
                  numericInput(inputId = "preplexity_tSNE", label = "Perplexity", value = current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$preplexity_tSNE, min = 1),
                  numericInput(inputId = "maxIter_tSNE", label = "Number of iterations", value = current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$maxIter_tSNE, min = 1)
                )
              )
            ),
            column(
              width = 6,
              blockTitle("Preprocess raw data (PCA)"),
              div(
                style = "margin-left: 10px!important; margin-top: -10px!important",
                checkboxGroupInput(
                  inputId = "preprocessPCA", 
                  label = "", 
                  choiceNames = list("Center", "Scale"), 
                  choiceValues = list("centerPCA", "scalePCA"), 
                  selected = c("centerPCA", "scalePCA")[c(current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$center, current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$scale)], 
                  inline = FALSE
                )
              )
            )
          )
        )
      ),
      
      conditionalPanel(
        condition = 'input.chooseAnalysisOptionsFromModal == "augmentation"',
        div(
          class = "bordered-div",
          blockTitle("MixUp Data Augmentation"),
          fluidRow(
            column(
              width = 6,
              div(
                style = "margin-left: 10px;",
                labelLeft(
                  selectInput(
                    inputId = "method_MixUp", 
                    label = NULL, 
                    choices = c("Unbiased" = "unbiased", "Minority" = "minority", "Inner" = "inner"), 
                    selected = current_AnalysisOptionsModal$Augmentation$MixUp$method_MixUp
                  ),
                  label = "Method"
                ),
                labelLeft(
                  numericInput(
                    inputId = "alpha_MixUp", 
                    label = NULL, 
                    value = current_AnalysisOptionsModal$Augmentation$MixUp$alpha_MixUp, 
                    step = 0.01
                  ),
                  label = "Alpha"
                )
              )
            ),
            column(
              width = 6,
              div(
                style = "margin-left: 10px;",
                labelLeft(
                  numericInput(
                    inputId = "m_MixUp", 
                    label = NULL, 
                    value = current_AnalysisOptionsModal$Augmentation$MixUp$m_MixUp, 
                    min = 2, 
                    max = 50
                  ),
                  label = "Replication"
                ),
                labelLeft(
                  numericInput(
                    inputId = "y_threshold_MixUp", 
                    label = NULL, 
                    value = current_AnalysisOptionsModal$Augmentation$MixUp$y_threshold_MixUp, 
                    min = 0, 
                    max = 1,
                    step = 0.01
                  ),
                  label = "Threshold"
                )
              )
            )
          )
        )
      ),
      
      conditionalPanel(
        condition = 'input.chooseAnalysisOptionsFromModal == "featureSelect"',
        div(
          class = "bordered-div",
          fluidRow(
            column(
              width = 6,
              blockTitle("Differential Expression (DESeq)"),
              div(
                style = "margin-left: 10px;",
                labelLeft(
                  selectInput(
                    inputId = "testType_DESeq",
                    label = NULL,
                    choices = list(
                      "Wald" = "wald",
                      "Likelihood ratio" = "lrt"
                    ),
                    selected = current_AnalysisOptionsModal$FeatureSelection$DESeq$testType_DESeq
                  ),
                  label = "Hypothesis test"
                ),
                labelLeft(
                  selectInput(
                    inputId = "fitType_DESeq",
                    label = NULL,
                    choices = list(
                      "Parametric" = "parametric",
                      "Local" = "local",
                      "Mean" = "mean",
                      "Regression (GLM)"
                    ),
                    selected = current_AnalysisOptionsModal$FeatureSelection$DESeq$fitType_DESeq
                  ),
                  label = "Model fitting"
                ),
                labelLeft(
                  selectInput(
                    inputId = "sfType_DESeq",
                    label = NULL,
                    choices = list(
                      "Ratio" = "ratio",
                      "poscounts" = "poscounts",
                      "Iterate" = "iterate"
                    ),
                    selected = current_AnalysisOptionsModal$FeatureSelection$DESeq$sfType_DESeq
                  ),
                  label = "Size factor estimate"
                ),
                labelLeft(
                  selectInput(
                    inputId = "pAdjust_DESeq",
                    label = NULL,
                    choices = list(
                      "Benjamini-Hochberg" = "BH",
                      "False Discovery Rate" = "fdr",
                      "Hochberg" = "hochberg",
                      "Bonferroni" = "bonferroni",
                      "Benjamini-Yekutieli" = "BY",
                      "Holm" = "holm",
                      "Hommel" = "hommel",
                      "No correction" = "none"
                    ),
                    selected = current_AnalysisOptionsModal$FeatureSelection$DESeq$pAdjust_DESeq
                  ),
                  label = "Adjust (p-val.)"
                )
              )
            ),
            column(
              width = 6,
              blockTitle("Prin. Comp. Analysis (PCA)"),
              div(
                style = "margin-left: 10px;",
                labelLeft(
                  numericInput(
                    inputId = "nFeat_PCA",
                    label = NULL,
                    value = current_AnalysisOptionsModal$FeatureSelection$PCA$nFeat_PCA,
                    min = 2
                  ),
                  label = "Num. of Features"
                )
              )
            )
          )
        )
      ),
      
      footer = tagList(
        fluidRow(
          column(
            width = 3,
            div(
              style = "margin: 8px 0px 0px 10px!important; float: left;",
              span(
                icon("question-sign", lib = "glyphicon", style="margin-right: 0px;"), 
                tags$a(href = "about:blank", "Manual", target = "_blank")
              )
            )
          ),
          column(
            width = 9,
            div(
              style = "float: right; margin: 0px 10px 0px 0px!important;",
              actionButton("cancelAnalysisModal", "Cancel"),
              actionButton("resetAnalysisModal", "Reset"),
              actionButton("okAnalysisModal", "OK", class = "btn-success")
            )
          )
        )
      ), 
      easyClose = FALSE
    )
  }
  
  # Function to update values of elements within "Options" modal under Analysis tab.
  updateAnalysisOptionsModalElements <- function(reset = FALSE){
    if (reset){
      values <- analysisOptionsModalDefaults
    } else {
      values <- current_AnalysisOptionsModal
    }
    
    # Dimension Reduction (dimReduction)
    preprocessPCA_values <- c("centerPCA", "scalePCA")[c(values$PCA_tSNE_plots$PCA$center, values$PCA_tSNE_plots$PCA$scale)]
    updateCheckboxGroupInput(inputId = "preprocessPCA", selected = preprocessPCA_values)
    
    updateNumericInput(inputId = "initialDimsPCA_tSNE", value = values$PCA_tSNE_plots$tSNE$initialDimsPCA_tSNE)
    updateNumericInput(inputId = "preplexity_tSNE", value = values$PCA_tSNE_plots$tSNE$preplexity_tSNE)
    updateNumericInput(inputId = "maxIter_tSNE", value = values$PCA_tSNE_plots$tSNE$maxIter_tSNE)
    
    # Augmentation (augmentation)
    updateSelectInput(inputId = "method_MixUp", selected = values$Augmentation$MixUp$method_MixUp)
    updateNumericInput(inputId = "alpha_MixUp", value = values$Augmentation$MixUp$alpha_MixUp)
    updateNumericInput(inputId = "m_MixUp", value = values$Augmentation$MixUp$m_MixUp)
    updateNumericInput(inputId = "y_threshold_MixUp", value = values$Augmentation$MixUp$y_threshold_MixUp)
    
    # Feature Selection (featureSelect)
    updateSelectInput(inputId = "testType_DESeq", selected = values$FeatureSelection$DESeq$testType_DESeq)
    updateSelectInput(inputId = "fitType_DESeq", selected = values$FeatureSelection$DESeq$fitType_DESeq)
    updateSelectInput(inputId = "sfType_DESeq", selected = values$FeatureSelection$DESeq$sfType_DESeq)
    updateSelectInput(inputId = "pAdjust_DESeq", selected = values$FeatureSelection$DESeq$pAdjust_DESeq)
    updateNumericInput(inputId = "nFeat_PCA", value = values$FeatureSelection$PCA$nFeat_PCA)
  }
  
  # Save current values from inputs of modal to the current state reactive list.
  saveCurrentState_AnalysisOptionsModalElements <- function(){
    # Dimension Reduction (dimReduction)
    current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$center <- "centerPCA" %in% input$preprocessPCA
    current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$scale <- "scalePCA" %in% input$preprocessPCA
    current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$initialDimsPCA_tSNE <- input$initialDimsPCA_tSNE
    current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$preplexity_tSNE <- input$preplexity_tSNE
    current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$maxIter_tSNE <- input$maxIter_tSNE
    
    # Augmentation (augmentation)
    current_AnalysisOptionsModal$Augmentation$MixUp$method_MixUp <- input$method_MixUp
    current_AnalysisOptionsModal$Augmentation$MixUp$alpha_MixUp <- input$alpha_MixUp
    current_AnalysisOptionsModal$Augmentation$MixUp$m_MixUp <- input$m_MixUp
    current_AnalysisOptionsModal$Augmentation$MixUp$y_threshold_MixUp <- input$y_threshold_MixUp
    
    # Feature Selection (featureSelect)
    current_AnalysisOptionsModal$FeatureSelection$DESeq$testType_DESeq <- input$testType_DESeq
    current_AnalysisOptionsModal$FeatureSelection$DESeq$fitType_DESeq <- input$fitType_DESeq
    current_AnalysisOptionsModal$FeatureSelection$DESeq$sfType_DESeq <- input$sfType_DESeq
    current_AnalysisOptionsModal$FeatureSelection$DESeq$pAdjust_DESeq <- input$pAdjust_DESeq
    current_AnalysisOptionsModal$FeatureSelection$PCA$nFeat_PCA <- input$nFeat_PCA
  }
  
  # Show modal when "Options" button is clicked.
  observe({
    showModal(analysisOptionsModal())
  }) %>% 
    bindEvent(input$analysisOptionsModal)
  
  # Update the modal inputs with current values when Cancel is pressed
  observe({
    updateAnalysisOptionsModalElements()
    removeModal()
  }) %>% 
    bindEvent(input$cancelAnalysisModal)
  
  # Restore modal inputs to default values on Reset, without affecting current_values until OK is pressed
  observe({
    updateAnalysisOptionsModalElements(reset = TRUE)
  }) %>% 
    bindEvent(input$resetAnalysisModal)
  
  # Update current_values with modal inputs on OK, save this as the latest state, and close modal
  observe({
    saveCurrentState_AnalysisOptionsModalElements()
    
    # TODO 1 ----
    # Burada yalnızca genel listede bir değişim olması durumunda update TRUE olacak şekilde bir ayarlama 
    # yapılacak. Şimdilik her OK tıklandığında update edilmesini zorunlu tutuyoruz. İleride düzenlenecek.
    ctrl_Analysis$update <- TRUE
    
    removeModal()
  }) %>% 
    bindEvent(input$okAnalysisModal)
  
  # Control allowed values for analysis options (Options Modal under Analysis tab.)
  observe({
    observe({
      if (input$alpha_MixUp < 0 | is.na(input$alpha_MixUp)){
        updateNumericInput(inputId = "alpha_MixUp", value = analysisOptionsModalDefaults$Augmentation$MixUp$alpha_MixUp)
      }
    }) %>% 
      bindEvent(input$alpha_MixUp)
    
    observe({
      if (input$m_MixUp < 2 | is.na(input$m_MixUp)){
        updateNumericInput(inputId = "m_MixUp", value = analysisOptionsModalDefaults$Augmentation$MixUp$m_MixUp)
      }
      
      if (!is.na(input$m_MixUp)){
        if (input$m_MixUp > 50){
          updateNumericInput(inputId = "m_MixUp", value = 50)
        }
      }
    }) %>% 
      bindEvent(input$m_MixUp)
    
    observe({
      if (is.na(input$y_threshold_MixUp)){
        val <- analysisOptionsModalDefaults$Augmentation$MixUp$y_threshold_MixUp
        updateNumericInput(inputId = "y_threshold_MixUp", value = val)
      } else {
        if (input$y_threshold_MixUp < 0){
          val <- 0.01
          updateNumericInput(inputId = "y_threshold_MixUp", value = val)
        }
        if (input$y_threshold_MixUp > 1){
          val <- 0.99
          updateNumericInput(inputId = "y_threshold_MixUp", value = val)
        }
      }
    }) %>% 
      bindEvent(input$y_threshold_MixUp)
  }) %>% 
    bindEvent(input$analysisOptionsModal, ignoreInit = TRUE)
  
  # PCA & tSNE results
  pcaRes <- reactive({
    DF <- getData()
    res <- pcaResults(
      .data = DF, 
      center = current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$center, 
      scale. = current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$scale
    )
    
    return(res)
  })
  
  tSNEres <- reactive({
    DF <- getData()
    res <- tSNEresults(
      .data = DF,
      initial_dims = current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$initialDimsPCA_tSNE,
      perplexity = current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$preplexity_tSNE,
      max_iter = current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$maxIter_tSNE,
      pca_center = current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$center,
      pca_scale = current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$scale,
      check_duplicates = FALSE
    )
    
    return(res)
  })
  
  # Print Raw data to the app
  output$RawData <- renderDT({
    DF <- getData()
    nCol <- ncol(DF)
    
    if (!ctrl_Global$data){
      return(NULL)
    }
    
    if (nCol < 10){
      return(DF)
    } else {
      if (all(!is.na(ctrl_DataUpload$colTo), !is.na(ctrl_DataUpload$colFrom))){
        if (ctrl_DataUpload$colTo > ctrl_DataUpload$colFrom & ctrl_DataUpload$colTo <= nCol){
          DF <- DF[,ctrl_DataUpload$colFrom:ctrl_DataUpload$colTo]
        } else {
          DF <- NULL
        }
      } else {
        DF <- NULL
      }
    }
    
    return(DF)
  })
  
  output$PCA_ImportanceResults <- renderDT({
    res <- pcaRes()
    
    if (is.null(res)){
      output$PCA_ImportanceResults_Notes <- renderUI({
        div()
      })
      return(NULL)
    }
    
    res_summary <- summary(res)
    tblPrint <- res_summary$importance
    tblPrint <- round(tblPrint, 4)
    
    output$PCA_ImportanceResults_Notes <- if (ncol(tblPrint) > 10){
      renderUI({
        alertBox(
          type = "note",
          'PCA results table has too many columns (e.g., >10) to fit page width. ',
          'Top 10 principal components are printed in the PCA results table.'
        )
      })
    } else {
      renderUI({
        div()
      })
    }
    
    if (ncol(tblPrint) > 10){
      return(tblPrint[, 1:10])
    }
    
    return(tblPrint)
  }) %>% 
    bindEvent(input$runAnalysis)
  
  # Initialize plotData to draw PCA plot.
  analysis_plotContainer1_PCA_init <- reactive({
    res <- pcaRes()
    
    if (is.null(res)){
      ctrl_Analysis$PCAplotSucess <- FALSE
      return(NULL)
    }
    
    pcaData <- as.data.frame(res$x)
    
    if (ncol(pcaData) == 1){
      ctrl_Analysis$PCAplotSucess <- FALSE
      return(NULL)
    }
    
    ctrl_Analysis$PCAplotSucess <- TRUE
    return(pcaData)
  })
  
  observe({
    plotData <- analysis_plotContainer1_PCA_init()
    
    if (!is.null(plotData) & ctrl_Analysis$PCAplotSucess){
      output$pcaPlot <- renderPlot({
        customTheme <- theme(
          panel.grid = element_blank()
        )
        
        ggplot(plotData, aes(x = PC1, y = PC2)) +
          theme_bw(base_size = 14) +
          customTheme +
          geom_point(size = 4, colour = rgb(0, 0, 1, .4)) +
          labs(title = "PCA: First two principal components", x = "PC1", y = "PC2")
      })
    }
  }) %>% 
    bindEvent(input$runAnalysis)
  
  # Initialize plotData to draw PCA plot.
  analysis_plotContainer1_tSNE_init <- reactive({
    res <- tSNEres()
    
    if (is.null(res)){
      ctrl_Analysis$tSNEplotSucess <- FALSE
      return(NULL)
    }
    
    tsneData <- as.data.frame(res$Y)
    colnames(tsneData) <- c("Dim1", "Dim2")
    ctrl_Analysis$tSNEplotSucess <- TRUE
    
    return(tsneData)
  })
  
  observe({
    plotData <- analysis_plotContainer1_tSNE_init()
    
    if (!is.null(plotData) & ctrl_Analysis$tSNEplotSucess){
      output$tSNEplot <- renderPlot({
        customTheme <- theme(
          panel.grid = element_blank()
        )
        
        ggplot(plotData, aes(x = Dim1, y = Dim2)) +
          theme_bw(base_size = 14) +
          customTheme +
          geom_point(size = 4, colour = rgb(1, 0, 0, .4)) +
          labs(title = "t-SNE: Dimensionality Reduction", x = "Dimension 1", y = "Dimension 2")
      })
    }
  }) %>% 
    bindEvent(input$runAnalysis)
  
  output$params <- renderPrint({
    list(
      dimensionReductionMethod = input$dimensionReductionMethod,
      rVals_colFrom = ctrl_DataUpload$colFrom,
      rVals_colTo = ctrl_DataUpload$colTo,
      uploadedFile = input$upload,
      nCol = ncol(dataM()),
      dataValid = ctrl_Global$data,
      tSNEplot = ctrl_Analysis$tSNEplotSucess,
      PCAplot = ctrl_Analysis$PCAplotSucess,
      modalInput = input$preprocessPCA,
      modal2 = input$preplexity_tSNE,
      modal2_rVal = current_AnalysisOptionsModal$PCA_tSNE_plots$tSNE$preplexity_tSNE,
      ctrlModalPCA = current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$center,
      ctrlModalPCA2 = current_AnalysisOptionsModal$PCA_tSNE_plots$PCA$scale,
      updated = ctrl_Analysis$update
    )
  })
}

# Execute shiny app
shinyApp(ui, server)