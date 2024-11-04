rm(list=ls())
library(readr)
library(readxl)
library(dplyr)
library(DESeq2)


dataRV<-read.csv("final_not_augm_data_2class.csv")
# Load data from a CSV file
data2 <- read.csv("3combined_data_all_last4.csv")

data<-data2

dataGene<-colnames(data)
data_class <- data$class
table(data$class)
data$class<-NULL
count<- t(data)

colnames(count)<- paste0(c("C", "CO")[data_class+1], rep(1:483, 2))

coldata <-data.frame(status=data_class)
coldata
# View the first few rows of the dataset
#coldata <- read_excel("coldata2.xlsx")

coldata <- coldata %>% 
  mutate( status = factor(status, labels = c("Control","Compensated"), levels = c(0, 1)) 
  )

data = count
data = round(data, 0)
dds <- DESeqDataSetFromMatrix(countData = data,
                              colData = coldata,
                              design = ~  status  
)


smallestGroupSize <- 3
keep <- rowSums(counts(dds) >= 10) >= smallestGroupSize
dds <- dds[keep,]

# Differential expression analysis ----
dds <- DESeq(dds)
res <- results(dds,)
summary(res)
res

res <- res[order(abs(res$stat), decreasing = TRUE), ]
res

# selectedFeatures <- rownames(res)[1:200]

# Data transformation ----
# Variance Stabilizing Transformation (VST)
vst     <- varianceStabilizingTransformation(dds)
vstData <- assay(vst)
head(vstData)

# vstData <- vstData[selectedFeatures, ]
rownames(vstData)
colnames(vstData)
class(vstData)
dim(vstData)


# Select 2000 features via PCA
PCA_Res <- prcomp(t(vstData), scale. = TRUE)
# PCA yC<klerini (loadings) al
PCA_loadings <- PCA_Res$rotation

# D0lk ana bileEen iC'in yC<klerin mutlak deDerlerini al ve sD1rala
PC1_loadings <- abs(PCA_loadings[,1])
PC1_loadings_ordered <- sort(PC1_loadings, decreasing = TRUE)

# D0lk 2000 genin isimlerini al
pcaFeatures <- names(PC1_loadings_ordered)[1:2000]
dim(vstData)
# SevstData# Select PCA Features.
vstData <- vstData[match(pcaFeatures, rownames(vstData)), ]

res <- res[match(rownames(vstData), rownames(res)), ]
res <- res[order(abs(res$stat), decreasing = TRUE), ]
selectedFeatures <- rownames(res)[1:200]
res

ratDF <- tibble(class = coldata$status) %>% 
  bind_cols(., as.data.frame(t(vstData[match(selectedFeatures, rownames(vstData)), ])))

dim( ratDF) 

which( colnames(data2) %in% "ENSRNOG00060020123"== "TRUE")
which( colnames(ratDF) %in% "ENSRNOG00060020123"== "TRUE")


write.csv(ratDF, "ratDF2.csv", row.names = FALSE )

data<-read.csv("ratDF2.csv")
colnames(data)
