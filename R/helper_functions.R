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

# Add table caption
tableCaption <- function(caption_text = NULL, font_size = "16px", font_color = "#004080",
                         style = "margin-bottom: 10px!important", ...){
  div(
    style = style,
    span(tags$b("Table"), ": ", caption_text, style = paste0("font-size: ", font_size, ";", "color: ", font_color))
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

sectionTitle <- function(title = "", ...){
  div(
    h4(paste0("> ", title), style = "margin-bottom: 20px; font-weight: 900"),
    ...
  )
}


tSNEresults <- function(.data = NULL, .response = NULL, seed = NULL, ...){
  if (is.null(.data)){
    return(NULL)
  }
  
  if (!is.null(seed) && is.numeric(seed)){
    set.seed(seed)
  }
  
  # Remove duplicates.
  .data <- .data[!duplicated(.data), ]
  
  .response_values <- NULL
  if (!is.null(.response)){
    .response_values <- .data[[.response]]
    
    .data <- .data %>% 
      dplyr::select(-all_of(.response))
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
  
  return(
    list(
      results = tsneFit,
      response = .response_values
    )
  )
  
  return(tsneFit)
}

pcaResults <- function(.data = NULL, .response = NULL, ...){
  if (is.null(.data)){
    return(NULL)
  }
  
  .response_values <- NULL
  if (!is.null(.response)){
    .response_values <- .data[[.response]]
    
    .data <- .data %>% 
      dplyr::select(-all_of(.response))
  }
  
  pcaFit <- try({
    .data %>% 
      select(where(is.numeric)) %>% 
      prcomp(x = ., ...)
  })
  
  if (inherits(pcaFit, "try-error")){
    return(NULL)
  }
  
  return(
    list(
      results = pcaFit,
      response = .response_values
    )
  )
}