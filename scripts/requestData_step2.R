require(sf)
require(tidyverse)
downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"
# read selected geographic layers for downloading
roi <- read_delim("data/derived_data/regions.csv", delim = ",")
getDatasets <- read_csv("./data/derived_data/allDatasets_selection.csv")
getDatasets <- getDatasets %>% filter(include)
for(ii in 1:length(roi$mrgid)){
  for(jj in 1:length(getDatasets$datasetid)){
    datasetid <- getDatasets$datasetid[jj]
    mrgid <- roi$mrgid[ii]
    print(paste("downloading data for ", roi$marregion[ii], "and dataset nr: ", datasetid))
    downloadURL <- paste0("https://geo.vliz.be/geoserver/wfs/ows?service=WFS&version=1.1.0",
                          "&request=GetFeature&typeName=Dataportal%3Aeurobis-obisenv_full&resultType=results&",
                          "viewParams=where%3A%28%28up.geoobjectsids+%26%26+ARRAY%5B", mrgid,
                          "%5D%29%29+AND+datasetid+IN+(",datasetid,");context%3A0100&propertyName=datasetid%2C",
                          "datecollected%2Cdecimallatitude%2Cdecimallongitude%2Ccoordinateuncertaintyinmeters%2C",
                          "scientificname%2Caphiaid%2Cscientificnameaccepted%2Cinstitutioncode%2Ccollectioncode%2C",
                          "occurrenceid%2Cscientificnameauthorship%2Cscientificnameid%2Ckingdom%2Cphylum%2Cclass",
                          "%2Corder%2Cfamily%2Cgenus%2Csubgenus%2Caphiaidaccepted%2Cbasisofrecord%2Ceventid&",
                          "outputFormat=csv")
    data <- read_csv(downloadURL, col_types = "ccccccTnnnccccccccccccccc") 
    filename = paste0("region", roi$mrgid[ii], "_datasetid", datasetid,  ".csv")
    if(nrow(data) != 0){
      write_delim(data, file.path(downloadDir, "byDataset", filename), delim = ",")
    }
  }
}
