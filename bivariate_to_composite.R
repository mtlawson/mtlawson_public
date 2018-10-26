# bivariate_to_composite.R
# function to generate composite outcome from two univariate outcomes
# cut R1 at cutpt; those below cut are in cat1 and have lower R, those above are in cat2 and have higher R

bivariate_to_composite <- function(R1,R2,cutpt) {
  n <- length(R1)
  R <- rep(NA,n)
  cat1 <- R1<cutpt
  R[cat1] <- (R1[cat1]-min(R1[cat1]))/(max(R1[cat1])-min(R1[cat1]))
  R[!cat1] <- 1+(R2[!cat1]-min(R2[!cat1]))/(max(R2[!cat1])-min(R2[!cat1]))
  return(R)
}