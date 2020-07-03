require(sf)
require(tidyverse)
downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"

# read geographic layers for plotting
layerurl <- paste0("http://geo.vliz.be/geoserver/MarineRegions/ows?service=WFS&version=1.0.0&",
                   "request=GetFeature&typeName=MarineRegions:eez_iho_union_v2&",
                   "outputFormat=application/json")
regions <- sf::st_read(layerurl)

# read selected geographic layers for downloading
roi <- read_delim("data/derived_data/regions.csv", delim = ",")

# check by plotting
regions %>% filter(mrgid %in% roi$mrgid) %>%
  ggplot() +
  geom_sf(fill = "blue", color = "white") +
  geom_sf_text(aes(label = mrgid), size = 2, color = "white") +
  theme(axis.title = element_blank(),
        axis.text = element_blank(),
        axis.ticks = element_blank())
ggsave("data/derived_data/regionsOfInterest.png", width = 3, height =  4, )
#== download data by geographic location and trait =====================================
beginDate<- "1900-01-01"
endDate <- "2020-05-31"
attributeID1 <- "benthos"
attributeID2 <- NULL
attributeID3 <- NULL
# Full occurrence (selected columns)
for(ii in 1:length(roi$mrgid)){
  mrgid <- roi$mrgid[ii]
  print(paste("downloading data for", roi$marregion[ii]))
  downloadURL <- paste0("http://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0&",
                        "request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&",
                        "viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid, 
                        "%5D%29%29+AND+%28%28observationdate+BETWEEN+%27",beginDate,"%27+AND+%27",endDate,
                        "%27+%29%29+AND+aphiaid+IN+%28+SELECT+aphiaid+FROM+eurobis.taxa_attributes+WHERE+",
                        "selectid+IN+%28%27", attributeID1,"%27%5C%2C%27",attributeID2,
                        "%27%29%29%3Bcontext%3A0100&propertyName=datasetid%2Cdatecollected%2Cdecimallatitude",
                        "%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2Cscientificname%2Caphiaid%2C",
                        "scientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2Coccurrenceid%2C",
                        "scientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass%2Corder%2C",
                        "family%2Cgenus%2Csubgenus%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&outputFormat=csv")
  filename = paste0("region", roi$mrgid[ii], ".csv")
  data <- read_csv(downloadURL) 
  write_delim(data, file.path(downloadDir, "byTrait", filename), delim = ";")
}
filelist <- list.files("data/raw_data/byTrait")
allDataExtra <- lapply(filelist, function(x) 
  read_delim(file.path("data", "raw_data/byTrait", x), 
             delim = ";", 
             col_types = "ccccccTnnlccccccccccccccc"))  %>%
  set_names(sub(".csv", "", filelist))                  %>%
  bind_rows(.id = "mrgid")                              %>%
  mutate(mrgid = sub("region", "", mrgid))
#write_delim(allDataExtra, file.path(dataDir, "allDataExtra.csv"), delim = ";")

#=== from downloaded data ===========================
#
#allDataExtra <- read_delim(file.path(dataDir, "allDataExtra.csv"), delim = ";")
datasetidsoi <- allDataExtra %>% distinct(datasetid) %>% 
  mutate(datasetid = sub('http://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=', 
                         "", datasetid, fixed = T))
#==== retrieve data by dataset ==============
#
source("read_dasid_features.R")
all_info <- data.frame()
for (i in datasetidsoi$datasetid){
  dataset_info <- fdr2(i)
  all_info <- rbind(all_info, dataset_info)
}
names(all_info)[1]<-"datasetid"
write.csv(all_info,file="./data/derived_data/allDatasets.csv",row.names = F)
# Note
# this step is followed by manual inspection of data sets, and selection
# results in file "./data/derived_data/allDatasets_selection.csv"
