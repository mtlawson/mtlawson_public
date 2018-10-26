# sim1s_true_diffs.R
# find true treatment differences for composite outcome given univariate treatment effects
# R - composite outcome
# R1/R2 - univariate outcome 1/2
# A - observed treatment, coded {-1,1}
# S - true subgroup, coded {-1,1}
# d1/d2 - magnitude of true treatment effect for R1/R2
# q - quantile to cut R1 when constructing composite outcome
# antag - boolean, synergistic vs. antagonistic simulation setting (controls direction of true trt effects)

# counterfactual logic in the bulk of this code is based on
# synergistic:  S==1 means A==1 increases R1 by d1 and R2 by d2
#               S==-1 means A==-1 decreases R1 by d1 and R2 by d2
# antagonistic: S==1 means A==1 increases R1 by d1 and decreases R2 by d2
#               S==-1 means A==-1 decreases R1 by d1 and increases R2 by d2

sim1s_true_diffs <- function(R,R1,R2,A,S,d1,d2,q,antag=F) {
  n <- length(R)
  R_trt <- rep(NA,n)
  R_ctrl <- rep(NA,n)
  R_trt[S==0] <- R[S==0]
  R_ctrl[S==0] <- R[S==0]
  if (!antag) {
    # true diffs for intervention group
    tg <- S==1
    tg_i <- which(tg)
    for (i in 1:sum(tg)) {
      if (A[tg_i[i]]==1) {
        R_trt[tg_i[i]]=R[tg_i[i]]
        R_1p=R1
        R_2p=R2
        R_1p[tg_i[i]]=R_1p[tg_i[i]]-d1
        R_2p[tg_i[i]]=R_2p[tg_i[i]]-d2
        Rp <- bivariate_to_composite(R_1p,R_2p,q)
        R_ctrl[tg_i[i]]=Rp[tg_i[i]]
      } else if (A[tg_i[i]]==-1) {
        R_ctrl[tg_i[i]]=R[tg_i[i]]
        R_1p=R1
        R_2p=R2
        R_1p[tg_i[i]]=R_1p[tg_i[i]]+d1
        R_2p[tg_i[i]]=R_2p[tg_i[i]]+d2
        Rp <- bivariate_to_composite(R_1p,R_2p,q)
        R_trt[tg_i[i]]=Rp[tg_i[i]]
      }
    }
    # true diffs for control group
    cg <- S==-1
    cg_i <- which(cg)
    for (i in 1:sum(cg)) {
      if (A[cg_i[i]]==1) {
        R_trt[cg_i[i]]=R[cg_i[i]]
        R_1p=R1
        R_2p=R2
        R_1p[cg_i[i]]=R_1p[cg_i[i]]+d1
        R_2p[cg_i[i]]=R_2p[cg_i[i]]+d2
        Rp <- bivariate_to_composite(R_1p,R_2p,q)
        R_ctrl[cg_i[i]]=Rp[cg_i[i]]
      } else if (A[cg_i[i]]==-1) {
        R_ctrl[cg_i[i]]=R[cg_i[i]]
        R_1p=R1
        R_2p=R2
        R_1p[cg_i[i]]=R_1p[cg_i[i]]-d1
        R_2p[cg_i[i]]=R_2p[cg_i[i]]-d2
        Rp <- bivariate_to_composite(R_1p,R_2p,q)
        R_trt[cg_i[i]]=Rp[cg_i[i]]
      }
    }
  }
  if (antag) {
    # true diffs for intervention group
    tg <- S==1
    tg_i <- which(tg)
    for (i in 1:sum(tg)) {
      if (A[tg_i[i]]==1) {
        R_trt[tg_i[i]]=R[tg_i[i]]
        R_1p=R1
        R_2p=R2
        R_1p[tg_i[i]]=R_1p[tg_i[i]]-d1
        R_2p[tg_i[i]]=R_2p[tg_i[i]]+d2
        Rp <- bivariate_to_composite(R_1p,R_2p,q)
        R_ctrl[tg_i[i]]=Rp[tg_i[i]]
      } else if (A[tg_i[i]]==-1) {
        R_ctrl[tg_i[i]]=R[tg_i[i]]
        R_1p=R1
        R_2p=R2
        R_1p[tg_i[i]]=R_1p[tg_i[i]]+d1
        R_2p[tg_i[i]]=R_2p[tg_i[i]]-d2
        Rp <- bivariate_to_composite(R_1p,R_2p,q)
        R_trt[tg_i[i]]=Rp[tg_i[i]]
      }
    }
    # true diffs for control group
    cg <- S==-1
    cg_i <- which(cg)
    for (i in 1:sum(cg)) {
      if (A[cg_i[i]]==1) {
        R_trt[cg_i[i]]=R[cg_i[i]]
        R_1p=R1
        R_2p=R2
        R_1p[cg_i[i]]=R_1p[cg_i[i]]+d1
        R_2p[cg_i[i]]=R_2p[cg_i[i]]-d2
        Rp <- bivariate_to_composite(R_1p,R_2p,q)
        R_ctrl[cg_i[i]]=Rp[cg_i[i]]
      } else if (A[cg_i[i]]==-1) {
        R_ctrl[cg_i[i]]=R[cg_i[i]]
        R_1p=R1
        R_2p=R2
        R_1p[cg_i[i]]=R_1p[cg_i[i]]-d1
        R_2p[cg_i[i]]=R_2p[cg_i[i]]+d2
        Rp <- bivariate_to_composite(R_1p,R_2p,q)
        R_trt[cg_i[i]]=Rp[cg_i[i]]
      }
    }
  }
  # find true difference vector
  R_diff = R_trt-R_ctrl
  return(R_diff)
}