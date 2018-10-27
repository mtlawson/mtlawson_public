# flex_sim1_app.R
# shiny app to generate simulation 1 data given slider inputs
# graphically illustrate how univariate and composite outcomes correspond

library(shiny)
library(plotly)

# requisite data generation functions -- included here so app.R is self-sufficient when shared
# function to convert two univariate outcomes to one composite outcome
bivariate_to_composite <- function(R1,R2,cutpt) {
  n <- length(R1)
  R <- rep(NA,n)
  cat1 <- R1<cutpt
  R[cat1] <- (R1[cat1]-min(R1[cat1]))/(max(R1[cat1])-min(R1[cat1]))
  R[!cat1] <- 1+(R2[!cat1]-min(R2[!cat1]))/(max(R2[!cat1])-min(R2[!cat1]))
  return(R)
}
# function to generate data for FLEX simulation 1
generate_sim_data_1s <- function(codedir,n,p,epsilon=1,d1,d2,quant_cut=0.25,seed=23,antag=F) {
  if (!is.null(seed)) {
    set.seed(seed)
  }
  X <- matrix(runif(n*p,-1,1),nrow=n,ncol=p)
  beta1 <- rnorm(p,0,1)
  beta2 <- rnorm(p,0,1)
  # treatment allocation coded as {0,1} for algebraic simplicity later
  A <- rep(0,n)
  A[sample(1:n,ceiling(n/2),replace=F)] <- 1
  epsilon <- rnorm(n,0,epsilon)
  marker <- rep(0,n)
  marker[X[,1]< -0.5] <- -1
  marker[X[,1]>0.5] <- 1
  if (!antag) {
    R1 <- X%*%beta1+epsilon
    R1[marker==1] <- R1[marker==1]+d1*A[marker==1]
    R1[marker==-1] <- R1[marker==-1]-d1*A[marker==-1]
    R2 <- X%*%beta2+epsilon
    R2[marker==1] <- R2[marker==1]+d2*A[marker==1]
    R2[marker==-1] <- R2[marker==-1]-d2*A[marker==-1]
  }
  if (antag) {
    R1 <- X%*%beta1+epsilon
    R1[marker==1] <- R1[marker==1]+d1*A[marker==1]
    R1[marker==-1] <- R1[marker==-1]-d1*A[marker==-1]
    R2 <- X%*%beta2+epsilon
    R2[marker==1] <- R2[marker==1]-d2*A[marker==1]
    R2[marker==-1] <- R2[marker==-1]+d2*A[marker==-1]
  }
  R <- bivariate_to_composite(R1,R2,quantile(R1,quant_cut))
  ret_list <- c("X","beta1","beta2","A","marker","R1","R2","R")
  ret <- sapply(ret_list,function(x) NULL)
  for (r in ret_list) {
    eval(parse(text=sprintf("ret$%s = %s",r,r)))
  }
  return(ret)
}

# starting random number seed (23 for Michael Jordan)
seed <- 23

# define colorblind-friendly palette for use later
cbPalette <- c("#000000", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

# Define UI
# sliders to set simulation specifications
# resulting graphs of R1, R2, and R
ui <- fluidPage(
   
   # Application title
   titlePanel("Univariate vs. Composite Outcomes for FLEX Simulation 1"),
   
   # Sidebar with slider inputs for n, p, true R1/R2 treatment effect, and a button to change seed
   sidebarLayout(
      sidebarPanel(
         sliderInput("n",
                    label="Sample Size:",
                    min = 50,
                    max = 500,
                    value = 100),
         sliderInput("p",
                     label="Covariate Dimension:",
                     min = 5,
                     max = 50,
                     value = 30),
         sliderInput("d1",
                     label="R1 Treatment Effect:",
                     min = 1,
                     max = 10,
                     value = 3),
         sliderInput("d2",
                     label="R2 Treatment Effect:",
                     min = 1,
                     max = 10,
                     value = 3),
         numericInput("seed","Random Number Seed",value=23)
      ),
      
      # Scatterplot R/R1/R2 by the true splitting variable, X1
      mainPanel(
        plotlyOutput("compPlot"),
        plotlyOutput("univPlot1"),
        plotlyOutput("univPlot2")
      )
   )
)

# Define server logic required to draw scatterplots
server <- function(input, output) {
  observeEvent(input$changeseed,{seed=seed+1})
  # Plot for R
   output$compPlot <- renderPlotly({
     # generate data based on slider input
     dat <- generate_sim_data_1s(codedir,n=input$n,p=input$p,epsilon=1,d1=input$d1,d2=input$d2,seed=input$seed)
      x    <- dat$X[,1]
      R1 <- dat$R1
      R2 <- dat$R2
      R <- dat$R
      A <- factor(dat$A)

      plotdata <- data.frame(x,R1,R2,R,A)

      # set up axis titles
      x <- list(
        title = "X1 (True Splitting Variable)"
      )
      y <- list(
        title = "R (Composite Outcome)"
      )
      # draw the graph
      plot_ly(plotdata,x=~x,y=~R,name="A",type="scatter",mode="markers",color=~A,colors=cbPalette) %>% layout(xaxis=x,yaxis=y)

   })
   
   # Plot for R1
   output$univPlot1 <- renderPlotly({
     # generate data based on slider input
     dat <- generate_sim_data_1s(codedir,n=input$n,p=input$p,epsilon=1,d1=input$d1,d2=input$d2,seed=input$seed)
     x    <- dat$X[,1]
     R1 <- dat$R1
     R2 <- dat$R2
     R <- dat$R
     A <- factor(dat$A)
     
     plotdata <- data.frame(x,R1,R2,R,A)
     
     # set up axis titles
     x <- list(
       title = "X1 (True Splitting Variable)"
     )
     y <- list(
       title = "R1 (Univariate Outcome 1)"
     )
     # draw the graph
     plot_ly(plotdata,x=~x,y=~R1,name="A",type="scatter",mode="markers",color=~A,colors=cbPalette) %>% layout(xaxis=x,yaxis=y)
     
   })
   
   # Plot for R2
   output$univPlot2 <- renderPlotly({
     # generate data based on slider input
     dat <- generate_sim_data_1s(codedir,n=input$n,p=input$p,epsilon=1,d1=input$d1,d2=input$d2,seed=input$seed)
     x    <- dat$X[,1]
     R1 <- dat$R1
     R2 <- dat$R2
     R <- dat$R
     A <- factor(dat$A)
     
     plotdata <- data.frame(x,R1,R2,R,A)
     
     # set up axis titles
     x <- list(
       title = "X1 (True Splitting Variable)"
     )
     y <- list(
       title = "R2 (Univariate Outcome 2)"
     )
     # draw the graph
     plot_ly(plotdata,x=~x,y=~R2,name="A",type="scatter",mode="markers",color=~A,colors=cbPalette) %>% layout(xaxis=x,yaxis=y)
     
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

