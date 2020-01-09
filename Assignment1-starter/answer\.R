
  # STD, M.A. Hamelberg, S. El Khinifri
  # 11 January 2019
  
  # Function PreprocessLandsat
  # Inputs: landsat code as written in the .tif files from the tar.gz files and the relevant colour bands
preprocess.landsat <- function(landsatcode, r, g, b){
    # Listing .tif files in tar.gz landsat file
    L = list.files('data/',pattern = glob2rx(sprintf('%s.tif', landsatcode)), full.names = TRUE)
    
    Lstack <- stack(L) # Stack layers
    Lfmask = Lstack[[1]] # Extract fmask
    
    Lnofmask <- dropLayer(Lstack, 1) # Drop fmask from Lstack
    
    cloud2NA <- function(x, y){ # Define function for overlay
      x[y != 0] <- NA # NA in x if y is not 0
      return(x)
    }
    
    # Apply overlay function with fmaskless and fmask stack and raster
    Lprocessed <- overlay(x = Lnofmask, y = Lfmask, fun = cloud2NA)
    
    return(Lprocessed) # Return cloudless file
  }
  
  preprocess.landsat()
  loaddata
  
  # STD, M.A. Hamelberg, S. El Khinifri
  # 11 January 2019
  
  # Function loaddata landsat
  loaddata <- function(link){ # Inputs: link to dropbox zip file with landsat tar.gz files
    download.file(url=sprintf(link, l), destfile='zips', method='auto') # Download zip file
    
    unzip('zips', exdir = 'data') # Unzip files
    
    x=list.files('data', pattern = glob2rx('*.tar.gz'), full.names = TRUE) # List all tar.gz files
    
    for (l in x){
      untar(sprintf('%s', l), exdir = 'data') # Untar all tar.gz files into data folder
    }
    
    file.remove('zips') # Remove initial zip
  }
  
  
  
  
  main
  
  
  
  STD, M.A. Hamelberg, S. El Khinifri
  # 11 January 2019
  
  # Import and/or install packages
  # Importing and/or installing packages
  if (!require("raster")) install.packages("raster")
  if (!require("rgdal")) install.packages("rgdal")
  library(raster)
  
  # Source functions
  source('R/loaddata.R')
  source('R/PreprocessLandsat.R')
  
  # Create directories
  # dir.create(file.path('output'), showWarnings = FALSE)
  
  # Load datasets
  # Loading datasets
  loaddata('https://www.dropbox.com/sh/3lz5vylc7tzpiup/AAB3HCFHdJFa8lV_PMRlV5Wda?dl=1')
  
  # Functions
  #TASK1
  LC8 = list.files('data/', pattern = glob2rx('LC8*band.tif'), full.names = TRUE)
  LT5 = list.files('data/', pattern = glob2rx('LT5*band.tif'), full.names = TRUE)
  print(LC8)
  print(LT5)
  LC8stack <- stack(LC8)
  LT5stack <- stack(LT5)
  
  cloud2NA <- function(x, y){
    x[y != 0] <- NA
    return(x)
  }
  LC8cloudfree <- overlay(x = LC8, y = list.files('data/', pattern = glob2rx('LC8*cfmask.tif'), full.names = TRUE), fun = cloud2NA)
  plot(LC8cloudfree)
  # Assigning variables
  # Indexing landsat bands
  # Landsat 8
  LC8b = 2
  LC8g = 3
  LC8r = 4
  # Landsat 5
  LT5b = LC8b + 1
  LT5g = LC8g + 1
  LT5r = LC8r + 1
  
  # Main code
  
  # TASK1
  # Apply preprocess.landsat function
  LC8cloudfree = preprocess.landsat('LC8', LC8b, LC8g, LC8r)
  LT5cloudfree = preprocess.landsat('LT5', LT5b, LT5g, LT5r)
  
  # Use intersect to equalize extents
  LC8cloudfree=intersect(LC8cloudfree, LT5cloudfree)
  LT5cloudfree=intersect(LT5cloudfree, LC8cloudfree)
  
  intersect(LC8stack, LT5stack)
  # Plot results of intersect as true colour
  plotRGB(LC8cloudfree, LC8b, LC8g, LC8r, stretch = 'lin')
  plotRGB(LT5cloudfree, LT5b, LT5g, LT5r, stretch = 'lin')
  
  ndvi <- (LC8stack[[5]] - LC8stack[[4]]) / (LC8stack[[5]] + LC8stack[[4]])
  plot(ndvi)
  
  #TASK2
  #TASK3
  # TASK2
  # Calculate NDVI for Landsat 8
  LC8ndvi <- (LC8cloudfree[[LC8r + 1]] - LC8cloudfree[[LC8r]]) / (LC8cloudfree[[LC8r + 1]] + LC8cloudfree[[LC8r]])
  # Calculate NDVI for Landsat 5
  LT5ndvi <- (LT5cloudfree[[LT5r + 1]] - LT5cloudfree[[LT5r]]) / (LT5cloudfree[[LT5r]] + LT5cloudfree[[LT5r + 1]])
  
  
  # TASK3
  # Define function for overlay removing latest timeframe from oldest
  timeseries <- function(x, y){
    x - y
    return(x)
  }
  # Apply overlay function with Landsat 8 and Landsat 5 inputs and the timeseries function
  ndvicomparison <- overlay(x = LC8ndvi, y = LT5ndvi, fun = timeseries)
  plot(ndvicomparison) # Plot the NDVI comparison
  
  # Create directory for output
  dir.create(file.path('output'), showWarnings = FALSE)
  
  # writeRaster(x=turaStack, filename='turaStack.grd', datatype='INT2S')
  # Write to .tif file in the output
  writeRaster(x=ndvicomparison, filename='output/ndvicomparison.tif', overwrite=TRUE, datatype='FLT8S')