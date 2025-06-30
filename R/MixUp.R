# Function to run MixUp calculations.
mixup_init <- function(.x, .y, alpha = .5, m = 2) {
  if (m < 2){
    stop("'m' should be greater or equal 2.")
  }
  
  if (alpha <= 0){
    stop("Shape parameter of Beta distribution, i.e., 'alpha', must be a positive numeric value.")
  }
  
  # Number of rows and cols for data, excluding the response column.
  num_rows <- nrow(.x)
  num_cols <- ncol(.x)
  
  # Response column.
  if (is.vector(.y)) {
    .y <- matrix(.y, ncol = 1)
  }
  
  # Complete data.
  data <- cbind(.x, .y)
  
  # Stack data m times.
  data_stacked <- data[rep(1:num_rows, m), ]
  
  # Select random sample (with replacement) from stacked data set.
  idx <- sample(1:nrow(data_stacked), nrow(data_stacked))
  
  # For each row, generate lambda values from Beta distribution with shape parameter(s) "alpha"
  lambda <- rbeta(nrow(data_stacked), alpha, alpha)
  
  # Generate MixUp'd data set.
  data_MixUp <- lambda * data_stacked + (1 - lambda) * data_stacked[idx, ]
  # y_new <- as.numeric(data_MixUp[, ncol(data_MixUp)] >= 0.5)
  y_new <- data_MixUp[, ncol(data_MixUp)]
  
  return(list(
    x = data_MixUp[, 1:num_cols], 
    y = y_new
    # y = data_MixUp[, (num_cols + 1):ncol(data_MixUp)]
  ))
}

# Note: y stands for the response variable.
#
# Args:
#   x, y: a matrix or data.frame including the complete data. Response variable should be given with 'y'.
#   alpha: a positive numeric. It is the shape parameters (shape1 and shape2) of Beta distribution.
#   m: a positive integer. Should be equal or greater than 2. It is used to define the amount of replication
#      of data matrix. If equals 2, for example, the number of samples in the new data set will be 2 times 
#      of the original one.
#   method: augmentation method. Default is "unbiased". Other choices are:
#           unbiased: generates random samples without considering group sizes.
#           minority: generates samples from minority class. Generated data is multiple of original data by m.
#           inner: generates data from both groups multiplied by m.
#   y_threshold: a numeric value. MixUp'd y values is assigned one of classes based on y_threshold value. If above or equal y_threshold, 
#                new observation is assigned to class 1, and 0 otherwise.
#
# Example:
# set.seed(42)
# x_tr <- matrix(rpois(1000, lambda = 50), ncol = 10)
# y_tr <- ifelse(rpois(100, lambda = 1) > 0, 1, 0)
# 
# res <- MixUp(x_tr, y_tr, method = "unb", m = 2, y_threshold = .5)
# tbl1 <- table(y_tr)
# tbl1
# prop.table(tbl1)
# 
# tbl2 <- table(res$y)
# tbl2
# prop.table(tbl2)
MixUp <- function(x, y, alpha = .5, m = 2, method = c("unbiased", "minority", "inner"), y_threshold = 0.5, ...){
  
  method <- match.arg(method)
  res <- NULL
  
  if (method == "minority"){
    ySize <- table(y)
    minorityClass <- names(ySize[which.min(ySize)])
    
    if (ySize[1] == ySize[2]){
      minorityClass <- names(ySize)[sample(1:2, 1)]
    }
    
    idxMinority <- which(y == minorityClass)
    args <- list(
      .x = x[idxMinority, ], 
      .y = as.numeric(rep(minorityClass, length(idxMinority))), 
      alpha = alpha, 
      m = m
    )
    
    tmp <- do.call("mixup_init", args)

    res <- list(
      x = rbind(tmp$x, x[-idxMinority, ]),
      y = c(tmp$y, y[-idxMinority])
    )
  } else if (method == "unbiased"){
    res <- mixup_init(x, y, alpha, m)
    if (!is.null(y_threshold)){
      res$y <- as.numeric(res$y >= y_threshold) + 1
    }
  } else {
    tmp <- lapply(unique(y), function(u){
      idx <- which(y == u)
      mixup_init(x[idx, ], y[idx], alpha, m)
    })
    
    x_new <- y_new <- NULL
    for (i in 1:length(tmp)){
      x_new <- rbind(x_new, tmp[[i]]$x)
      y_new <- c(y_new, tmp[[i]]$y)
    }
  
    res <- list(x = x_new, y = y_new)
  }
  
  return(res)
}

