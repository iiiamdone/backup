# RasterLayer = one file, one band
# RasterBrick = one file, multiple bands. Commonly used with RGB images
# RasterStack = multiple files, multiple bands (Landsat GeoTIFFs)

install.packages('rgdal')
install.packages('raster')
library(raster)
library(rgdal)

# 1. preprocessing 
setwd("~/Documents/Assignment1-starter")
#Source external functions
source("./calculateNDVI.R")

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
  rm('.data/data.zip')
}

if (!file.exists('./data/L5')) {
  dir.create('./data/L5')
}

if (!file.exists('./data/L8')) {
  dir.create('./data/L8')
}

TarFiles <- list.files(data_folder, pattern = glob2rx('*.tar.gz'), full.names=TRUE)
for (i in (TarFiles)){
  untar(TarFiles[1],exdir='./data/L8')
  untar(TarFiles[2],exdir='./data/L5')
}

# Load data
LC8 = stack(list.files(path = './data/L8', pattern = glob2rx('*band*.tif'), full.names = TRUE))
LT5 = stack(list.files(path = './data/L5', pattern = glob2rx('*band*.tif'), full.names = TRUE))

# Landsat8_images <- stack(list.files(path = './data/L8',pattern = glob2rx('*.tif'),full.names = TRUE)) # multiple bands 
# Landsat5_images <- stack(list.files(path = './data/L5',pattern = glob2rx('*.tif'),full.names = TRUE))

#Visualizing the input data
png(filename="output/LC81970242014109-SC20141230042441.png", width=800, height=500)
plotRGB(LC8, r = 4, g = 2, b = 2, stretch = "lin")
dev.off()

png(filename="output/LT51980241990098-SC20150107121947.png", width=800, height=500)
plotRGB(LT5, r = 3, g = 2, b = 1, stretch = "lin")
dev.off()


# 2. NDVI calculations 
ndvi2014 <- calculateNDVI(LC8[5],LC8[4])
ndvi1990 <-  calculateNDVI(LT5[4],LT5[3])

# 3. Image differencing 
dif_NDVI <- ndvi2014 - ndvi1990

png(filename="output/dif_NDVI.png", width=800, height=500)
plot(dif_NDVI, legend = FALSE, col = c("#FFA500","#FF4500"))
legend("bottomright", legend = c("1990", "2014"), fill = c("#FFA500","#FF4500"))
title(main = "NDVI comparison map")
dev.off()








