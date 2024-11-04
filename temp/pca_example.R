# options:
#-hangi degiskenin c??kt?? oldugu
#- (gerekli mi bilmiyorum: verinin olceklendirilmesi, nmerkezilestirilmesi vs) center = TRUE/FALSE, scale. = TRUE/FALSE
# 


library(ggplot2)
library(datasets)

# Iris veri setini kullan
data(iris)
head(iris
     )
pca_model <- prcomp(iris[, 1:4], center = TRUE, scale. = TRUE)

pca_data <- data.frame(Species = iris$Species, 
                       pca_model$x[, 1:2])

ggplot(pca_data, aes(PC1, PC2, color = Species)) +
  geom_point(size = 2) +
  labs(title = "PCA - Iris Veri Seti", 
       x = "PC1", y = "PC2") +
  theme_minimal()
