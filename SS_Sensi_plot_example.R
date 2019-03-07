devtools::install_github("r4ss/r4ss")
library(r4ss)

#Set directory and extract ouput from models
#Model 1 needs to be the Reference model, with sensitivity runs following from run 2 on.
Dir<-"C:/Users/.../GitHub/Stock-Assessment-Sensitivity-Plots/Sensitivity_runs/"
zz<-list()
Runs<-32
for(i in 1:Runs) 
  {
	setwd(paste0(Dir,"Reference Model all data in_",i))
	if(i==1){zz[[i]]<-SS_output(getwd())}
	if(i>1){zz[[i]]<-SS_output(getwd(),covar=FALSE)}
  }
setwd(Dir)

#Use the summarize function in r4ss to get model summaries
model.summaries<- SSsummarize(zz)

#Define the names of each model. This will be used to label runs in the table and in the figures.
mod.names<-c(
"Reference",
"I: -CA dockside rec",
"I: -OR dockside rec",
"I: -WA dockside rec",
"I: -CA CPFV",
"I: -OR onboard",
"I: -AFSC Triennial",
"I: -NWFSC Trawl",
"I: -IPHC",
"LtC: -CA trawl",
"LtC: -CA non-trawl",
"LtC: -CA dockside rec",
"LtC: -OR-WA trawl",
"LtC: -OR-WA non-trawl",
"LtC: -OR dockside rec",
"LtC: -WA dockside rec",
"LtC: -CA CPFV",
"LtC: -OR onboard",
"LtC: -AFSC Triennial",
"LtC: -NWFSC Trawl",
"LtC: -IPHC",
"AgeC: -CA non-trawl",
"AgeC: -CA dockside rec",
"AgeC: -OR-WA trawl",
"AgeC: -OR-WA non-trawl",
"AgeC: -OR dockside rec",
"AgeC: -WA dockside rec",
"AgeC: -NWFSC Trawl",
"AgeC: -IPHC",
"-all indices",
"-all length comps",
"-all age comps"
)

#Run the sensitivity plot function
SS_Sensi_plot(model.summaries=model.summaries,
						current.year=2017,
						mod.names=mod.names, #List the names of the sensitivity runs
						filename.in="Sensi_RE_out.DMP", #Saved file of relative errors
						CI=0.95, #Confidence interval box based on the reference model
						TRP.in=0.4, #Target relative abundance value
						LRP.in=0.25, #Limit relative abundance value
						sensi_xlab="Sensitivity scenarios", #X-axis label
						ylims.in=c(-1,2,-1,2,-1,2,-1,2,-1,2,-1,2), #Y-axis label
						plot.figs=c(1,1,1,1,1,1), #Which plots to make/save? 
						sensi.type.breaks=c(9.5,21.5),
						anno.x=c(4,14.5,27),
						anno.y=c(2,2,2),
						anno.lab=c("Index","Lengths","Ages"))

