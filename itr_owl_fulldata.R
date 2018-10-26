# itr_owl_fulldata function
# find ITR by fitting OWL to full data
# X - covariate matrix (all numeric)
# A - treatment coded {-1,1}
# R - reward (do not need to shift above 0--RWL handles this)

itr_owl_fulldata <- function(X,A,R,nfolds=10,seed=NA,gauss=FALSE) {
  if (!is.na(seed)) set.seed(seed)
  # for complete cases, just do things normally
  if (class(X)=="matrix") {
    # fit OWL
    if (!gauss) owl_fit <- Olearning_Single(H=X,A=A,R2=R,m=nfolds)
    if (gauss) owl_fit <- Olearning_Single(H=X,A=A,R2=R,m=nfolds,kernel="rbf")
    # find estimated ITR from OWL
    itr_owl <- predict(owl_fit,X)
    
    # return
    ret <- sapply(c("owl_fit","itr_owl"),function(x) NULL)
    ret$owl_fit <- owl_fit
    ret$itr_owl <- itr_owl
  }
  # for imputed data, fit OWL to each imputed dataset, then take majority vote
  if (class(X)=="list") {
    # set up matrix to store votes and list to store OWL fits
    vote_mat <- matrix(NA,nrow=nrow(X[[1]]),ncol=length(X))
    owl_fits <- vector('list',length(X))
    # fit OWL and get ITR within each fold, store votes and fits
    for (i in 1:length(X)) {
      # fit OWL
      if (!gauss) owl_fits[[i]] <- Olearning_Single(H=X[[i]],A=A,R2=R,m=nfolds)
      if (gauss) owl_fits[[i]] <- Olearning_Single(H=X[[i]],A=A,R2=R,m=nfolds,kernel="rbf")
      # find estimated ITR from OWL
      vote_mat[,i] <- predict(owl_fits[[i]],X[[i]])
    }
    # take majority vote
    itr_owl <- apply(vote_mat,1,function(x) sum(x==1)>sum(x==-1))*2-1
    # return
    ret <- sapply(c("owl_fit","itr_owl"),function(x) NULL)
    ret$owl_fit <- owl_fits
    ret$itr_owl <- itr_owl
    ret$vote_mat <- vote_mat
  }
  
  return(ret)
}