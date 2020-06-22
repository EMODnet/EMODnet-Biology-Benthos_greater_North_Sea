# Benthos_greater_North_Sea

## Introduction

The large databases of EMODNET Biology only store confirmed presences of species. However, when mapping species distribution, it is also important where the species did not occur: there is at least as much information in absences as in presences. Inferring absences from presence-only databases is difficult and always involves some guesswork.
In this product we have used as much meta-information as possible to guide us in inferring absences. There is important meta-information at two different levels: the level of the data set, and the level of the species. 
Datasets can contain implicit information on absences when they have uniformly searched for the same species over a number of sample locations. Normally, if the species would have been present there, it would have been recorded. Other datasets, however, are not informative at all about absences. Typical examples are museum collections. The fact that a specimen is found at a particular place confirms that it lived there, but does not give information on any other species being present or absent in the same spot. A difficulty is that some datasets have searched for a restricted part of the total community, e.g. only sampled shellfish but no worms. In this case, absence of a shellfish species is relevant, but absence of a worm is not. The dataset can only be used to infer absence for the species it has targeted. Here we implicitly assume that a dataset inventoring the endomacrobenthos, is targeting all species belonging to this functional group. Usually, the distinction can be made on the basis of the metadata. It is also helpful to plot the total number of species versus the total number of samples. Incomplete datasets have far less species than expected for their size, compared to 'complete' datasets.
At the species level, taxonomic databases such as WoRMS give information on the functional group the species belongs to. This information is present for many species, but it is incomplete. However, we can use it in a step to select the most useful datasets. We could use it to restrict the species to be used in mapping, but since the data are incomplete that would cause some loss of interesting information.

## General procedure in preparing the data product

The retrieval of data goes in three steps.
In the first step, functional group information is used to harvest potentially interesting datasets. A query is performed for data on species known to be benthic (in WoRMS) and to occur in a number of different sea regions. This yields a large dataset with benthic data, but many of these data come from datasets that are not useful for our purpose. As an example, planktonic datasets contain many benthic animals, because larvae of benthic animals occur in the zooplankton (the so-called meroplankton). We cannot use the plankton datasets to infer anything about absence of benthos in the sea floor.
From the dataset resulting from step 1 we harvest all potentially interesting datasets, that contain at least one benthic animal in the region of interest. We subsequently use the imis database with meta-information on the datasets, to list the meta-data of all these datasets. On that basis we perform the (manual) selection of datasets to be used. We also qualify the datasets as either 'complete' or 'incomplete'.
In the next step, we download the part of all these useful datasets that occur in the region of interest. For practical reasons this region is subdivided in many subregions - in that way the downloaded files are not too big and there is less risk of interruptions of the process. After download, all these files are recombined into one big datafile.
In the final step, we define 'sampling events' that share time and place. We consider such events as one sample. For the incomplete datasets, we inventory what species they have targeted.
Finally, for every species we determine whether or not it was present in all sampling events of all relevant datasets. This presence/absence information is written to the output file, together with the spatial location and the sampling date. We then rasterize this information and show it in a map per species. The intention is to use this information to produce interpolated maps covering also the non-sampled space.

## Directory structure

```
Benthos_greater_North_Sea/
├── analysis
├── data/
│   ├── derived_data/
│   └── raw_data/
├── docs/
├── product/
└── scripts/
```

* **analysis** - Markdown notebook with the general workflow used in this product
* **data** - Raw and derived data. Note that due to the data size, these directories do not contain the actual mass of data of the project. The directories are made to store data when the project is running. There are a few ancillary files in derived_data, needed for running the download and producing maps
* **docs** - Rendered report of the Markdown document
* **product** - Output product files. A pdf file with maps of the species distributions, and a binary Rdata file with the species presences by event, as well as the characteristics of the events (date and place).
* **scripts** - The code used for the project. The Markdown document sources these scripts, without actually reproducing them

## Data series

This product is based on the compilation of a large number of data sets. Details of candidate datasets and datasets actually used are in the code and in the ancillary .csv files. The best summary is given in the file ./data/derived_data/allDatasets_selection.csv. It lists dataset ids, titles, abstracts, as well as fields describing whether the data set has been included and whether it is 'complete' in the sense of having sampled the entire macro-endobenthic community.
The wfs calls can also be found in the code.

## Data product

The products are of two different kinds.

![example product Lanice conchilega](https://github.com/pmjherman/Benthos_greater_North_Sea/blob/master/maps_species_131495_1.png)

Per species the presence or absence in each of the sampling events is recorded as a Boolean variable. Output is restricted to species that have been found more than 200 times in the entire dataset, but this can be changed in the code. This file is to be used as a basis for the production of interpolation maps, but can also be used as a basis for clustering and descriptive analyses.

Per species, the presence/absence data are also rasterized in a relatively fine raster. For each raster cell, the proportion of observations with presence of the species is calculated. The map shows these proportions (between 0 and 1). A pdf file with these maps is included in the directory "product"


## More information:


### Citation and download link

This product should be cited as:

Herman, P.M.J., Stolte, W., van der Heijden, L. 2020. Summary presence/absence maps of macro-endobenthos in the greater North Sea, based on nearly 100,000 samples from 65 assembled monitoring data sets. EMODNET Biology data product.

Available to download in:

{{link_download}}

### Authors

Peter M.J. Herman, Willem Stolte, Luuk van der Heijden
