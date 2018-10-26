# flex_sim2_rscript.R
# function to plug into Rscript and run a single iteration of simulation 2
# simulation 2: trial-like conditions (n=200,p=30), 2 outcome variables

# input args:
# codedir - directory where code is stored
# libdir - directory where packages are stored
# sdatadir - directory where intermediate simulation results get stored
# scrdir - directory where log file should be sent
# antag - boolean, T=antagonistic setting/F=synergistic setting
# method - method used to estimate the ITR, "rlt" or "owl"
# d1 - true treatment effect for R1
# d2 - true treatment effect for R2
# i - the simulation index ranging from 1:N
args=commandArgs(trailingOnly=T)

# take command line input and rename
codedir = as.character(args[1])
libdir = as.character(args[2])
sdatadir = as.character(args[3])
scrdir = as.character(args[4])
antag = as.logical(args[5])
method = as.character(args[6])
d1 = as.numeric(args[7])
d2 = as.numeric(args[8])
i = as.numeric(args[9])

# start log file (written via bash)
system(sprintf("echo 'sim2, antag=%s, method=%s, d1=%s, d2=%s, i=%s' > %s/sim2_ant%s_%s_%s_%s_%s.Rout",antag,method,d1,d2,i,scrdir,antag,method,d1,d2,i))
system(sprintf("echo 'command line input received' >> %s/sim2_ant%s_%s_%s_%s_%s.Rout",scrdir,antag,method,d1,d2,i))

# initialize
# source internally needed code
source(sprintf("%s/flex_simulation_2.R",codedir))
system(sprintf("echo 'code sourced' >> %s/sim2_ant%s_%s_%s_%s_%s.Rout",scrdir,antag,method,d1,d2,i))
# library needed packages
for (pkg in c("RLT","DTRlearn")) {
  eval(parse(text=sprintf("library(%s,lib.loc='%s')",pkg,libdir)))
}
system(sprintf("echo 'packages libraried' >> %s/sim2_ant%s_%s_%s_%s_%s.Rout",scrdir,antag,method,d1,d2,i))

# set random number seed
seed=i*1000

# run simulation 2
rlt_ind <- (method=="rlt")
eval(parse(text=sprintf("sim2_out_ant%s_%s_%s_%s_%s=flex_simulation_2(codedir=codedir,n=200,p=30,d1=d1,d2=d2,k_mark=2,q=0.25,seed=seed,rlt=rlt_ind,antag=antag)",antag,method,d1,d2,i)))
system(sprintf("echo 'simulation 2 run' >> %s/sim2_ant%s_%s_%s_%s_%s.Rout",scrdir,antag,method,d1,d2,i))

# save results
eval(parse(text=sprintf("save(sim2_out_ant%s_%s_%s_%s_%s,file='%s/sim2_out_ant%s_%s_%s_%s_%s.rda')",antag,method,d1,d2,i,sdatadir,antag,method,d1,d2,i)))
system(sprintf("echo 'saving results... DONE' >> %s/sim2_ant%s_%s_%s_%s_%s.Rout",scrdir,antag,method,d1,d2,i))