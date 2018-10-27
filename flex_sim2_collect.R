# flex_sim2_collect.R
# cluster code to collect the results of FLEX sim 2

# set up locations
datadir <- "~/flex/data"
sdatadir <- "~/scr/simdata"
codedir <- "~/flex"
libdir <- "~/scr"
scrdir <- "~/submits"

# set up variables controlling names of files
method_list <- c("rlt","owl")
ant_list <- c(0,1)
d1_list <- c(1,3,10)
d2_list <- c(1,3,10)
N <- 100

# outfile for debugging
system(sprintf("echo 'starting loop' > %s/sim2_collect.Rout",scrdir))

for (ant in ant_list) {
  for (d1 in d1_list) {
    for (d2 in d2_list) {
      system(sprintf("echo 'ant=%s, d1=%s, d2=%s' >> %s/sim2_collect.Rout",ant,d1,d2,scrdir))
      # create R object to store sens/spec matrix and MSE for a given (ant,d1,d2)
      eval(parse(text=sprintf("sim2_ant%s_%s_%s=sapply(c('sens_spec','mse'),function(x) NULL)",ant,d1,d2)))
      eval(parse(text=sprintf("sim2_ant%s_%s_%s$sens_spec=matrix(0,nrow=4,ncol=3)",ant,d1,d2)))
      eval(parse(text=sprintf("colnames(sim2_ant%s_%s_%s$sens_spec)=c(-1,0,1)",ant,d1,d2)))
      eval(parse(text=sprintf("rownames(sim2_ant%s_%s_%s$sens_spec)=c('rlt_sens','rlt_spec','owl_sens','owl_spec')",ant,d1,d2)))
      eval(parse(text=sprintf("sim2_ant%s_%s_%s$mse=0",ant,d1,d2)))
      system(sprintf("echo 'objects created' >> %s/sim2_collect.Rout",scrdir))
      for (m in method_list) {
        system(sprintf("echo 'ant=%s, d1=%s, d2=%s, m=%s' >> %s/sim2_collect.Rout",ant,d1,d2,m,scrdir))
        # name the sens/spec matrix
        m_i=which(method_list==m)
        m_range=2*(m_i-1)+(1:2)
        system(sprintf("echo 'm_range=(%s,%s)' >> %s/sim2_collect.Rout",m_range[1],m_range[2],scrdir))
        # obtain list of simulations that actually ran and did not get eaten by ghosts
        system(sprintf("ls %s | grep sim2_out_ant%s_%s_%s_%s | grep rda > %s/file_list_temp.txt",sdatadir,ant,m,d1,d2,sdatadir))
        eval(parse(text=sprintf("temp_file_list=scan(file='%s/file_list_temp.txt',what='character')",sdatadir)))
        system(sprintf("echo 'file list created' >> %s/sim2_collect.Rout",scrdir))
        # s tallies number of simulations that actually ran for given (ant,d1,d2,m)
        s=0
        for (i in 1:N) {
          system(sprintf("echo 'ant=%s, d1=%s, d2=%s, m=%s, i=%s' >> %s/sim2_collect.Rout",ant,d1,d2,m,i,scrdir))
          # check if simulation actually ran or if ghosts in the cluster ate it
          if (sum(grepl(sprintf("sim2_out_ant%s_%s_%s_%s_%s.rda",ant,m,d1,d2,i),temp_file_list))>0) {
            system(sprintf("echo 'sim ran' >> %s/sim2_collect.Rout",scrdir))
            # if so, increment counter
            s=s+1
            # and load those sim results
            eval(parse(text=sprintf("load(file='%s/sim2_out_ant%s_%s_%s_%s_%s.rda')",sdatadir,ant,m,d1,d2,i)))
            # then add sens/spec matrix to appropriate rows
            if (m=="rlt") {
              eval(parse(text=sprintf("sim2_ant%s_%s_%s$sens_spec[1:2,]=sim2_ant%s_%s_%s$sens_spec[1:2,]+sim2_out_ant%s_%s_%s_%s_%s$sub_sens_spec",ant,d1,d2,ant,d1,d2,ant,m,d1,d2,i)))
              system(sprintf("echo 'added sens_spec' >> %s/sim2_collect.Rout",scrdir))
            }
            if (m=="owl") {
              eval(parse(text=sprintf("sim2_ant%s_%s_%s$sens_spec[3:4,]=sim2_ant%s_%s_%s$sens_spec[3:4,]+sim2_out_ant%s_%s_%s_%s_%s$sub_sens_spec",ant,d1,d2,ant,d1,d2,ant,m,d1,d2,i)))
              system(sprintf("echo 'added sens_spec' >> %s/sim2_collect.Rout",scrdir))
            }
            # and add MSE if method produced an MSE
            if (m=="rlt") {
              eval(parse(text=sprintf("sim2_ant%s_%s_%s$mse=sim2_ant%s_%s_%s$mse+sim2_out_ant%s_%s_%s_%s_%s$mse",ant,d1,d2,ant,d1,d2,ant,m,d1,d2,i)))
              system(sprintf("echo 'added mse' >> %s/sim2_collect.Rout",scrdir))
            }
          }
          # remove intermediate data object to free up memory
          eval(parse(text=sprintf("rm(sim2_out_ant%s_%s_%s_%s_%s)",ant,m,d1,d2,i)))
        }
        # now that we know the number of sims that actually ran...
        # divide sens/spec matrix subviews and MSE sums by number of sims so you have an average
        if (m=="rlt") {
          eval(parse(text=sprintf("sim2_ant%s_%s_%s$sens_spec[1:2,]=sim2_ant%s_%s_%s$sens_spec[1:2,]/%s",ant,d1,d2,ant,d1,d2,s)))
          eval(parse(text=sprintf("sim2_ant%s_%s_%s$mse=sim2_ant%s_%s_%s$mse/%s",ant,d1,d2,ant,d1,d2,s)))
          system(sprintf("echo 'divided by s' >> %s/sim2_collect.Rout",scrdir))
        }
        if (m=="owl") {
          eval(parse(text=sprintf("sim2_ant%s_%s_%s$sens_spec[3:4,]=sim2_ant%s_%s_%s$sens_spec[3:4,]/%s",ant,d1,d2,ant,d1,d2,s)))
          system(sprintf("echo 'divided by s' >> %s/sim2_collect.Rout",scrdir))
        }
      }
      # save the results to the 'real' data directory
      eval(parse(text=sprintf("save(sim2_ant%s_%s_%s,file='%s/sim2_ant%s_%s_%s.rda')",ant,d1,d2,datadir,ant,d1,d2)))
      system(sprintf("echo 'results saved' >> %s/sim2_collect.Rout",scrdir))
    }
  }
}

