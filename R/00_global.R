options(shiny.maxRequestSize = 30 * (1024^2))  # Max upload size is 30 MB. 

library(shiny)
library(dplyr)
library(DT)
library(ggplot2)
library(Rtsne)
library(DESeq2)

# Defaults ----
## Analysis Options Modal ----
analysisOptionsModalDefaults <- list(
  PCA_tSNE_plots = list(
    PCA = list(
      center = TRUE,
      scale = TRUE 
    ),
    tSNE = list(
      initialDimsPCA_tSNE = 50,
      perplexity_tSNE = 10,
      maxIter_tSNE = 500
    )
  ),
  Augmentation = list(
    MixUp = list(
      method_MixUp = "unbiased",
      alpha_MixUp = 0.5,
      m_MixUp = 2,
      y_threshold_MixUp = 0.5
    )
  ),
  FeatureSelection = list(
    DESeq = list(
      minCount = 3,
      testType_DESeq = "wald",
      fitType_DESeq = "parametric",
      sfType_DESeq = "ratio",
      pAdjust_DESeq = "BH"
    ),
    PCA = list(
      nFeat_PCA = 100
    )
  )
)
