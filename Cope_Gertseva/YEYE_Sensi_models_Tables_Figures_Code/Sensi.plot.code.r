devtools::install_github("r4ss/r4ss")
library(r4ss)
library(ggplot2)
library(plyr)
library(reshape2)
library(flextable)
library(officer)

gg_color_hue <- function(n) 
	{
  		hues = seq(15, 375, length = n + 1)
  		hcl(h = hues, l = 65, c = 100)[1:n]
	}


#current.year: Year to report output
#mod.names: List the names of the sensitivity runs
#likelihood.out=c(1,1,1): Note which likelihoods are in the model (surveys, lengths, ages)
#Sensi.RE.out="Sensi_RE_out.DMP": #Saved file of relative errors
#CI=0.95:Confidence interval box based on the reference model
#TRP.in=0.4:Target relative abundance value
#LRP.in=0.25: Limit relative abundance value
#sensi_xlab="Sensitivity scenarios" : X-axis label
#ylims.in=c(-1,2,-1,2,-1,2,-1,2,-1,2,-1,2): Y-axis label
#plot.figs=c(1,1,1,1,1,1): Which plots to make/save?
#sensi.type.breaks=NA: vertical breaks that can separate out types of sensitivities
#anno.x=NA: Vertical positioning of the sensitivity types labels
#anno.y=NA: Horizontal positioning of the sensitivity types labels
#anno.lab=NA: Sensitivity types labels


