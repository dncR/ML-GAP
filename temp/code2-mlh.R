library(MASS)
# unbiased: T??m veri seti ??zerinde mixup uygular.
# minority: Yaln??zca az??nl??k s??n??f?? ??zerinde mixup uygular.
# inner   : Hem ??o??unluk (majority) hem de az??nl??k s??n??flar??nda ayr?? ayr?? mixup uygular ve sonu??lar?? birle??tirir.
# MixUp s??n??f??n?? R'de bir fonksiyon olarak tan??mlayal??m
MixUp <- function(train_x, train_y, minor_x, minor_y, major_x, major_y, alpha, m) {
  
  # MixUp i??lemini uygulayan alt fonksiyon
  mixup <- function(data_x, data_y) {
    num_data <- nrow(data_x)
    indata_dim <- ncol(data_x)
    
    if (is.null(dim(data_y))) {
      data_y <- matrix(data_y, ncol = 1)
    }
    
    data <- cbind(data_x, data_y)
    new_data <- data[rep(1:nrow(data), each = m), ]
    
    # Rastgele kar??????m indeksi olu??tur
    idx <- sample(1:nrow(new_data))
    
    # Beta da????l??m??ndan lambda de??erleri al ve boyutlar?? uygun hale getirmek i??in geni??let
    lmbda <- matrix(rbeta(nrow(new_data), alpha, alpha), nrow = nrow(new_data), ncol = ncol(new_data))
    
    # MixUp i??lemi: Yay??lma (broadcasting) benzeri bir uygulama
    mixed_data <- lmbda * new_data + (1 - lmbda) * new_data[idx, ]
    
    list(new_x = mixed_data[, 1:indata_dim], new_y = mixed_data[, (indata_dim + 1):ncol(mixed_data)])
  }
  
  # mixup_by fonksiyonu
  mixup_by <- function(option) {
    stopifnot(m >= 2)
    
    if (option == "unbiased") {
      mixup(train_x, train_y)
    } else if (option == "minority") {
      mixup(minor_x, minor_y)
    } else if (option == "inner") {
      new_major <- mixup(major_x, major_y)
      new_minor <- mixup(minor_x, minor_y)
      list(new_x = rbind(new_major$new_x, new_minor$new_x), new_y = rbind(new_major$new_y, new_minor$new_y))
    } else {
      stop(paste(option, "not implemented"))
    }
  }
  
  # Kar??????m fonksiyonunu d??nd??r
  list(mixup_by = mixup_by)
}

# ??rnek bir kullan??m
# ??rnek verileri olu??turma
set.seed(42) # Sonu??lar??n tekrarlanabilir olmas?? i??in rastgelelik sabitleniyor
#x_train <- matrix(rnorm(1000), ncol = 10)
#y_train <- sample(0:1, 100, replace = TRUE)


# Mixup nesnesi olu??tur
mixup <- MixUp(train_x = x_train, train_y = y_train,
               minor_x = x_minority, minor_y = y_minority,
               major_x = x_majority, major_y = y_majority,
               alpha = 0.5, m = 5)

# Az??nl??k verileri ??zerinde MixUp i??lemi yapal??m
result <- mixup$mixup_by("unbiased")
new_x <-round(result$new_x)
new_y <- round(result$new_y)


