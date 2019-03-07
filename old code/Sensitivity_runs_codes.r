devtools::install_github("r4ss/r4ss")
library(r4ss)
library(ggplot2)
library(plyr)

RUN.SS<-function(path, ss.exe="SS",ss.cmd=" -nohess -nox")
{
  navigate <- paste("cd ",path,sep="")
  command <- paste(navigate," & ",ss.exe,ss.cmd,sep="")
  shell(command,invisible=TRUE,translate=TRUE)
}


#CPUE runs: 1-8
#Lt comps: 9-20
#Age comps: 21-28
#No CPUE: 29
#No Lt comps: 30
#No Age comps:31

#Likelihood components
Dir<-"C:/Users/Jason.Cope/Desktop/Yelloweye_2017_folders/YE_models/Sensitivities/Likelihood components/"
Runs<-32
for(i in 1:Runs) 
  {
    setwd(paste0(Dir,"Reference Model all data in_",i))
    RUN.SS(paste(getwd(),"/",sep=""), ss.exe="SS",ss.cmd=" -nohess -nox")
  }

#Process output
survey.like<-Lt.like<-Age.like<-survey.lambda<-Lt.lambda<-Age.lambda<-parms<-qs<-dev.quants<-list()
for(i in 1:Runs) 
  {
	setwd(paste0(Dir,"Reference Model all data in_",i))
	zz<-SS_output(getwd(),covar=FALSE)
	#SS_plots(zz,uncertainty=FALSE)

	fleet.likes<-zz$likelihoods_by_fleet
	survey.lambda[[i]]<-fleet.likes[1,][-1:-2]
	survey.like[[i]]<-fleet.likes[2,][-1:-2]
	Lt.lambda[[i]]<-fleet.likes[3,][-1:-2]
	
	Lt.like[[i]]<-fleet.likes[4,][-1:-2]
	Age.lambda[[i]]<-fleet.likes[5,][-1:-2]
	Age.like[[i]]<-fleet.likes[6,][-1:-2]
	
	parms[[i]]<-zz$estimated_non_dev_parameters[,1]
	qs[[i]]<-unique(zz$cpue$Calc_Q)
	if(zz$nsexes==1){SB_curr<-zz$derived_quants[zz$derived_quants$Label=="SPB_2017",2]/2}
	if(zz$nsexes==2){SB_curr<-zz$derived_quants[zz$derived_quants$Label=="SPB_2017",2]}
	dev.quants[[i]]<-c(zz$SBzero,
	                   SB_curr,
	                   zz$current_depletion,zz$derived_quants[zz$derived_quants$Label=="TotYield_SPRtgt",2],
	                   zz$derived_quants[zz$derived_quants$Label=="Fstd_SPRtgt",2])
 }
 
setwd(Dir)
survey.like.LC<-mapply(cbind,survey.like)
Lt.like.LC<-mapply(cbind,Lt.like)
Age.like.LC<-mapply(cbind,Age.like)

survey.lambda.LC<-mapply(cbind,survey.lambda)
Lt.lambda.LC<-mapply(cbind,Lt.lambda)
Age.lambda.LC<-mapply(cbind,Age.lambda)

qs.LC<-mapply(cbind,qs)
#write.csv(qs.LC)
parms.LC<-mapply(cbind,parms)
rownames(parms.LC)<-rownames(zz$estimated_non_dev_parameters)
dev.quants.LC<-mapply(cbind,dev.quants)
rownames(dev.quants.LC)<-c("SB0","SB2017","SB2017/SB0","Yield_SPR","F_SPR_target")

write.csv(rbind(survey.like.LC,survey.lambda.LC,Lt.like.LC,Lt.lambda.LC,Age.like.LC,Age.lambda.LC,qs.LC,parms.LC,dev.quants.LC),paste0(Dir,"LC_parms_quants.csv"))


#Model specification
Dir<-"C:/Users/Jason.Cope/Desktop/YE_models/Sensitivities/Model specification/"
Runs<-27
for(i in 2:Runs) 
{
  setwd(paste0(Dir,"REFERENCE_MODEL_",i))
  RUN.SS(paste(getwd(),"/",sep=""), ss.exe="SS",ss.cmd=" -nohess -nox")
}

#Process output
devtools::install_github("r4ss/r4ss")
library(r4ss)
library(plyr)
Dir<-"C:/Users/Jason.Cope/Desktop/YE_models/Sensitivities/Model specification/For table/"

