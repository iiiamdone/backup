#Hallo

#Load library
library(rgdal)
library(raster)
setwd("~/Documents/Exercise4-starter")
#Source external functions
source("./R/detectFires.R")
source("./R/calculateNBR.R")

#Create data and output folders and download data from URL
data_URL <- "https://www.dropbox.com/sh/3lz5vylc7tzpiup/AAB3HCFHdJFa8lV_PMRlV5Wda?dl=1"
data_folder <- "./data"

if (!dir.exists(data_folder)){
  dir.create(data_folder)}

if (!dir.exists('output')) {
  dir.create('output')
}

if (!file.exists('./data/data.zip')) {
  download.file(url = data_URL, destfile = './data/data.zip', method = 'auto')
  unzip('./data/data.zip', exdir = './data')
}


#Load data
Landsat_images <- list.files(data_folder, pattern = glob2rx('L*'), full.names=TRUE)

# pre processing 

# ndvi calculation 

# image differencing 




#Load library
library(rgdal)
library(raster)
setwd("~/Documents/Exercise4-starter")
#Source external functions
source("./R/detectFires.R")
source("./R/calculateNBR.R")

#Create data and output folders and download data from URL
data_URL <- "https://www.dropbox.com/sh/3lz5vylc7tzpiup/AAB3HCFHdJFa8lV_PMRlV5Wda?dl=1"
data_folder <- "./data"

if (!dir.exists(data_folder)){
  dir.create(data_folder)}

if (!dir.exists('output')) {
  dir.create('output')
}

if (!file.exists('./data/data.zip')) {
  download.file(url = data_URL, destfile = './data/data.zip', method = 'auto')
  unzip('./data/data.zip', exdir = './data')
}


#Load data
Landsat_images <- list.files(data_folder, pattern = glob2rx('L*'), full.names=TRUE)

# pre processing 

# ndvi calculation 

# image differencing 




































