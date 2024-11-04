# method comparison 
# iki verinin ayn?? seyi olcup olcmedigini gosterir
setwd("D:/research/COBRE/2ndstudy/second_firstAugment/data")
rm(list=ls())
library(readr)
library(readxl)
library(dplyr)
library(DESeq2)

dataRV<-read.csv("final_not_augm_data_2class.csv")
data2 <- read.csv("D:/research/COBRE/2ndstudy/second_firstAugment/data/3combined_data_all_last4.csv")
dataRV<-data2
dataRV<- arrange(dataRV, class)

data<-dataRV 
# Load data from a CSV file



dataGene<-colnames(data)
data_class<- data$class
table(data$class)
data$class<-NULL
count<- t(data)
count<-round(count, 0)
colnames(count)<- paste0(c("C", "CO")[data_class+1], rep(1:483, 2))
#colnames(count)<- paste0(c("C", "CO")[data_class+1], rep(1:23, 2))


# View the first few rows of the dataset

coldata<-data.frame(status = data_class)
rownames(coldata)<-colnames(count)
 
#coldata <- read_excel("D:/research/COBRE/2ndstudy/second_firstAugment/data/coldata2.xlsx")

coldata <- coldata %>% 
  mutate( status = factor(status, labels = c("Control","Compensated"), 
                          levels =c(0,1)) 
  )


str(coldata)

dds <- DESeqDataSetFromMatrix(countData = count,
                              colData = coldata,
                              design = ~  status  
)


res<-DESeq(dds)


#resFC<-results(res)
resFC2<-results(res)
resFC2
all(rownames(resFC2 ) %in% rownames(resFC))


FC1<-resFC$log2FoldChange
FC2<-resFC2[rownames(resFC),"log2FoldChange"]
getwd()


save(FC1, file = "FC1.rda")
save(FC2, file = "FC2.rda")

plot(FC1, FC2)

lm(FC2~FC1)
summary( lm(FC2~FC1))

################################################################################ method comparison reg: deming regression
library(mcr)
library(dplyr)
library(ggplot2)

load("FC1.rda")
load("FC2.rda")

model1<- mcreg(x = FC1, y = FC2, error.ratio = 1, method.reg = "Deming", method.ci = "analytical",
               mref.name = "Raw Data", mtest.name = "Augmented Data", na.rm = TRUE)

printSummary(model1)
plot(model1)



