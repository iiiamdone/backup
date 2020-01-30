---
title: random forest code for land cover classification 
author: Jinwen Zhang
description: Explanation of GEE codes for a final project in Geoscripting course
date_published: 2020-01-31
---

[Open In Code Editor here](https://code.earthengine.google.com/?scriptPath=users%2Fiiiamdone%2Ftest1%3Afinal_project_geoscripting)
This final project will utilize random forest to predict land cover change on Lagos, Nigeria.

## Instructions

The basic workflow is as follows:

1. Fetch the Landsat ImageCollection dataset and examine availability
2. Define region of interest and import as `FeatureCollection`
3. Group `ImageCOllection` to `Image` objects using reducer and filter
4. Collect trianing data with classifed labels 
5. Train random forest model
6. Visualization

### 1. Get Landsat images collection

Landsat 5 ETM and Landsat 8 OLI surface reflectance data will be used. These data offered a 30-meter spatial resolution and available for the period of 2000 to 2018.Landsat 5 is available since 1985, while Landsat 8 is available since 2013. 
we select 2000 and 2018 these two time spots as they are more representative for capturing land cover change within the study area. 

Retrieve the [USGS Landsat 8 Collection 1 Tier 1 TOA Reflectance](https://developers.google.com/earth-engine/datasets/catalog/LANDSAT_LC08_C01_T1_TOA) as an `ee.ImageCollection` in the import tab and select the NDVI band.

```js
var l8: ImageCollection('USGS Landsat 8 Collection 1 Tier 1 TOA Reflectance') (12bands)
```

### 2. Define clipping and region boundary geometries
### extent 
The extent specifies the region of interest that defines the boundaries of image composite. In this case, we extracted GADM level 3 data and 

Clipping the data is an optional step that sets pixels outside an area of
interest as null, which is helpful for drawing attention to a particular area
within a region. Here, the [Database of Global Administrative Areas](https://gadm.org/download_country_v3.html)
(LSIB) vector dataset is filtered to choose level-3 data -- geometries
covering Lagos state, whose union serves as the clipping geometry. The expected outcome is, after clipping, all pixels outside of Africa will be null. Next, a polygon describing a rectangular extent of the desired animation is defined. 

After the GADM shapefile was downloaded, we can project it to a new coordinate system (EPSG:26391). After that, we uploaded them as `FeatureCollection` object and imported them  `ee.Geometry` object

```js

// Define the regional bounds of animation frames.
var table = ee.FeatureCollection("users/iiiamdone/lagos");
```

### 3. Select image composite by parameters

#### cloud masking 
```js
var maskL8sr = function(image) {
  // Bits 3 and 5 are cloud shadow and cloud, respectively.
  var cloudShadowBitMask = (1 << 3);
  var cloudsBitMask = (1 << 5);
  // Get the pixel QA band.
  var qa = image.select('pixel_qa');
  // Both flags should be set to zero, indicating clear conditions.
  var mask = qa.bitwiseAnd(cloudShadowBitMask).eq(0)
                .and(qa.bitwiseAnd(cloudsBitMask).eq(0));
  return image.updateMask(mask);
}

var cloudMaskL457 = function(image) {
  var qa = image.select('pixel_qa');
  // If the cloud bit (5) is set and the cloud confidence (7) is high
  // or the cloud shadow bit is set (3), then it's a bad pixel.
  var cloud = qa.bitwiseAnd(1 << 5)
                  .and(qa.bitwiseAnd(1 << 7))
                  .or(qa.bitwiseAnd(1 << 3));
  // Remove edge pixels that don't occur in all bands
  var mask2 = image.mask().reduce(ee.Reducer.min());
  return image.updateMask(cloud.not()).updateMask(mask2);
};

```
#### filter by dates and regions of interest (roi)
```js
var dataset2018 = l8 
                  .filterDate('2018-01-01', '2018-12-31')
                  .filterBounds(table)
                  .map(maskL8sr)
                  .median();

var dataset2000 = l7 
                  .filterDate('2000-01-01', '2000-12-31')
                  .filterBounds(table)
                  .map(cloudMaskL457)
                  .median();

```
The results (`dataset2018` and`dataset2000` ) came from  `ImageCollection` objects that lists all of the images sensing over the study area in that specific time period. The  `median`  filter serves as a reducer here, to compute the mean value for each pixel. At each location in the output image, in each band, the pixel value is the median of all unmasked pixels in the input imagery (the images in the collection). From that, the result (`La2013`) only contains one image at large.

####  clip to predefined boundaries and visualize the images
```js
var La2018 = ee.Image(dataset2018).clip(table) 
Map.addLayer(La2018, {bands:['B4', 'B3', 'B2',], min: 0, max: 3000}, 'Lagos2018',false);
var La2000 = ee.Image(dataset2000).clip(table) 
Map.addLayer(La2000, {bands:['B3', 'B2', 'B1',], min: 0, max: 3000}, 'Lagos2000',false);
```


### 4. collecting training data 
By select points on the image based on expert knowledge, and high-resolution satellite layers in GEE. These training data were collected and exported as GEE assets (`FeatureCollection` objects)in order to increaes more reproducibility, therefore we re-import the traningpoints as codes shown as: 
```js
// load training points. the numberic property 'landcover' stores know labels
// here, the training data is collected from previous studies
var pnts = ee.FeatureCollection("users/iiiamdone/trainingpnts");

```

### 5. Train random forest model 
Here only contain RF model for predicting 2018, others are in the [code](https://code.earthengine.google.com/?scriptPath=users%2Fiiiamdone%2Ftest1%3Afinal_project_geoscripting)

```js
// overlay points on imagery to get training
var training = La2018.select(bands8).sampleRegions({
  collection : pnts,
  properties : ['landcover'],
  scale : 30,
  tileScale : 8,
})

// // divide training and test sets 
var withRandom = training.randomColumn('random');
var split = 0.7;
var trainingFC = withRandom.filter(ee.Filter.lt('random', split));
var testingFC = withRandom.filter(ee.Filter.gte('random', split));

// traing a random forest classifier with some default parameters
var modelRF = ee.Classifier.randomForest(100).train({
  features: trainingFC, 
  classProperty : 'landcover', // The name of the property containing the class value
  inputProperties : bands8,
})

// Classify the image with the same bands used for training. (predict)
var test = testingFC.classify(modelRF)
var Classified = La2018.select(bands8).classify(modelRF);

// get a confusion matrix represetning resubstitution accuracy
var trainingAccuracy = modelRF.confusionMatrix();
print("resubstitution error Matrix",trainingAccuracy)
print('training overall accuracy: ', trainingAccuracy.accuracy()); 

```

### 6. Visualization

```js

// visualization 
var igbpPalette = [
  '000000', // water
  'aea1d6', // wetlands
  'ff0000', // agriculture
  '00ff00', // forest
  'c6da8a', // grassland 
  '86da9c', // shrub
  'FF0000', // urban
  'da6807', // barren
];

Map.addLayer(training, {min:0, max:10,palette: igbpPalette}, 'tranining clusters ', false)
Map.addLayer(Classified, {min:0, max:254,palette: igbpPalette}, 'predicted 2018')
Map.addLayer(predicted,  {min:0, max:254,palette: igbpPalette}, 'predicted 2000')


```

