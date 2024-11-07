# Return the UI for a modal dialog with data selection input. If 'failed' is
# TRUE, then display a message that the previous value was invalid.
warningErrorModal <- function(text = "Text to show within model",
                              warning = FALSE, error = TRUE, easy_close = TRUE, ...) {

  footerList <- NULL
  footerList <- if (!easy_close){
    if (easy_close){
      footer = tagList(
        actionButton("closeErrorWarningModal", "Close")
      )
    }
  }

  modalDialog(
    span(text),
    footer = footerList,
    easyClose = easy_close,
  )
}

tSNEresults <- function(.data = NULL, seed = NULL, ...){
  if (is.null(.data)){
    return(NULL)
  }
  
  if (!is.null(seed) && is.numeric(seed)){
    set.seed(seed)
  }
  
  tsneFit <- try({
    .data %>%
      select(where(is.numeric)) %>%
      Rtsne(
        X = ., 
        verbose = FALSE,
        ...
      )
  })
  
  if (inherits(tsneFit, "try-error")){
    return(NULL)
  }
  
  return(tsneFit)
}
# # Show modal when file size exceeds allowed limits.
# # Remove modal when close button is clicked.
# observe({
#   if (rVals$uploadFileLimit){
#     showModal(warningErrorModal()) 
#   }
#   
#   observe({
#     removeModal()
#     rVals$uploadFileLimit <- FALSE
#   }) %>%
#     bindEvent(input$closeErrorWarningModal, ignoreInit = TRUE)
#   
# }) %>% 
#   bindEvent(rVals$uploadFileLimit, ignoreInit = TRUE)



pcaResults <- function(.data = NULL, ...){
  if (is.null(.data)){
    return(NULL)
  }
  
  pcaFit <- try({
    .data %>% 
      select(where(is.numeric)) %>% 
      prcomp(x = ., ...)
  })
  
  if (inherits(pcaFit, "try-error")){
    return(NULL)
  }
  
  return(pcaFit)
}


alertBox <- function(..., class = "alert-box", type = c("note", "error", "warning", "success")){
  type <- match.arg(type)

  iconType <- switch(
    type,
    note = "glyphicon-info-sign",
    error = "glyphicon-remove-sign",
    success = "glyphicon-ok-sign",
    warning = "glyphicon-warning-sign"
  )
  
  iconColor <- switch(
    type,
    note = "#3498db",
    error = "red",
    success = "#28b463",
    warning = "#f39c12"
  )
  
  div(
    class = paste(class, type),
    icon(paste("glyphicon", iconType), lib = "glyphicon", style=paste0("margin-right: 5px; color: ", iconColor, ";")),
    span(paste0(type, ": ")),
    ...
  )
}

# Add label to the left of given HTML element.
labelLeft <- function(..., label = ""){
  div(
    style = "display: flex; align-items: center; margin-top: 5px;",
    tags$label(label, style = "margin-right: 10px; margin-bottom: 15px!important;"),
    ...
  )
}

# Add title with hr under it.
blockTitle <- function(title = "", hr = TRUE, ...){
  div(
    h5(title, style = "margin: 0px!important; padding: 0px!important; color: #004080; font-weight: bold"),
    if (hr){
      hr(style = "margin: 10px 0px; padding: 0px; border-color: #bebebe")
    }
  )
}