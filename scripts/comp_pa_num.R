require(raster)
require(sp)
require(RColorBrewer)
require(svMisc)
require(tidyverse)
require(reshape2)
downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"
mapsDir <- "product/maps"
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

######### read in stored data
load(file.path(mapsDir,"spe.Rdata"))
splst<-read_delim(file.path(mapsDir,"specieslist.csv"),delim=",")
names(spe)[5:ncol(spe)]<-splst$scientificName[1:(ncol(spe)-4)]
spe<-spe %>% mutate_at(5:ncol(spe),as.numeric)
# read in numerical density data
numdts<-read_delim(file.path(dataDir,"df_ab.csv"),delim=",")
evts<-numdts %>% select(data,sta,x,y) %>% distinct()


pdf(file.path(mapsDir,"compPAdens.pdf"),width=8,height=5.5)
# select at random 100 species among the first 500
spslct<-unique(floor(runif(100)*500)+1)
par(mfrow=c(1,2))
for(i in spslct){
  spp<-cbind(spe[,1:4],spe[,i+4])
  spp<-spp[!is.na(spp[,5]),]
  specname<-names(spe)[i+4]
  names(spp)[5]<-"pres_abs"
  coordinates(spp)<- ~decimalLongitude+decimalLatitude
  projection(spp)<-proWG
  r1<-rasterize(spp,r,field="pres_abs",fun=mean)
  #
  #plotting
  par(bg="lightblue")
  yor<-brewer.pal(7,"YlOrRd")
  plot(0, 0, type="n", ann=FALSE, axes=FALSE)
  par(new=TRUE)
  plot(r1,breaks=c(-0.01,0,0.2,0.4,0.6,0.8,1),
       col=yor,
       main=paste(specname,"P/A"),
       legend=FALSE)
  plot(rs,add=T,col=lcol,legend=FALSE)
  legend("bottomright",col=yor[1:6],pch=15,
         legend=c("0",">0-0.2",">0.2-0.4",">0.4-0.6",">0.6-0.8",">0.8-1"),
         bg=lcol,cex=0.6)
  ######## plot the numerical data of the same species ##############
  spp<- numdts %>% filter(tx==specname)
  spp<- spp %>% full_join(evts,by=c("data","sta","x","y")) %>%
    mutate(dens=ifelse(is.na(dens),0,dens))
  if(nrow(spp)>0){
    coordinates(spp)<- ~x+y
    projection(spp)<-proWG
    r1<-rasterize(spp,r,field="dens",fun=mean)
    md<-max(log(values(r1)+1),na.rm=T)
    r1<-log(r1+1)/md
    #
    #plotting
    par(bg="lightblue")
    yor<-brewer.pal(7,"YlOrRd")
    plot(0, 0, type="n", ann=FALSE, axes=FALSE)
    par(new=TRUE)
    plot(r1,breaks=c(-0.01,0,0.2,0.4,0.6,0.8,1),
         col=yor,
         main=paste(specname,"density"),
         legend=FALSE)
    plot(rs,add=T,col=lcol,legend=FALSE)
    legend("bottomright",col=yor[1:6],pch=15,
           legend=c("0",paste0(">0-",floor(exp(0.2*md)-1)),
                    paste0(">",floor(exp(0.2*md)-1),"-",floor(exp(0.4*md)-1)),
                    paste0(">",floor(exp(0.4*md)-1),"-",floor(exp(0.6*md)-1)),
                    paste0(">",floor(exp(0.6*md)-1),"-",floor(exp(0.8*md)-1)),
                    paste0(">",floor(exp(0.8*md)-1),"-",floor(exp(1.0*md)-1))),
           bg=lcol,cex=0.6)
  }else{
    plot(0, 0, type="n", ann=FALSE, axes=FALSE)
    par(new=TRUE)
    
  }
  
}
dev.off()