SS_Sensi_plot<-function(model.summaries,
						current.year, 
						mod.names, 
						likelihood.out=c(1,1,1), 
						Sensi.RE.out="Sensi_RE_out.DMP", 
						CI=0.95, 
						TRP.in=0.4, 
						LRP.in=0.25, 
						sensi_xlab="Sensitivity scenarios",
						ylims.in=c(-1,2,-1,2,-1,2,-1,2,-1,2,-1,2),
						plot.figs=c(1,1,1,1,1,1),
						sensi.type.breaks=NA,
						anno.x=NA,
						anno.y=NA,
						anno.lab=NA)
{
 	#num.likes<-sum(likelihood.out)*2+2
 	num.likes<-dim(subset(model.summaries$likelihoods_by_fleet,model==1))[1] #determine how many likelihoods components

 	if(missing(mod.names)){mod.names<-paste("model ",1:model.summaries$n)}
		if(likelihood.out[1]==1)
			{
				syrvlambda_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Surv_lambda"]
				survey.lambda<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(3,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Survey_lambda")
				
				syrvlike_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Surv_like"]
				survey.like<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(syrvlike_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Survey_likelihood")			
			}
			else
			{
				survey.lambda<-survey.like<-data.frame(t(rep(NA,model.summaries$n+2)))
			}
		if(likelihood.out[2]==1)
			{
				Ltlambda_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Length_lambda"]
				Lt.lambda<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(Ltlambda_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Lt_lambda")
				Ltlike_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Length_like"]
				Lt.like<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(Ltlike_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Lt_likelihood")
			}
			else
			{
				Lt.lambda<-Lt.like<-data.frame(t(rep(NA,model.summaries$n+2)))
			}
		if(likelihood.out[3]==1)
			{
				Agelambda_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Age_lambda"]
				Age.lambda<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(Agelambda_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Age_lambda")
				Agelike_index<-c(1:num.likes)[subset(model.summaries$likelihoods_by_fleet,model==1)$Label=="Age_like"]
				Age.like<-data.frame(rownames(t(model.summaries$likelihoods_by_fleet))[-1:-2],t(model.summaries$likelihoods_by_fleet[seq(Agelike_index,dim(model.summaries$likelihoods_by_fleet)[1], num.likes),][-1:-2]),"Age_likelihood")
			}
			else
			{
				 Age.lambda<-Age.like<-data.frame(t(rep(NA,model.summaries$n+2)))
			}

	parms<-model.summaries$pars
	#rownames(parms)<-parms$Label
	parms<-data.frame(parms$Label,parms[,1:(dim(parms)[2]-3)],"Parameters")
	if(any(model.summaries$nsexes==1))
		{
			dev.quants<-rbind(
						model.summaries$quants[model.summaries$quants$Label=="SSB_Initial",1:(dim(model.summaries$quants)[2]-2)]/2,
						(model.summaries$quants[model.summaries$quants$Label==paste0("SSB_",current.year),1:(dim(model.summaries$quants)[2]-2)])/2,
						model.summaries$quants[model.summaries$quants$Label==paste0("Bratio_",current.year),1:(dim(model.summaries$quants)[2]-2)],
						model.summaries$quants[model.summaries$quants$Label=="SPR_MSY",1:(dim(model.summaries$quants)[2]-2)]/2,
						model.summaries$quants[model.summaries$quants$Label=="Fstd_SPRtgt",1:(dim(model.summaries$quants)[2]-2)]
						)
			#Extract SDs for use in the ggplots
			dev.quants.SD<-c(
						model.summaries$quantsSD[model.summaries$quantsSD$Label=="SSB_Initial",1]/2,
						(model.summaries$quantsSD[model.summaries$quantsSD$Label==paste0("SSB_",current.year),1])/2,
						model.summaries$quantsSD[model.summaries$quantsSD$Label==paste0("Bratio_",current.year),1],
						model.summaries$quantsSD[model.summaries$quantsSD$Label=="SPR_MSY",1]/2,
						model.summaries$quantsSD[model.summaries$quantsSD$Label=="Fstd_SPRtgt",1]
						)
		}
	if(any(model.summaries$nsexes==2))
		{
			dev.quants<-rbind(
						model.summaries$quants[model.summaries$quants$Label=="SSB_Initial",1:(dim(model.summaries$quants)[2]-2)],
						model.summaries$quants[model.summaries$quants$Label==paste0("SSB_",current.year),1:(dim(model.summaries$quants)[2]-2)],
						model.summaries$quants[model.summaries$quants$Label==paste0("Bratio_",current.year),1:(dim(model.summaries$quants)[2]-2)],
						model.summaries$quants[model.summaries$quants$Label=="SPR_MSY",1:(dim(model.summaries$quants)[2]-2)],
						model.summaries$quants[model.summaries$quants$Label=="Fstd_SPRtgt",1:(dim(model.summaries$quants)[2]-2)]
						)
			#Extract SDs for use in the ggplots
			dev.quants.SD<-c(
						model.summaries$quantsSD[model.summaries$quantsSD$Label=="SSB_Initial",1],
						(model.summaries$quantsSD[model.summaries$quantsSD$Label==paste0("SSB_",current.year),1]),
						model.summaries$quantsSD[model.summaries$quantsSD$Label==paste0("Bratio_",current.year),1],
						model.summaries$quantsSD[model.summaries$quantsSD$Label=="SPR_MSY",1],
						model.summaries$quantsSD[model.summaries$quantsSD$Label=="Fstd_SPRtgt",1]
						)
		}
	dev.quants.labs<-data.frame(c("SB0",paste0("SSB_",current.year),paste0("Bratio_",current.year),"MSY_SPR","F_SPR"),dev.quants,"Derived quantities")
	AICs<-2*model.summaries$npars+(2*as.numeric(model.summaries$likelihoods[1,1:model.summaries$n]))
	deltaAICs<-AICs-AICs[1]
	AIC.out<-data.frame(cbind(c("AIC","deltaAIC"),rbind.data.frame(AICs,deltaAICs),c("AIC")))
	colnames(AIC.out)<-colnames(survey.lambda)<-colnames(survey.like)<-colnames(Lt.lambda)<-colnames(Lt.like)<-colnames(Age.lambda)<-colnames(Age.like)<-colnames(parms)<-colnames(dev.quants.labs)<-c("Type",mod.names,"Label")
	Like.parm.quants<-rbind(AIC.out,survey.like,survey.lambda,Lt.like,Lt.lambda,Age.like,Age.lambda,parms,dev.quants.labs)	
	Like.parm.quants.table.data<-as_grouped_data(Like.parm.quants,groups=c("Label"))
	#as_flextable(Like.parm.quants.table.data)
	write.csv(Like.parm.quants.table.data,paste0(Dir,"Likes_parms_devquants_table.csv"))

#Calcualte relative errors
dev.quants.mat<-as.matrix(dev.quants)
colnames(dev.quants.mat)<-1:dim(dev.quants.mat)[2]
rownames(dev.quants.mat)<-c("SB0",paste0("SSB_",current.year),paste0("Bratio_",current.year),"MSY_SPR","F_SPR")
#RE<-melt((as.matrix(dev.quants)-as.matrix(dev.quants)[,1])/as.matrix(dev.quants)[,1])
RE<-melt((dev.quants.mat-dev.quants.mat[,1])/dev.quants.mat[,1])[-1:-5,]
#Get values for plots
Dev.quants.temp<-as.data.frame(cbind(rownames(dev.quants.mat),dev.quants.mat[,-1]))
colnames(Dev.quants.temp)<-c("Metric",mod.names[-1])
Dev.quants.ggplot<-data.frame(melt(Dev.quants.temp,id.vars=c("Metric")),RE[,2:3])
colnames(Dev.quants.ggplot)<-c("Metric","Model_name","Value","Model_num_plot","RE")
Dev.quants.ggplot$Metric<-factor(Dev.quants.ggplot$Metric,levels=unique(Dev.quants.ggplot$Metric))
save(Dev.quants.ggplot,file=Sensi.RE.out)

#Calculate RE values for reference model boxes
CI_DQs_RE<-((dev.quants[,1]+dev.quants.SD*qnorm(CI))-dev.quants[,1])/dev.quants[,1]
TRP<-(TRP.in-dev.quants[3,1])/dev.quants[3,1]
LRP<-(LRP.in-dev.quants[3,1])/dev.quants[3,1]
#Plot relative errors
four.colors<-gg_color_hue(5)
lty.in=2
if(any(is.na(sensi.type.breaks)))
	{
		lty.in=0
		sensi.type.breaks=c(1,1)
	}
if(any(is.na(anno.x)))
	{
		anno.x=c(1,1)
	}
if(any(is.na(anno.y)))
	{
		anno.y=c(1,1)
	}

if(any(is.na(anno.lab)))
	{
		anno.lab=c("","")
	}

if(plot.figs[1]==1)
{
ggplot(Dev.quants.ggplot,aes(Model_num_plot,RE))+
  geom_point(aes(shape=Metric,color=Metric))+
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[1],ymax=CI_DQs_RE[1]),fill=NA,color=four.colors[1])+ 
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[2],ymax=CI_DQs_RE[2]),fill=NA,color=four.colors[2])+ 
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[3],ymax=CI_DQs_RE[3]),fill=NA,color=four.colors[3])+
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[4],ymax=CI_DQs_RE[4]),fill=NA,color=four.colors[4])+ 
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[5],ymax=CI_DQs_RE[5]),fill=NA,color=four.colors[5])+ 
  geom_hline(yintercept =c(TRP,LRP),lty=c(1,2),color=c("darkgreen","darkred"))+
  scale_x_continuous(breaks = 2:model.summaries$n,labels=unique(Dev.quants.ggplot$Model_name))+
  scale_y_continuous(limits=ylims.in[1:2])+
  theme(axis.text.x = element_text(angle=90,vjust=0.25))+
  labs(x = sensi_xlab,y = "Relative error")+
  annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
  geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave("Sensi_REplot_all.png")
}

