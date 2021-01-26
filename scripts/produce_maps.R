require(raster)
require(sp)
require(RColorBrewer)
require(svMisc)
require(tidyverse)
library(ggplot2)
library('rnaturalearth')
library(magick)
library(rgeos)

downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"
mapsDir <- "product/maps"
rasterDir <- "product/species_rasters"
plotsDir <- "product/species_plots"
proWG<-CRS("+proj=longlat +datum=WGS84")
##########################################################
# define a raster covering the grid. Set resolution of the raster here
##########################################################
r<-raster(ext=extent(-16,9,46,66),ncol=150,nrow=280,crs=proWG,vals=0)
##########################################################
# load some information needed for the maps
##########################################################
# Show countries
world <- ne_countries(scale = "medium", returnclass = "sf")
# EMODnet colors
emodnetColor <- list(
  # First palette
  blue = "#0A71B4",
  yellow = "#F8B334",
  darkgrey = "#333333",
  # Secondary palette,
  darkblue = "#012E58",
  lightblue = "#61AADF",
  white = "#FFFFFF",
  lightgrey = "#F9F9F9"
)
# EMODnet logo
logo_raw <- image_read("https://www.emodnet-biology.eu/sites/emodnet-biology.eu/files/public/logos/logo-footer.png") 
logo <- logo_raw %>% image_scale("150")
#
##########################################################
#### load data
##########################################################
sbnsc<- read_delim("./data/derived_data/all2Data.csv",
                   col_types = "ccccccccTnnncccccccccccccccn",
                   delim=",")
trdi<-read.csv("./data/derived_data/allDatasets_selection.csv",
               stringsAsFactors = FALSE)
usedds<- trdi %>% filter (include) %>% dplyr::select(datasetid)
splst<-read_delim(file.path(dataDir,"sp2use.csv"),
                  col_types = "dccccccclllllllllllllllll",
                  delim=",")
##########################################################
##### select few columns to work with
##### filter to only the used datasets
##### and filter to true benthic species only
##########################################################
trec<- sbnsc %>% dplyr::select(eventDate=datecollected,
                               decimalLongitude=decimallongitude,
                               decimalLatitude=decimallatitude,
                               scientificName=scientificnameaccepted,
                               aphiaID=AphiaID,
                               datasetid=datasetid) %>%
  mutate(datasetid=as.numeric(substr(datasetid,65,90))) %>%
  filter(datasetid %in% usedds$datasetid)
trec<- trec %>%  filter(aphiaID %in% splst$AphiaID)
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
############ end of the generic part. What follows is a loop over the species ##
spmin<-1
spmax<-nsptoplot

for(ss in spmin:spmax){
  spAphId<-spfr$aphiaID[ss]
  specname<-spfr$scientificName[ss]
  spcolumn<-paste0("pa",spAphId)
  progress(value=ss,max.value=spmax,init=(ss=spmin))
  # from the list of incomplete datasets, check if they have our species. 
  # Only keep these, drop the others
  tt_ds<- ic_sp                      %>% 
    filter(aphiaID==spAphId) %>%
    distinct(datasetid)      %>% 
    bind_rows(trdi_ct        %>% 
                dplyr::select(datasetid))
  # The dataset to be used consists of all complete datasets, and all 
  # incomplete datasets that targeted our species
  spe<- trec                                                      %>% 
    filter(datasetid %in% tt_ds$datasetid)                  %>%
    group_by(eventNummer)                                   %>%
    summarize(pres_abs= as.numeric(any(aphiaID==spAphId)),.groups = 'drop')  %>%
    left_join(events,by='eventNummer') 
  spesh <- spe                               %>% 
    mutate (spcolumn=(pres_abs==1)) %>% 
    dplyr::select (- pres_abs)
  names(spesh)[5]<-spcolumn
  spesh <- spesh %>% dplyr::select('eventNummer',spcolumn)
  if(ss==spmin) allspe <- spesh else {
    allspe <- allspe %>% full_join(spesh,by='eventNummer')
  }
  coordinates(spe)<- ~decimalLongitude+decimalLatitude
  projection(spe)<-proWG
  r1<-rasterize(spe,r,field="pres_abs",fun=mean)
  # Export rasters as tif
  raster::writeRaster(
    r1, 
    file.path(
      rasterDir, paste0(
        sprintf("%04d",ss), "_",
        spAphId, "_",
        gsub(" ", "-", specname),
        ".tif"
      )
    ),
    overwrite=TRUE
  )
  #
  # Transform raster to vector
  grid <- sf::st_as_sf(raster::rasterToPolygons(r1))
  grid_bbox <- sf::st_bbox(sf::st_transform(grid, 3035))
  
  # Plot the grid
  plot_grid <- ggplot() +
    geom_sf(data = world, 
            fill = emodnetColor$darkgrey, 
            color = emodnetColor$lightgrey, 
            size = 0.1) +
    geom_sf(data = grid, aes(fill = layer), size = 0.05) +
    coord_sf(crs = 3035, xlim = c(grid_bbox$xmin, grid_bbox$xmax), ylim = c(grid_bbox$ymin, grid_bbox$ymax)) +
    scale_fill_viridis_c(alpha = 1, begin = 1, end = 0, direction = -1) +
    ggtitle(specname,
            subtitle = paste0('AphiaID ', spAphId)) +
    theme(
      panel.background = element_rect(fill = emodnetColor$lightgrey),
      plot.title = element_text(color= emodnetColor$darkgrey, size = 14, face="bold.italic", hjust = 0.5),
      plot.subtitle = element_text(color= emodnetColor$darkgrey, face="bold", size=10, hjust = 0.5)
    )
  
  # Inspect plot
  plot_grid
  
  # Save plot
  filnam<-file.path(plotsDir, 
                    paste0(sprintf("%04d",ss), "_",spAphId, "_",gsub(" ", "-", specname),".png"))
  ggsave(filename = filnam,width = 198.4375, height = 121.70833333, dpi = 300, units = "mm")
  
  # Add emodnet logo
  plot <- image_read(filnam)
  final_plot <- image_composite(plot, logo, gravity = "northeast", offset = "+680+220")
  image_write(final_plot, filnam)
}

evs<-tibble(eventNummer=allspe$eventNummer)
evs<- evs %>% left_join(events,by='eventNummer')
spe<- cbind(evs,allspe[,2:ncol(allspe)])
save(spe,file=file.path(mapsDir,"spe.Rdata"))
write_delim(spfr,path=file.path(mapsDir,"specieslist.csv"),delim=",")

for(i in 5:ncol(spe)) spe[,i]<-as.numeric(spe[,i])
write_delim(spe,path=file.path(mapsDir,"spe.csv"),delim=",")
