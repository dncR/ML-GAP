library(MASS)
# unbiased: T??m veri seti ??zerinde mixup uygular.
# minority: Yaln??zca az??nl??k s??n??f?? ??zerinde mixup uygular.
# inner   : Hem ??o??unluk (majority) hem de az??nl??k s??n??flar??nda ayr?? ayr?? mixup uygular ve sonu??lar?? birle??tirir.

MixUp <- function(train_x, train_y, minor_x, minor_y, major_x, major_y, alpha, m) {
  if(m < 2) stop("m should be greater than or equal to 2")
  
  # ???? mixup fonksiyonu
  mixup <- function(data_x, data_y, alpha, m) {
    num_data <- nrow(data_x)
    indata_dim <- ncol(data_x)
    
    if (is.vector(data_y)) {
      data_y <- matrix(data_y, ncol = 1)
    }
    
    data <- cbind(data_x, data_y)
    new_data <- data[rep(1:num_data, m), ]
    
    # Rastgele kar??????m indeksi olu??tur
    idx <- sample(1:nrow(new_data), nrow(new_data))
    
    # Beta da????l??m??ndan lambda de??erleri al
    lmbda <- rbeta(nrow(new_data), alpha, alpha)
    
    # MixUp i??lemi: sat??r baz??nda ??arpma yap??lacak
    mixed_data <- lmbda * new_data + (1 - lmbda) * new_data[idx, ]
    
    list(x = mixed_data[, 1:indata_dim], y = mixed_data[, (indata_dim + 1):ncol(mixed_data)])
  }
  
  # mixup_by fonksiyonu
  mixup_by <- function(option) {
    if (option == "unbiased") {
      return(mixup(train_x, train_y, alpha, m))
    } else if (option == "minority") {
      return(mixup(minor_x, minor_y, alpha, m))
    } else if (option == "inner") {
      new_major <- mixup(major_x, major_y, alpha, m)
      new_minor <- mixup(minor_x, minor_y, alpha, m)
      new_x <- rbind(new_major$x, new_minor$x)
      new_y <- rbind(new_major$y, new_minor$y)
      return(list(x = new_x, y = new_y))
    } else {
      stop(paste(option, "not implemented"))
    }
  }
  
  # Fonksiyonlar?? d??nd??r
  list(
    mixup_by = mixup_by
  )
}

# ??rnek kullan??m
set.seed(42) # Sonu??lar??n tekrar elde edilebilir olmas?? i??in sabit bir tohum belirliyoruz

# Poisson da????l??m??ndan x_train verisi ??retelim
# 100 sat??r ve 10 s??tun olacak ??ekilde, lambda = 3
x_train <- matrix(rpois(1000, lambda = 50), ncol = 10)

# Poisson da????l??m??ndan y_train verisi ??retelim, binary olacak ??ekilde lambda = 1
y_train <- ifelse(rpois(100, lambda = 1) > 0, 1, 0)

# x_train'i az??nl??k ve ??o??unluk verisi olarak b??l??mlendirelim
x_minority <- x_train[1:10, ]
y_minority <- y_train[1:10]
x_majority <- x_train[11:100, ]
y_majority <- y_train[11:100]



# x_train ve y_train verilerini yazma
write.csv(x_train, file = "x_train.csv", row.names = FALSE)
write.csv(y_train, file = "y_train.csv", row.names = FALSE)

# x_minority ve y_minority verilerini yazma
write.csv(x_minority, file = "x_minority.csv", row.names = FALSE)
write.csv(y_minority, file = "y_minority.csv", row.names = FALSE)

# x_majority ve y_majority verilerini yazma
write.csv(x_majority, file = "x_majority.csv", row.names = FALSE)
write.csv(y_majority, file = "y_majority.csv", row.names = FALSE)

# MixUp fonksiyonunu kullanarak veri art??r??m?? yapal??m
mixup <- MixUp(train_x = x_train, train_y = y_train,
               minor_x = x_minority, minor_y = y_minority,
               major_x = x_majority, major_y = y_majority,
               alpha = 0.5, m = 5)

# Az??nl??k verileri ??zerinde MixUp i??lemi yapal??m
new_data <- mixup$mixup_by("unbiased")
new_x1 <- round(new_data$x)
new_y1 <- round(new_data$y)


