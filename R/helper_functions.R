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


augmentationResults <- function(.data, .response, ...){
  x <- .data %>% 
    select(-all_of(.response)) %>% 
    as.data.frame(.)
  
  y <- .data[[.response]]
  
  if (length(unique(y)) != 2){
    res <- list(status = "error", 
                message = paste("Response variable must have exactly two non-empty categories.", 
                                "Please check your response variable is binary and there is no empty category."),
                result = NULL)
    
    return(res)
  }
  
  categories <- NULL
  if (is.factor(y)){
    y <- forcats::fct_drop(y)
    categories <- levels(y)
    y <- as.numeric(y)
  } else if (is.numeric(y)){
    categories <- sort(unique(y))
    y[y == categories[1]] <- 1
    y[y != categories[1]] <- 2
  } else if (is.character(y)){
    categories <- sort(unique(y))
    y <- forcats::fct(y, levels = categories)
    y <- as.numeric(y)
  } else {
    res <- list(status = "error", 
                message = paste("Unknown variable type for response. Please check that response variable is one of",
                                "'numeric' or 'categorical' variable."),
                result = NULL)
    
    return(res)
  }
  
  # tmp <- MixUp(x, y, alpha = .5, m = 2, method = "minority", y_threshold = .5)
  tmp <- MixUp(x, y, ...)
  tmp$y <- as.factor(categories[tmp$y])
  
  res <- list(status = "success", 
              message = NULL,
              result = tmp)
  
  return(res)
}

