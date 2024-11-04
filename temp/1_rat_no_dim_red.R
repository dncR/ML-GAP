rm(list=ls())
# Number of features: 20531 (whole exom sequencing)

library(DESeq2)
library(edgeR)
library(dplyr)
library(readxl)

# Read data ----
batch1_1 <- read_excel("D:/COBRE/2ndstudy/data/raw/GSE240923_processed-data-mct.xlsx", 
                       sheet = "count matrix-batch-1" )

batch1_2 <- read_excel("D:/COBRE/2ndstudy/data/raw/GSE240923_processed-data-mct.xlsx", 
                       sheet = "count matrix batch-2" )

batch2 <- read_excel("D:/COBRE/2ndstudy/data/raw/GSE242014_processed-data-pab.xlsx", 
                     sheet = "raw count table" )

coldata <- read_excel("D:/COBRE/2ndstudy/data/raw/coldata.xlsx")
coldata <- as.data.frame(coldata)

rv_part1 <- inner_join(batch1_1, batch1_2)
rv_data  <- inner_join(rv_part1, batch2)
rv_data1 <- as.data.frame(rv_data)

counts <- rv_data1
rownames(counts) <- counts$id
counts <- counts[,-1]

# Transpose the data
xx <- t(counts)

# Convert the transposed matrix back to a data frame
xx <- as.data.frame(xx)

# Extracting sample names (row names)
sample_names <- rownames(xx)

# Creating the Target column based on the given row names
xx$Target <- ifelse(grepl("CTRL", sample_names, ignore.case = TRUE), 0,
                    ifelse(grepl("DECOMP", sample_names, ignore.case = TRUE), 2,
                           ifelse(grepl("COMP", sample_names, ignore.case = TRUE), 1, NA)))

# Display the transposed and adjusted data frame
head(xx)
dim(xx)
xx[c(1:3, 17:20, 67),16584:16586 ]

library(dplyr)
xx$class<-xx$Target
# Filtering the data where Target is 0 or 1
main_data <- xx %>%
  filter(Target == 0 | Target == 1)
dim(main_data)
# Display the first few rows of the main_data
head(main_data)

rownames(xx)

write.csv(xx, "D:/COBRE/2ndstudy/data/raw/final_not_augm_data_3class.csv", row.names = FALSE, quote = FALSE)
write.csv(xx, "D:/COBRE/2ndstudy/data/raw/final_not_augm_data_2class.csv", row.names = FALSE, quote = FALSE)
