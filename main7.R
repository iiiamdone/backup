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
setwd("~/Exercise7-starter")

set.seed(500)

# ++++++++++++++++++++++++++++++++++++ 1. SOME PREPARATION +++++++++++++++++++++++++++++++++++++
# Load data

data_URL <- "https://raw.githubusercontent.com/GeoScripting-WUR/AdvancedRasterAnalysis/gh-pages/data/Gewata.zip"
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

# modifying extents and projection 
ethiopia <- stack(list.files(path = './data', pattern = glob2rx('*B*.tif'), full.names = TRUE))
GADM <- st_transform(st_as_sf(raster::getData('GADM', country = 'ETH', level = 3, path = './data')), crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0" )
gwt <- GADM[GADM$NAME_3 == "Getawa", ]
lulc <- stack(list.files(path = './data', pattern = glob2rx('*lulc*.tif'), full.names = TRUE))

gwtUTM <- st_transform(st_as_sf(gwt), CRS(proj4string(lulc)))
gwtCrop <- crop(lulc, gwtUTM)
plot(gwtCrop, main = sprintf('cropp'))
gwtMask <- mask(lulc, gwtUTM)
plot(gwtMask, main = sprintf('mask'))


# validation data and reference map 
ValData <- mask(crop(lulc, gwtUTM), gwtUTM)
RefMap <- mask(crop(ethiopia, gwtUTM), gwtUTM)
ndvi <- overlay(RefMap$GewataB4, RefMap$GewataB3, fun = function(x,y){(x-y)/(x+y)})
plot(ValData,main = sprintf('Actual Landcover Gewata'))

# training data 
trainingPoly = readOGR("./data/TrainPolys.geojson")
trainingPoly@data$Class
str(trainingPoly@data$Class)
trainingPoly@data$Code <- as.numeric(trainingPoly@data$Class)
trainingPoly@data
plot(ndvi)
plot(trainingPoly, add = TRUE)


trainingPolys <- st_transform(st_as_sf(trainingPoly), CRS(proj4string(ndvi)))
# assign code values to raster cells, pick up polygons on referening map based on where they overlap 

# Define a colour scale for the classes (as above)
# corresponding to: cropland, forest, wetland
cols <- c("orange", "dark green", "light blue")

# make polygons with certain classes 
classes <- rasterize(trainingPolys, ndvi, field='Code')
plot(classes, col=cols, legend=FALSE)

## Add a customized legend
legend("topright", legend=c("cropland", "forest", "wetland"), fill=cols, bg="white")

# stacking all the layers for training/predicting together into one layer 
covs <- addLayer(RefMap, ndvi)
names(covs) <- names(covs) <- c("band1", "band2", "band3", "band4", "band5", "band7", "NDVI")
plot(covs)

# only select training data regarding polygons 
covmasked <- mask(covs, classes)
plot(covmasked)
names(classes) <- "training Ref"
trainingbrick <- addLayer(covmasked, classes) 
plot(trainingbrick)


valuetable <- getValues(trainingbrick)
valuetable <- na.omit(valuetable)
valuetable <- as.data.frame(valuetable)
head(valuetable, n=10)
tail(valuetable, n = 10)
names(valuetable)<- c("band1", "band2", "band3", "band4", "band5", "band7", "NDVI","class")
valuetable$class <- factor(valuetable$training.Ref, levels = c(1:3))
val_crop <- subset(valuetable, class == 1)
val_forest <- subset(valuetable, class == 2)
val_wetland <- subset(valuetable, class == 3)

## NDVI
par(mfrow = c(3, 1))
hist(val_crop$layer, main = "cropland", xlab = "NDVI", xlim = c(0, 1), ylim = c(0, 4000), col = "orange")
hist(val_forest$layer, main = "forest", xlab = "NDVI", xlim = c(0, 1), ylim = c(0, 4000), col = "dark green")
hist(val_wetland$layer, main = "wetland", xlab = "NDVI", xlim = c(0, 1), ylim = c(0, 4000), col = "light blue")

par(mfrow = c(1, 1))


# ++++++++++++++++++++++++++++ 4. random forest  ++++++++++++++++++++++++++++ 
modelRF <- randomForest(x=valuetable[ ,c(1:8)], y=valuetable$class,
                        importance = TRUE)
modelRF$confusion
# to make the confusion matrix more readable
colnames(modelRF$confusion) <- c("cropland", "forest", "wetland", "class.error")
rownames(modelRF$confusion) <- c("cropland", "forest", "wetland")
modelRF$confusion
varImpPlot(modelRF)


predLC <- predict(covs, model = modelRF, na.rm = TRUE)
cols <- c("orange", "dark green", "light blue")
plot(predLC, col=cols, legend=FALSE)
legend("bottomright", 
       legend=c("cropland", "forest", "wetland"), 
       fill=cols, bg="white")