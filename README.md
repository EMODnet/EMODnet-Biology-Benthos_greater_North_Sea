# Benthos_greater_North_Sea

## Introduction

The large databases of EMODNET Biology only store confirmed presences of species. However, when mapping species distribution, it is also important where the species did not occur: there is at least as much information in absences as in presences. Inferring absences from presence-only databases is difficult and always involves some guesswork.
In this product we have used as much meta-information as possible to guide us in inferring absences. There is important meta-information at two different levels: the level of the data set, and the level of the species. 
Datasets can contain implicit information on absences when they have uniformly searched for the same species over a number of sample locations. Normally, if the species would have been present there, it would have been recorded. Other datasets, however, are not informative at all about absences. Typical examples are museum collections. The fact that a specimen is found at a particular place confirms that it lived there, but does not give information on any other species being present or absent in the same spot. A difficulty is that some datasets have searched for a restricted part of the total community, e.g. only sampled shellfish but no worms. In this case, absence of a shellfish species is relevant, but absence of a worm is not. The dataset can only be used to infer absence for the species it has targeted. Here we implicitly assume that a dataset inventoring the endomacrobenthos, is targeting all species belonging to this functional group. Usually, the distinction can be made on the basis of the metadata. It is also helpful to plot the total number of species versus the total number of samples. Incomplete datasets have far less species than expected for their size, compared to 'complete' datasets.
At the species level, taxonomic registers such as WoRMS (WoRMS Editorial Board, 2021) give information on the functional group the species belongs to. This information is present for many species, but it is most likely incomplete. The size of the register excludes any easy test of completeness of the traits. However, even if incomplete, the register trait data can be used to select the most useful datasets. If one were to use an incomplete register directly to restrict the species to be used in mapping, that would cause loss of interesting information. Therefore the present workflow contains additional steps using the identified promising datasets rather than the species list based on the register’s traits.

## General procedure in preparing the data product

The retrieval of data was done in three steps. Firstly, functional group information was used to harvest potentially interesting datasets. A query was performed for data on species known to be benthic (in WoRMS) and to occur in a number of different sea regions. This yielded a large dataset with benthic data, but many of these data came from datasets that were not useful for our purpose, as an example, planktonic datasets contain many benthic animals, because larvae of benthic animals occur in the zooplankton (the so called meroplankton). The plankton datasets cannot be used to infer about absence of benthos in the seafloor. From the inventory resulting from step 1, all potentially interesting datasets, that contain at least one benthic animal in the region of interest, were harvested. The IMIS database, with meta-information on the datasets, was subsequently used to list the metadata of all these datasets. On that basis a (manual) selection of datasets to be used was performed and quantified as either 'complete' or 'incomplete'. 
Secondly, all the useful datasets that occur in the region of interest were downloaded. For practical reasons this region was subdivided in smaller portions – in that way the downloaded files were not too big and decreases the risk of interruptions of the process. After downloading, all the files were recombined into one big data file.
Thirdly, 'sampling events' that share time and place were defined and these were considered as one sample. For the incomplete datasets, and inventory of the species they have targeted was created. Finally, for every species it was determined whether or not it was present in all sampling events of all relevant datasets. This presence/absence information was written to the output file, together with the spatial location and the sampling date. 

## Directory structure

```
Benthos_greater_North_Sea/
├── analysis
├── data/
│   ├── derived_data/
│   └── raw_data/
│         ├── byDataset/
│         └── byTrait/
├── docs/
└── product/
    ├── maps/ 
    ├── species_plots/ 
    └── species_rasters/

```

* **analysis** - Markdown notebook with the general workflow used in this product, All R code used during the analysis is incorporated into the Markdown notebook. For consistency reasons, the code is not replicated as independent scripts. If needed, code chunks can easily be extracted from the notebook.
* **data** - Raw and derived data. Note that due to the data size, these directories do not contain the actual mass of data of the project. The directories are made to store data when the project is running. There are a few ancillary files in derived_data, needed for running the download and producing maps
* **docs** - Rendered report of the Markdown document
* **product** - Output product files. The subdirectory maps contains general files with the results of the analysis for all species found 200 times or more (note that for the rarer species no output is produced, although this can easily be done using the provided code). There are three files. spe.csv is a very large csv file recording for each species and each sampling event whether the species was present (1), absent (0) or not looked for (NA). This information is also stored in the binary file spe.Rdata that can only be read from R. The names and some attributes of the species in spe.csv are stored in specieslist.csv. For each species, a raster is made with fraction presences, and stored as a geotiff file in the subdirectory species_rasters. The rasters are plotted and stored per species in the subdirectory species_plots.

