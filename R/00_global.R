options(shiny.maxRequestSize = 30 * (1024^2))  # Max upload size is 30 MB. 

library(shiny)
library(dplyr)
library(DT)
library(ggplot2)
library(Rtsne)


# Defaults ----
## Analysis Options Modal ----
analysisOptionsModalDefaults <- list(
  PCA_tSNE_plots = list(
    PCA = list(
      center = TRUE,
      scale = TRUE 
    ),
    tSNE = list(
      initDimsPCA = 50,
      perplexity = 30,
      nIter = 500
    )
  ),
  Augmentation = list(
    MixUp = list(
      method = "unbiased",
      alpha = 0.5,
      m = 2,
      threshold = 0.5
    )
  ),
  FeatureSelection = list(
    DESeq = list(
      minCount = 3
    ),
    PCA = list(
      nFeatures = NA
    )
  )
)


orig <- list(x = 5, y = TRUE)
