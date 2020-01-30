---
title: random forest code for land cover classification 
author: Jinwen Zhang
description: Explanation of GEE codes for a final project in Geoscripting course
date_published: 2020-01-31
---

[Open In Code Editor](https://code.earthengine.google.com/5adfefccc22add575841bce5163fcce7)
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
var maskL8 = function(image) {
  var qa = image.select('BQA');
  /// Check that the cloud bit is off.
  // See https://landsat.usgs.gov/collectionqualityband
  var mask = qa.bitwiseAnd(1 << 4).eq(0);
  return image.updateMask(mask);
};
```
#### filter by dates and regions of interest (roi)
```js
var dataset2013 = l8 
                  .filterDate('2013-01-01', '2013-12-31')
                  .filterBounds(roi)
                  .map(maskL8)
                  .median();
```
####  clip to predefined boundaries 
```js
var La2013 = ee.Image(dataset2013).clip(table) 
```
The result (`dataset2013`) is an `ImageCollection` that lists all of the images sensing over the study area in that specific time period. The  `median`  filter serves as a reducer here, to compute the mean value for each pixel. At each location in the output image, in each band, the pixel value is the median of all unmasked pixels in the input imagery (the images in the collection). From that, the result (`La2013`) only contains one image at large.

####  visualize the image
```js
Map.addLayer(La2013, {bands:['B4', 'B3', 'B2',], min: 0, max: 0.3}, 'Lagos2013',false);

```

### 4. collecting training data 
by select points on the image based on expert knowledge, and high-resolution satellite layers in GEE.
```js
// just a few examples here 
 water = 
    /* color: #bf04c2 */
    /* shown: false */
    ee.FeatureCollection(
        [ee.Feature(
            ee.Geometry.Point([3.107970051862594, 6.482713584807883]),
            {
              "landcover": 0,
              "system:index": "0"
            }),
residential = ee.FeatureCollection(
        [ee.Feature(
            ee.Geometry.Point([3.2343770058245127, 6.734572657797003]),
            {
              "landcover": 1,
              "system:index": "0"
            }),
            
 industrial = 
  ee.FeatureCollection(
        [ee.Feature(
            ee.Geometry.Point([3.246948001111832, 6.602872661270299]),
            {
              "landcover": 4,
              "system:index": "0"
            }),
// COLLECT training data 
var newfc = residential.merge(vegetation).merge(water).merge(industrial)
print(newfc)
```

### 5. Train random forest model 
```js

// method 2
// split the training data into e.g. 80% for training and 20 % for testing
// add a new random column to features(collection)
// FYI https://code.earthengine.google.com/c8c2701a804d9f025a73e94d2cad63c6
var training2 = objectPropertiesImage
                // .updateMask(seeds)
                .sampleRegions({
                          collection: newfc,  // features collected/defined by predefined points 
                                            // Get the sample from the polygons FeatureCollection.
                          properties: ['landcover'], // Keep this list of properties from the polygons.
                          scale: 30, // Set the scale to get Landsat pixels in the polygons.
                          tileScale : 8,
});
print(training2)

var withRandom = training2.randomColumn('random');
var split = 0.6;
var trainingFC = withRandom.filter(ee.Filter.lt('random', split));
var testingFC = withRandom.filter(ee.Filter.gte('random', split));

var TrainedClassifier = ee.Classifier.randomForest(100).train( // constructure a predictor
    {
      features : trainingFC, 
      classProperty : 'landcover',
      inputProperties : bands, 
      // gamma : 0.5,
    });
var testLC =  testingFC.classify(TrainedClassifier);   
var trainAccuracy2 = TrainedClassifier.confusionMatrix()

var confusionMatrix = testLC.errorMatrix('landcover','classification')    
print("Train Accuracy,", trainAccuracy2)
print("resubstitution error Matrix",trainAccuracy2)
print('training overall accuracy: ', trainAccuracy2.accuracy());

```

### 6. Visualization

```js

// Visualization brushes 
var palette =['0000FF', 'ffa500','000000','FFFF00','00FF00'];

// 0000FF is water is blue
// ffa500 is cropland with vegetation is orange
// 00000 is urban is black
// ffff00 is bare land is yellow
// 00ff00 is natural vegetation is green

Map.addLayer(training, {min:0, max:0.02,palette: paletter}, 'tranining clusters ', false)
Map.addLayer(classified, {min:0, max:254,palette: paletter}, 'Classified objects')

```

