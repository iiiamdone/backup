# Function to calculate the Normalized Difference Vegetation Index
# Input raster bands are NIR and Red band
# Output is an ndvi raster

calculateNDVI <- function (NIR, RED){
  ((NIR - RED) / (NIR + RED))
}