# create readable output tables
for (ant in ant_list) {
  for (d1 in d1_list) {
    for (d2 in d2_list) {
      eval(parse(text=sprintf("load(file='%s/sim2_ant%s_%s_%s.rda')",datadir,ant,d1,d2))) 
    }
  }
}

# subgroup sens and spec: synergistic
sim2_sens_spec_table <- matrix("",nrow=2+2*length(d1_list)*length(d2_list),ncol=9)
sim2_sens_spec_table[1,] <- c("delta_1","delta_2","Measure","Method=RLT","","","Method=OWL","","")
sim2_sens_spec_table[2,] <- c("","","","S=-1","S=0","S=1","S=-1","S=0","S=1")
for (i in 1:length(d1_list)) {
  sim2_sens_spec_table[(2+2*(length(d2_list)*(i-1))+1),1] <- d1_list[i]
  for (j in 1:length(d2_list)) {
    sim2_sens_spec_table[2+2*(length(d2_list)*(i-1))+2*(j-1)+1,2] <- d2_list[j]
    sim2_sens_spec_table[2+2*(length(d2_list)*(i-1))+2*(j-1)+(1:2),3] <- c("Sens","Spec")
    sim2_sens_spec_table[2+2*(length(d2_list)*(i-1))+2*(j-1)+(1:2),4:6] <- sprintf("%.3f",eval(parse(text=sprintf("sim2_ant0_%s_%s$sens_spec[1:2,]",d1_list[i],d2_list[j]))))
    sim2_sens_spec_table[2+2*(length(d2_list)*(i-1))+2*(j-1)+(1:2),7:9] <- sprintf("%.3f",eval(parse(text=sprintf("sim2_ant0_%s_%s$sens_spec[3:4,]",d1_list[i],d2_list[j]))))
  }
}
save(sim2_sens_spec_table,file=sprintf("%s/sim2_sens_spec_table.rda",datadir))

