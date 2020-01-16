# Importing and/or installing packages
if (!require('raster')) install.packages('raster')
if (!require('sf')) install.packages('sf')
if (!require('rgdal')) install.packages('rgdal')
if (!require('sp')) install.packages('sp')
if (!require('rgeos')) install.packages('rgeos')
if (!require('randomForest')) install.packages('randomForest')
if (!require('geojsonR')) install.packages('geojsonR')

library(raster)
library(sf)
library(rgdal)
library(sp)
library(rgeos)
library(randomForest)
library(geojsonR)

# ++++++++++++++++++++++++++++++++  1. prepare data +++++++++++++++++++++++++++++++++++++++++
set.seed(500)
data_URL <- "https://www.dropbox.com/s/cv1de2fmy855wpy/data.zip?dl=1"
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

files <- list.files('./data', pattern = ".rda$", full.names = TRUE)
for (i in 1:length(files)){
  load(files[i])
}
 
gewata <- stack(GewataBand1, GewataBand2, GewataBand3, GewataBand4, GewataBand5, GewataBand7)
ndvi <- overlay(gewata$band4, gewata$band3, fun = function(x,y){(x-y)/(x+y)})

load('./data/trainPnts')

trainingPnts <- st_transform(st_as_sf(trainingPnts), CRS(proj4string(gewata)))
classPoly <- st_transform(st_as_sf(classPoly),CRS(proj4string(gewata)))

classes <- rasterize(trainingPnts, gewata, field='VCF')
classesVCT <- extract(gewata, trainingPnts)
