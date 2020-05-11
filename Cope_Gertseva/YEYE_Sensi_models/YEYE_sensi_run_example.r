devtools::install_github("r4ss/r4ss")
library(r4ss)
Dir<-"C:/Users/.../YEYE_Sensi_models/"
#Set directory and extract ouput from models
setwd(Dir)
#Read in the Sensi plot code
source("Sensi.plot.code.r")

#Model 1 needs to be the Reference model, with sensitivity runs following from run 2 on.
folder.name<-"REFERENCE_MODEL_" #Common folder name for all sensitivity runs
zz<-list()
Runs<-27
for(i in 1:Runs) 
  {
	setwd(paste0(Dir,folder.name,i))
	if(i==1){zz[[i]]<-SS_output(getwd())}
	if(i>1){zz[[i]]<-SS_output(getwd(),covar=FALSE)}
  }

#Use the summarize function in r4ss to get model summaries
model.summaries<- SSsummarize(zz)

#Define the names of each model. This will be used to label runs in the table and in the figures.
Mod.spec.names<-c(
"Reference",
"NWFSC biased",
"WDFW biased",
"WDFW w/ ADFG",
"NWFSC w/ ADFG",
"M est",
"NMT prior, fixed",
"NMT prior, est.",
"h est",
"2011 h value",
"2011 L-W",
"2011 maturity",
"spline maturity",
"2011 fecundity",
"All years -50%",
"All years +50%",
"Comm. -50%",
"Comm. +50%",
"Rec. -50%",
"Rec. +50%",
"Lumped comp data",
"No rec devs",
"Est. dome sel",
"harm. mean wgting",
"1 area",
"2 sex",
"Rec. sel. dome"
)


#Run the sensitivity plot function
setwd(Dir)
SS_Sensi_plot(model.summaries=model.summaries,
              current.year=2017,
              mod.names=Mod.spec.names, #List the names of the sensitivity runs
              likelihood.out=c(1,1,1),
              Sensi.RE.out="Sensi_RE_out.DMP", #Saved file of relative errors
              CI=0.95, #Confidence interval box based on the reference model
              TRP.in=0.4, #Target relative abundance value
              LRP.in=0.25, #Limit relative abundance value
              sensi_xlab="Sensitivity scenarios", #X-axis label
              ylims.in=c(-1,2,-1,2,-1,2,-1,2,-1,2,-1,2), #Y-axis label
              plot.figs=c(1,1,1,1,1,1,1,1), #Which plots to make/save? 
              sensi.type.breaks=c(5.5,8.5,10.5,14.5,20.5), #vertical breaks that can separate out types of sensitivities
              anno.x=c(3.5,3.5 ,7,9.5,12.5,12.5,17.5,24, -1, -1), # Vertical positioning of the sensitivity types labels
              anno.y=c(1.9,1.8,1.9,1.9,1.9,1.8,1.9,1.9,0.48,-0.18), # Horizontal positioning of the sensitivity types labels
              anno.lab=c("Ageing","Error","M","h","L-W;","Mat.","Removals","Other","TRP","LRP") #Sensitivity types labels
)