Runs<-27
survey.like<-Lt.like<-Age.like<-survey.lambda<-Lt.lambda<-Age.lambda<-parms<-qs<-dev.quants<-list()
for(i in 1:Runs) 
  {
	setwd(paste0(Dir,"REFERENCE_MODEL_",i))
	zz<-SS_output(getwd(),covar=FALSE)
	#SS_plots(zz,uncertainty=FALSE)

	fleet.likes<-zz$likelihoods_by_fleet
	survey.lambda[[i]]<-fleet.likes[1,][-1:-2]
	survey.like[[i]]<-fleet.likes[2,][-1:-2]
	Lt.lambda[[i]]<-fleet.likes[3,][-1:-2]
	Lt.like[[i]]<-fleet.likes[4,][-1:-2]
	Age.lambda[[i]]<-fleet.likes[5,][-1:-2]
	Age.like[[i]]<-fleet.likes[6,][-1:-2]
	
	parms[[i]]<- as.data.frame(cbind(rownames(zz$estimated_non_dev_parameters),zz$estimated_non_dev_parameters[,1]))
	#rownames(parms[[i]])<-rownames(zz$estimated_non_dev_parameters)
	colnames(parms[[i]])<-c("rn",i)
	qs[[i]]<-unique(zz$cpue$Calc_Q)
	if(zz$nsexes==1){SB_curr<-zz$derived_quants[zz$derived_quants$Label=="SPB_2017",2]/2}
	if(zz$nsexes==2){SB_curr<-zz$derived_quants[zz$derived_quants$Label=="SPB_2017",2]}
	dev.quants[[i]]<-c(zz$SBzero,
	                   SB_curr,
	                   zz$current_depletion,zz$derived_quants[zz$derived_quants$Label=="TotYield_SPRtgt",2],
	                   zz$derived_quants[zz$derived_quants$Label=="Fstd_SPRtgt",2])
 }
 
survey.like.MS<-mapply(cbind,survey.like)
Lt.like.MS<-mapply(cbind,Lt.like)
Age.like.MS<-mapply(cbind,Age.like)
colnames(survey.like.MS)<-colnames(Lt.like.MS)<-colnames(Age.like.MS)<-1:Runs

survey.lambda.MS<-mapply(cbind,survey.lambda)
Lt.lambda.MS<-mapply(cbind,Lt.lambda)
Age.lambda.MS<-mapply(cbind,Age.lambda)
colnames(survey.lambda.MS)<-colnames(Lt.lambda.MS)<-colnames(Age.lambda.MS)<-1:Runs

qs.MS<-mapply(cbind,qs)
colnames(qs.MS)<-1:Runs
#write.csv(qs.LC)
parms.MS<-join_all(parms, by = "rn", type = 'full')
rownames(parms.MS)<-parms.MS[,1]
parms.MS<-parms.MS[,-1]
dev.quants.MS<-mapply(cbind,dev.quants)
rownames(dev.quants.MS)<-c("SB0","SB2017","SB2017/SB0","Yield_SPR","F_SPR_target")
colnames(dev.quants.MS)<-1:Runs

MS.table<-rbind(survey.like.MS,survey.lambda.MS,Lt.like.MS,Lt.lambda.MS,Age.like.MS,Age.lambda.MS,qs.MS,parms.MS,dev.quants.MS)
MS.table<-as.data.frame(t(apply(MS.table, 1, unlist)))
write.csv(MS.table,file=paste0(Dir,"MS_parms_quants.csv"))

library(reshape2)

