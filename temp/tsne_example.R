
# options:
#-hangi degiskenin c??kt?? oldugu
#- max_iter
# 


 
library(Rtsne)
library(ggplot2)

# ??rnek olarak iris veri setini kullan??yoruz
data(iris)
data_numeric <- iris[, 1:4]

# Tekrarlayan g??zlemleri kald??r??n
data_numeric_unique <- unique(data_numeric)

# t-SNE algoritmas??n?? ??al????t??r??n
set.seed(42)
tsne_model <- Rtsne(data_numeric_unique, dims = 2, initial_dims = 50, perplexity = 30, verbose = TRUE, max_iter = 500)

# t-SNE sonu??lar??n?? data frame'e d??n????t??r??n
tsne_data <- data.frame(tsne_model$Y)
colnames(tsne_data) <- c("Dim1", "Dim2")
tsne_data$Species <- iris$Species[!duplicated(data_numeric)]  # Tekrarlanmayan g??zlemlerle t??rleri e??le??tirin

# Sonu??lar?? g??rselle??tirme
ggplot(tsne_data, aes(x = Dim1, y = Dim2, color = Species)) +
  geom_point(size = 3) +
  theme_minimal() +
  labs(title = "t-SNE Visualization of Iris Dataset")