# subgroup sens and spec: antagonistic
sim2_sens_spec_table_a <- matrix("",nrow=2+2*length(d1_list)*length(d2_list),ncol=9)
sim2_sens_spec_table_a[1,] <- c("delta_1","delta_2","Measure","Method=RLT","","","Method=OWL","","")
sim2_sens_spec_table_a[2,] <- c("","","","S=-1","S=0","S=1","S=-1","S=0","S=1")
for (i in 1:length(d1_list)) {
  sim2_sens_spec_table_a[(2+2*(length(d2_list)*(i-1))+1),1] <- d1_list[i]
  for (j in 1:length(d2_list)) {
    sim2_sens_spec_table_a[2+2*(length(d2_list)*(i-1))+2*(j-1)+1,2] <- d2_list[j]
    sim2_sens_spec_table_a[2+2*(length(d2_list)*(i-1))+2*(j-1)+(1:2),3] <- c("Sens","Spec")
    sim2_sens_spec_table_a[2+2*(length(d2_list)*(i-1))+2*(j-1)+(1:2),4:6] <- sprintf("%.3f",eval(parse(text=sprintf("sim2_ant1_%s_%s$sens_spec[1:2,]",d1_list[i],d2_list[j]))))
    sim2_sens_spec_table_a[2+2*(length(d2_list)*(i-1))+2*(j-1)+(1:2),7:9] <- sprintf("%.3f",eval(parse(text=sprintf("sim2_ant1_%s_%s$sens_spec[3:4,]",d1_list[i],d2_list[j]))))
  }
}
save(sim2_sens_spec_table_a,file=sprintf("%s/sim2_sens_spec_table_a.rda",datadir))

# treatment effect MSE: synergistic
sim2_mse_table <- matrix("",nrow=1+length(d1_list),ncol=1+length(d2_list))
sim2_mse_table[1,] <- c("","delta_2=1","delta_2=3","delta_2=10")
sim2_mse_table[,1] <- c("","delta_1=1","delta_1=3","delta_1=10")
for (d1 in d1_list) {
  i=which(d1_list==d1)+1
  for (d2 in d2_list) {
    j=which(d2_list==d2)+1
    eval(parse(text=sprintf("mse_temp=sim2_ant0_%s_%s$mse",d1,d2)))
    sim2_mse_table[i,j]=sprintf("%.3f",mse_temp)
  }
}
save(sim2_mse_table,file=sprintf("%s/sim2_mse_table.rda",datadir))

# treatment effect MSE: antagonistic
sim2_mse_table_a <- matrix("",nrow=1+length(d1_list),ncol=1+length(d2_list))
sim2_mse_table_a[1,] <- c("","delta_2=1","delta_2=3","delta_2=10")
sim2_mse_table_a[,1] <- c("","delta_1=1","delta_1=3","delta_1=10")
for (d1 in d1_list) {
  i=which(d1_list==d1)+1
  for (d2 in d2_list) {
    j=which(d2_list==d2)+1
    eval(parse(text=sprintf("mse_temp=sim2_ant1_%s_%s$mse",d1,d2)))
    sim2_mse_table_a[i,j]=sprintf("%.3f",mse_temp)
  }
}
save(sim2_mse_table_a,file=sprintf("%s/sim2_mse_table_a.rda",datadir))
