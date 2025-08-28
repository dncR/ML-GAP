# UI SECTION ----
# UI with fluidPage
{ui <- fluidPage(
  # Set Bootstrap Theme (Global)
  # theme = bs_theme(version = 5),
  
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
      h2("ML-GAP2: A Machine Learning-Enhanced Genomic Analysis Pipeline Using Data Augmentation with GANs and MixUp!", class = "app_title"),
      
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
        img(src = "www/figure/Capture.PNG", width = 300, height = 300, style = "max-width: 100%; height: auto;"),
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
      class = "app_title",
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
          ),
          
          # Select response variable
          div(
            hr(style = "margin: 15px -10px; padding: 0px; border-color: #bebebe"),
            selectInput(inputId = "responseVar", label = "Response Variable", choices = NULL, selected = NULL),
            span(
              tags$b("Note"),
              ": Showing the first five columns only. Make sure that your response variable", 
              "is one of corresponding columns.")
          )
        ),
        
        ## Analysis ----
        conditionalPanel(
          condition = "input.tabs1 == 'Analysis'",
          div(
            radioButtons("dimReduction", label = "Dimension Reduction", 
                         choiceNames = list("Off", "On"),
                         choiceValues = list("off", "on"),
                         inline = TRUE, selected = "on"),
            
            radioButtons("dataAugmentation", label = "Data Augmentation (MixUp)", 
                         choiceNames = list("Off", "On"),
                         choiceValues = list("off", "on"),
                         inline = TRUE, selected = "on"),
            
            radioButtons("differentialExpression", label = "Differential Expression (DESeq)", 
                         choiceNames = list("Off", "On"),
                         choiceValues = list("off", "on"),
                         inline = TRUE, selected = "on")
            # div(
            #   style = "margin-left: 10px!important;",
            #   conditionalPanel(
            #     condition = "input.dimReduction == 'on'",
            #     numericInput("nDimsPCA", label = "Number of features", value = 2, min = 2, width = "150px")
            #   )
            # )
          ),
          
          div(style = "margin-top: 30px;"),
          
          fluidRow(
            column(
              width = 12,
              div(
                actionButton(
                  inputId = "analysisOptionsModal", 
                  label = "Options", 
                  icon = icon(name = "cog", lib = "glyphicon", style="margin-right: 5px;")
                ),
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
                'Dimension Reduction (PCA/t-SNE)', 
            
                # Container for the PCA and t-SNE analysis results.
                uiOutput(outputId = "analysis_tableContainer1", inline = FALSE),
                
                # Container for the PCA and t-SNE plots.
                uiOutput(outputId = "analysis_plotContainer1", inline = FALSE)
              ),
              
              tabPanel(
                title = 'Data Augmentation',
                
                # Container for the summary statistics of augmented and raw data.
                uiOutput(outputId = "augRes_tableContainer", inline = FALSE),
                
                # Container for the plots of augmented and raw data.
                uiOutput(outputId = "augRes_plotContainer", inline = FALSE)
              ),
              
              tabPanel('Agreement', DTOutput('MethodComparison')),
              tabPanel('Differential Expression', DTOutput('DifferentialExpression'))
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
        verbatimTextOutput("params"),
        verbatimTextOutput("console")
      )
    )
  )
)}
