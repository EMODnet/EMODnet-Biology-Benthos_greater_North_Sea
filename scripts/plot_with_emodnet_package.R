require(raster)
require(sp)
require(tidyverse)
library('rnaturalearth')
library(magick)
library(rgeos)
require(svMisc)
library(EMODnetBiologyMaps)
require(rgdal)

downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"
mapsDir <- "product/maps"
rasterDir <- "product/species_rasters"
plotsDir <- "product/species_plots"

### correct the EMODnetBiologyMaps package by running a slightly modified version
source("scripts/emodnet_map_plot_2.R")

#### load specieslist
spfr<-read_delim(file.path(mapsDir,"specieslist.csv"),delim=",")
nsptoplot<-length(which(spfr$n_events>200))
spmin<-1
spmax<-nsptoplot
#########################################################
for(ss in spmin:spmax){
  progress(value=ss,max.value=spmax,init=(ss=spmin))
  spAphId<-spfr$aphiaID[ss]
  specname<-spfr$scientificName[ss]
  rasterfil <- file.path(rasterDir, 
     paste0(sprintf("%04d",ss), "_",spAphId, "_",gsub(" ", "-", specname),".tif"))
  r1<-raster(rasterfil)  

  legend="P(pres)"
  # Plot the grid
  
  ec<-emodnet_colors()
  plot_grid <- emodnet_map_plot_2(data=r1,title=specname,subtitle=paste0('AphiaID ', spAphId),
                                  zoom=TRUE,seaColor=ec$darkgrey,landColor=ec$lightgrey,legend=legend)
  filnam<-file.path(plotsDir, 
                    paste0(sprintf("%04d",ss), "_",spAphId, "_",gsub(" ", "-", specname),".png"))
  
  emodnet_map_logo(plot_grid,path=filnam,width=120,height=160,dpi=300,units="mm",offset="+0+0")
  
}