if(plot.figs[2]==1)
{
Dev.quants.ggplot.SB0<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[1])
ggplot(Dev.quants.ggplot.SB0,aes(Model_num_plot,RE))+
  geom_point(aes(shape=Metric),color=four.colors[1])+
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[1],ymax=CI_DQs_RE[1]),fill=NA,color=four.colors[1])+ 
  geom_hline(yintercept =0,lty=1,color="gray")+
  scale_x_continuous(breaks = 2:model.summaries$n,labels=unique(Dev.quants.ggplot.SB0$Model_name))+
  scale_y_continuous(limits=ylims.in[3:4])+
  theme(axis.text.x = element_text(angle=90,vjust=0.25))+
  labs(x = sensi_xlab,y = "Relative error")+
  annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
  geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
  ggsave("Sensi_REplot_SB0.png")
}

if(plot.figs[3]==1)
{
Dev.quants.ggplot.SBt<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[2])
ggplot(Dev.quants.ggplot.SBt,aes(Model_num_plot,RE))+
  geom_point(aes(shape=Metric),color=four.colors[2])+
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[2],ymax=CI_DQs_RE[2]),fill=NA,color=four.colors[2])+ 
  geom_hline(yintercept =0,lty=1,color="gray")+
  scale_x_continuous(breaks = 2:model.summaries$n,labels=unique(Dev.quants.ggplot.SBt$Model_name))+
  scale_y_continuous(limits=ylims.in[5:6])+
  theme(axis.text.x = element_text(angle=90,vjust=0.25))+
  labs(x = sensi_xlab,y = "Relative error")+
  annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
  geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