## Data series

This product is based on the compilation of a large number of data sets. Details of candidate datasets and datasets actually used are in the code and in the ancillary .csv files. The best summary is given in the file ./data/derived_data/allDatasets_selection.csv. It lists dataset ids, titles, abstracts, as well as fields describing whether the data set has been included and whether it is 'complete' in the sense of having sampled the entire macro-endobenthic community.
The wfs calls can also be found in the code.

## Data product

![example product Lanice conchilega](https://github.com/pmjherman/Benthos_greater_North_Sea/blob/master/0007_131495_Lanice-conchilega.png)

Per species the presence or absence in each of the sampling events is recorded as a Boolean variable. Output is restricted to species that have been found more than 200 times in the entire dataset, but this can be changed in the code. This file is to be used as a basis for the production of interpolation maps, but can also be used as a basis for clustering and descriptive analyses. The file is saved as an R binary file and as a .csv file.

Per species, the presence/absence data are also rasterized in a relatively fine raster. For each raster cell, the proportion of observations with presence of the species is calculated. The map shows these proportions (between 0 and 1). 
Currently, there are maps available for a total of 1095 taxa. These encompass all taxa that have been observed more than 200 times in the total dataset of over 90,000 samples. There are approximately 73,000 samples in ‘complete’ datasets, targeting the whole community. The remainder are ‘incomplete’ datasets that only recorded the presence of a limited number of species.
Distinction between ‘complete’ and ‘incomplete’ datasets was made based on the description of the datasets in the meta-information, and checked using the relation between sampling effort and number of species found. The latter showed a good overall correspondence for the ‘complete’ datasets, although some datasets focusing on estuarine areas had a relatively modest number of taxa found for a relatively large sampling effort.
From the large number (approximately 6500) of taxa found in these datasets, most are classified in WoRMS as ‘Benthos’. However, over 1000 species were not, even though they were all found in datasets targeting benthos. This is partly explained because benthos datasets also find small fish, occasional zooplankton and other animals that are not typically benthic but that are often reported in the results. Another reason is that it concerns high-level taxa that count both benthic and non-benthic species in the taxon. Lastly, however, it is due to the fact that the species databases are incomplete. The list of non-benthic taxa found in benthic datasets was transferred to the WoRMS editors, in order to help with updating the traits database. This operation was not at all automatic, as it was clear that the list contained a large number of taxa that could not be termed ‘benthic’.

The maps were created using the [EMODnetBiologyMaps](https://github.com/EMODnet/EMODnetBiologyMaps) R package.

## More information:

### References

Salvador Fernández-Bejarano, Lennert Schepers (2020). EMODnetBiologyMaps: Creates ggplot maps with the style of EMODnet. R package version 0.0.1.0. Integrated data products created under the European Marine Observation Data Network (EMODnet) Biology project (EASME/EMFF/2017/1.3.1.2/02/SI2.789013), funded by the by the European Union under Regulation (EU) No 508/2014 of the European Parliament and of the Council of 15 May 2014 on the European Maritime and Fisheries Fund, https://github.com/EMODnet/EMODnetBiologyMaps

WoRMS Editorial Board (2021). World Register of Marine Species. Available from https://www.marinespecies.org at VLIZ. Accessed 2021-04-09. doi:10.14284/170

### Citation and download link

This product should be cited as:

Herman, P.M.J., Stolte, W., van der Heijden, L. 2020. Summary presence/absence maps of macro-endobenthos in the greater North Sea, based on nearly 100,000 samples from 65 assembled monitoring data sets. EMODNET Biology data product.

Available to download in:

https://www.emodnet-biology.eu/data-catalog?module=dataset&dasid=6617

### Authors

Peter M.J. Herman, Willem Stolte, Luuk van der Heijden
