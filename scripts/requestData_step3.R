require(sf)
require(tidyverse)
downloadDir <- "data/raw_data"
dataDir <- "data/derived_data"

filelist <- list.files("data/raw_data/byDataset")
all2Data <- lapply(filelist, function(x) 
  read_delim(file.path("data", "raw_data/byDataset", x), 
             delim = ",", 
             col_types = "ccccccTnnnccccccccccccccc"
  )
) %>%
  set_names(filelist) %>%
  bind_rows(.id = "fileID") %>%
  separate(fileID, c("mrgid", "datasetID"), "_") %>%
  mutate(mrgid = sub("[[:alpha:]]+", "", mrgid)) %>%
  mutate(datasetID = sub("[[:alpha:]]+", "", datasetID))
# mutate(mrgid = sub("region", "", mrgid))

all2Data<- all2Data %>%
  mutate(AphiaID=as.numeric(substr(aphiaidaccepted,52,65)))%>%
  filter(!is.na(AphiaID)) %>%
  filter(!is.na(decimallongitude)) %>%
  filter(!is.na(decimallatitude)) %>%
  filter(!is.na(datecollected))

write_delim(all2Data, file.path(dataDir, "all2Data.csv"), delim = ",")