ggsave("Sensi_REplot_SBcurrent.png")
}

if(plot.figs[4]==1)
{
Dev.quants.ggplot.Dep<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[3])
ggplot(Dev.quants.ggplot.Dep,aes(Model_num_plot,RE))+
  geom_point(aes(shape=Metric),color=four.colors[3])+
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[3],ymax=CI_DQs_RE[3]),fill=NA,color=four.colors[3])+ 
  geom_hline(yintercept =c(TRP,LRP,0),lty=c(1,2,1),color=c("darkgreen","darkred","gray"))+
  scale_x_continuous(breaks = 2:model.summaries$n,labels=unique(Dev.quants.ggplot.Dep$Model_name))+
  scale_y_continuous(limits=ylims.in[7:8])+
  theme(axis.text.x = element_text(angle=90,vjust=0.25))+
  labs(x = sensi_xlab,y = "Relative error")+
  annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
  geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
ggsave("Sensi_REplot_status.png")
}

if(plot.figs[5]==1)
{
Dev.quants.ggplot.MSY<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[4])
ggplot(Dev.quants.ggplot.MSY,aes(Model_num_plot,RE))+
  geom_point(aes(shape=Metric),color=four.colors[4])+
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[4],ymax=CI_DQs_RE[4]),fill=NA,color=four.colors[4])+ 
  geom_hline(yintercept =0,lty=1,color="gray")+
  scale_x_continuous(breaks = 2:model.summaries$n,labels=unique(Dev.quants.ggplot.MSY$Model_name))+
  scale_y_continuous(limits=ylims.in[9:10])+
  theme(axis.text.x = element_text(angle=90,vjust=0.25))+
  labs(x = sensi_xlab,y = "Relative error")+
  annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
  geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
ggsave("Sensi_REplot_MSY.png")
}

if(plot.figs[6]==1)
{
Dev.quants.ggplot.FMSY<-subset(Dev.quants.ggplot,Metric == unique(Dev.quants.ggplot$Metric)[5])
ggplot(Dev.quants.ggplot.FMSY,aes(Model_num_plot,RE))+
  geom_point(aes(shape=Metric),color=four.colors[5])+
  geom_rect(aes(xmin=1,xmax=model.summaries$n+1,ymin=-CI_DQs_RE[5],ymax=CI_DQs_RE[5]),fill=NA,color=four.colors[5])+ 
  geom_hline(yintercept =0,lty=1,color="gray")+
  scale_x_continuous(breaks = 2:model.summaries$n,labels=unique(Dev.quants.ggplot.FMSY$Model_name))+
  scale_y_continuous(limits=ylims.in[11:12])+
  theme(axis.text.x = element_text(angle=90,vjust=0.25))+
  labs(x = sensi_xlab,y = "Relative error")+
  annotate("text",x=anno.x,y=anno.y,label=anno.lab)+
  geom_vline(xintercept =c(sensi.type.breaks),lty=lty.in)
ggsave("Sensi_REplot_FMSY.png")
}
}

