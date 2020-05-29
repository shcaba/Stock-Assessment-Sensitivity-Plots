devtools::install_github("r4ss/r4ss")
library(r4ss)
library(flextable)
#Set directory and extract ouput from models
#Model 1 needs to be the Reference model, with sensitivity runs following from run 2 on.
Dir<-"C:/Users/.../GitHub/Stock-Assessment-Sensitivity-Plots/Sensitivity_runs/"
folder.name<-"Cab_SCS_MS_" #Common folder name for all sensitivity runs
zz<-list()
Runs<-19
for(i in 1:Runs) 
  {
	setwd(paste0(Dir,folder.name,i))
	if(i==1){zz[[i]]<-SS_output(getwd())}
	if(i>1){zz[[i]]<-SS_output(getwd(),covar=FALSE)}
  }
setwd(Dir)

#Use the summarize function in r4ss to get model summaries
model.summaries<- SSsummarize(zz)

#Define the names of each model. This will be used to label runs in the table and in the figures.
mod.names<-c(
  "Reference",
  "M: Fix to 2009",
  "M: Fix to prior",
  "M: Fix to Hamel",
  "M: Fix to VBGF",
  "M: Fix to OR",
  "VBGF 2009",
  "VBGF Grebel",
  "OR maturity",
  "Est. h",
  "All rec devs",
  "No rec devs",
  "High bias adj.",
  "Harmonic mean",
  "Dirichlet",
  "Wts = 1",
  "No blocks",
  "First blocks in 2000",
  "Alt rec catches"
)

#Run the sensitivity plot function
SS_Sensi_plot(model.summaries=model.summaries,
              current.year=2019,
              mod.names=mod.names, #List the names of the sensitivity runs
              likelihood.out=c(1,1,0),
              Sensi.RE.out="Sensi_RE_out.DMP", #Saved file of relative errors
              CI=0.95, #Confidence interval box based on the reference model
              TRP.in=0.4, #Target relative abundance value
              LRP.in=0.25, #Limit relative abundance value
              sensi_xlab="Sensitivity scenarios", #X-axis label
              ylims.in=c(-1,1,-1,1,-1,1,-1,1,-1,1,-1,1), #Y-axis label
              plot.figs=c(1,1,1,1,1,1), #Which plots to make/save? 
              sensi.type.breaks=c(6.5,9.5,13.5,16.5), #vertical breaks that can separate out types of sensitivities
              anno.x=c(3.75,8,11.5,15,18), # Vertical positioning of the sensitivity types labels
              anno.y=c(1,1,1,1,1), # Horizontal positioning of the sensitivity types labels
              anno.lab=c("Natural mortality","VBGF/Mat.","Recruitment","Data Wts.","Other") #Sensitivity types labels
)

