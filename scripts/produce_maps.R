require(raster)
require(sp)
require(RColorBrewer)
require(svMisc)
require(tidyverse)
downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"
outputDir <- "product"

proWG<-CRS("+proj=longlat +datum=WGS84")
##########################################################
# define a raster covering the grid. Set resolution of the raster here
##########################################################
r<-raster(ext=extent(-16,9,46,66),ncol=150,nrow=280,crs=proWG,vals=0)
##########################################################
# load a base raster with land
##########################################################
load("./data/derived_data/rs.Rdata")
lcol<-rgb(210/256,234/256,242/256)
##########################################################
#### load data
##########################################################
sbnsc<- read_delim("./data/derived_data/all2Data.csv",
                   col_types = "ccccccccTnnncccccccccccccccn",
                   delim=",")
trdi<-read.csv("./data/derived_data/allDatasets_selection.csv",stringsAsFactors = FALSE)
usedds<- trdi %>% filter (include) %>% dplyr::select(datasetid)
##########################################################
##### select few columns to work with
##########################################################
trec<- sbnsc %>% dplyr::select(eventDate=datecollected,
                        decimalLongitude=decimallongitude,
						            decimalLatitude=decimallatitude,
						            scientificName=scientificnameaccepted,
						            aphiaID=AphiaID,
						            datasetid=datasetid) %>%
                 mutate(datasetid=as.numeric(substr(datasetid,65,90))) %>%
                 filter(datasetid %in% usedds$datasetid)

##############################################################
# Define 'sampling events' as all records that share time and place, give
# ID numbers to all events (eventNummer), and store the eventNummer in each
# record of trec
##############################################################
events<- trec %>% dplyr::select(eventDate,decimalLongitude,decimalLatitude) %>% 
                  distinct() %>%
				          mutate(eventNummer=row_number())
trec <- trec %>% left_join(events,by=c('eventDate','decimalLongitude','decimalLatitude'))

########### work on datasets
#
#### check on completeness
#
nsp<-trec %>% group_by(datasetid) %>% 
              distinct(aphiaID)    %>%
              mutate(nspec=n())    %>%
              dplyr::select(datasetid,nspec) %>%
              distinct()
nev<-trec %>% group_by(datasetid)     %>% 
              distinct(eventNummer)    %>%
              mutate(nev=n())          %>%
              dplyr::select(datasetid,nev) %>%
              distinct()                    %>%
              left_join(nsp,by='datasetid')%>%
              left_join(trdi,by='datasetid')
#
plot(nev$nev,nev$nspec,log="xy",col=ifelse(nev$complete,"blue","red"),pch=19,
     xlab="number of events in dataset",ylab="number of species in dataset")
text(nev$nev*1.2,nev$nspec*(1+(runif(nrow(nev))-0.5)*0.4),nev$datasetid,cex=0.5)
# 
# #notes. BIS (599) and Voordelta (4662) rather poor in species for the effort. is OK
# #       similar 5701 Belgian coast and 1794 French coast
# #       In the end we only keep four incomplete datasets
# 
# 
# manage the incomplete datasets
#
trdi_ct<-trdi %>% filter (complete)
trdi_ic<-trdi %>% filter (!complete)
# make a species list for each incomplete dataset
ic_sp<-data.frame(datasetid=NULL,aphiaID=NULL)
for(i in 1:nrow(trdi_ic)){
  ds<-trdi_ic$datasetid[i]
  specs<-unique(trec$aphiaID[trec$datasetid==ds])
  ic_sp<-rbind(ic_sp,data.frame(datasetid=rep(ds,length(specs)),aphiaID=specs))
}

##############################################################
# find occurrence frequency of all species, and rank the species accordingly
#
spfr<- trec %>% 
  group_by(aphiaID,scientificName) %>%
  summarize(n_events=n()) %>%
	arrange(desc(n_events))
nsptoplot<-length(which(spfr$n_events>200))

############ end of the generic part. What follows is specific for the species #######################

spmin<-1
spmax<-nsptoplot

  
for(ss in spmin:spmax){
  spAphId<-spfr$aphiaID[ss]
  specname<-spfr$scientificName[ss]
  filpdf<-paste0("./data/output/maps_species_",spAphId,".pdf")
  filspe<-paste0("dats_species_",spAphId,".csv")
  pdf(filpdf,width=7,height=9)
  progress(value=ss,max.value=spmax,init=(ss=spmin))

    # from the list of incomplete datasets, check if they have our species. Only keep these, drop the others
	  tt_ds<- ic_sp %>% filter(aphiaID==spAphId) %>%
	                  distinct(datasetid) %>% 
	                  bind_rows(trdi_ct %>% dplyr::select(datasetid))
	     # The dataset to be used consists of all complete datasets, and all incomplete datasets that targeted our species
    spe<- trec %>% filter(datasetid %in% tt_ds$datasetid) %>%
	               group_by(eventNummer) %>%
				   summarize(pres_abs= as.numeric(any(aphiaID==spAphId)))  %>%
				   left_join(events,by='eventNummer')
    
    write_delim(spe,file.path(outputDir,filspe), delim = ",")
    
    coordinates(spe)<- ~decimalLongitude+decimalLatitude
    projection(spe)<-proWG
    r1<-rasterize(spe,r,field="pres_abs",fun=mean)
    #
    #plotting
    par(bg="lightblue")
    
    yor<-brewer.pal(7,"YlOrRd")
    plot(0, 0, type="n", ann=FALSE, axes=FALSE)
    par(new=TRUE)
    plot(r1,breaks=c(-0.01,0,0.2,0.4,0.6,0.8,1),col=yor,main=paste(specname,"all targeting datasets"))
    plot(rs,add=T,col=lcol,legend=FALSE)
    legend("bottomright",col=yor[1:6],pch=15,legend=c("0",">0-0.2",">0.2-0.4",">0.4-0.6",">0.6-0.8",">0.8-1"),
           bg=lcol)
    dev.off()
}
par(bg="white")