like.comps.names<-c(
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

#Calcualte relative errors
RE.LC<-melt((dev.quants.LC[-5,]-dev.quants.LC[-5,1])/dev.quants.LC[-5,1])
RE.LC<-subset(RE.LC,Var2>1)
#Get values for plots
Dev.quants.LC.temp<-as.data.frame(cbind(rownames(dev.quants.LC)[-5],dev.quants.LC[-5,-1]))
colnames(Dev.quants.LC.temp)<-c("Metric",like.comps.names)
Dev.quants.LC.ggplot<-as.data.frame(cbind(melt(Dev.quants.LC.temp,id.vars=c("Metric")),RE.LC[,2:3],"LC"))
colnames(Dev.quants.LC.ggplot)<-c("Metric","Model_name","Value","Model_num_plot","RE","Sensi")
save(Dev.quants.LC.ggplot,file="Dev.quants.LC.ggplot.DMP")


Mod.spec.names<-c(
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

#Calcualte relative errors
RE.MS<-melt((dev.quants.MS[-5,]-dev.quants.MS[-5,1])/dev.quants.MS[-5,1])
RE.MS<-subset(RE.MS,Var2>1)
#Get values for plots
Dev.quants.MS.temp<-as.data.frame(cbind(rownames(dev.quants.MS)[-5],dev.quants.MS[-5,-1]))
colnames(Dev.quants.MS.temp)<-c("Metric",Mod.spec.names)
Dev.quants.MS.ggplot<-as.data.frame(cbind(melt(Dev.quants.MS.temp,id.vars=c("Metric")),RE.MS[,2:3],"ModSpec"))
colnames(Dev.quants.MS.ggplot)<-c("Metric","Model_name","Value","Model_num_plot","RE","Sensi")
save(Dev.quants.MS.ggplot,file="Dev.quants.MS.ggplot.DMP")

#Combine sensitivities into one file
Dev.quants.ggplot<-rbind(Dev.quants.LC.ggplot,Dev.quants.MS.ggplot)
save(Dev.quants.ggplot,file="C:/Users/Jason.Cope/Desktop/YE_models/Sensitivities/Dev.quants.ggplot.DMP")


library(ggplot2)

gg_color_hue <- function(n) {
  hues = seq(15, 375, length = n + 1)
  hcl(h = hues, l = 65, c = 100)[1:n]
}

four.colors<-gg_color_hue(4)
setwd("C:/Users/Jason.Cope/Desktop/Yelloweye_2017_folders/YE_models/Sensitivities/")
#sensi.plot.in<-read.table('clipboard',header=TRUE)
#sensi.plot.in<-read.csv("Sensi_outs.csv")
load("Likelihood components/Dev.quants.LC.ggplot.DMP")
load("Model specification/For table/Dev.quants.MS.ggplot.DMP")
#sensi.plot.in.MS<-subset(sensi.plot.in,Sensi=="ModSpec")
#sensi.plot.in.LC<-subset(sensi.plot.in,Sensi=="LC")

ggplot(Dev.quants.LC.ggplot,aes(Model_num_plot,RE))+geom_point(aes(shape=Metric,color=Metric))+
  geom_rect(aes(xmin=1,xmax=33,ymin=-0.118,ymax=0.118),fill=NA,color=four.colors[1])+ 
  geom_rect(aes(xmin=1,xmax=33,ymin=-0.224,ymax=0.224),fill=NA,color=four.colors[2])+ 
  geom_rect(aes(xmin=1,xmax=33,ymin=-0.22,ymax=0.22),fill=NA,color=four.colors[3])+
  geom_rect(aes(xmin=1,xmax=33,ymin=-0.17,ymax=0.17),fill=NA,color=four.colors[4])+ 
  geom_vline(xintercept =c(8.5,20.5),lty=2)+
  geom_hline(yintercept =c(-0.12,0.413),lty=2,color=four.colors[3])+
  scale_x_continuous(breaks = 2:32,labels=unique(Dev.quants.LC.ggplot$Model_name))+
  scale_y_continuous(limits=c(-1,2))+
  theme(axis.text.x = element_text(angle=90,vjust=0.25))+
  labs(x = "Likelihood component removed",y = "Relative error")+
  annotate("text",x=c(4,14.5,27,-1,-1),y=c(2,2,2,0.48,-0.18),label=c("Index","Lengths","Ages","TRP","LRP"))


Dev.quants.MS.ggplot$Metric<-revalue(Dev.quants.MS.ggplot$Metric,c("SB0"="SS0","SB2017"="SS2017","SB2017/SB0"="SS2017/SS0"))
ggplot(Dev.quants.MS.ggplot,aes(Model_num_plot,RE))+geom_point(aes(shape=Metric,color=Metric))+
  geom_rect(aes(xmin=1,xmax=28,ymin=-0.118,ymax=0.118),fill=NA,color=four.colors[1])+ 
  geom_rect(aes(xmin=1,xmax=28,ymin=-0.224,ymax=0.224),fill=NA,color=four.colors[2])+ 
  geom_rect(aes(xmin=1,xmax=28,ymin=-0.22,ymax=0.22),fill=NA,color=four.colors[3])+
  geom_rect(aes(xmin=1,xmax=28,ymin=-0.17,ymax=0.17),fill=NA,color=four.colors[4])+ 
  geom_vline(xintercept =c(5.5,8.5,10.5,14.5,20.5),lty=2)+
  geom_hline(yintercept =c(-0.12,0.413),lty=2,color=four.colors[3])+
  theme(axis.text.x = element_text(angle=90,vjust=0.25))+
  labs(x = "Model specification",y = "Relative error")+
  scale_x_continuous(breaks = 2:27,labels=unique(Dev.quants.MS.ggplot$Model_name))+
  scale_y_continuous(limits=c(-1,2))+
  annotate("text",x=c(3.5,7,9.5,12.5,17.5,24, -1, -1),y=c(1.9,1.9,1.9,1.9,1.9,1.9,0.48,-0.18),label=c("Ageing Er.","M","h","L-W; Mat.","Removals","Other","TRP","LRP"))
  
