# Assignment 1, week 1


## NDVI change over time

### Your task
You would like to know if Wageningen and surroundings has become greener in spring time over the past years. The [Normalized Difference Vegetation Index](https://en.wikipedia.org/wiki/Normalized_difference_vegetation_index) should be a good indicator for this. You need to conduct a *bi-temporal comparison* of two NDVI images. Simply subtracting the two images should work, but unfortunately these haven't been pre-processed yet. Two Landsat raw surface reflectance products covering the area have been downloaded for you. They were acquired around the same period of the year, but about 30 years apart from each other. Your task is to prepare these images, conduct the bi-temporal comparison, and draw a conclusion.


### Details
- The Landsat data can be found [here](https://www.dropbox.com/sh/3lz5vylc7tzpiup/AAB3HCFHdJFa8lV_PMRlV5Wda?dl=1)
- Beware of the different product details and bands of [Landsat 8](https://landsat.gsfc.nasa.gov/landsat-8/) and [Landsat 5](https://landsat.gsfc.nasa.gov/landsat-5/)
- A cloud mask from the fmask algorithm is contained in both archives


### Requirements
- The data should be downloaded in your script, and not be uploaded to your Git repository
- Write and use at least 2 functions for the pre-processing
- Visualize the two Landsat products as RGB images and save them as a `.png` files
- Visualize the resulting NDVI comparison map, from which the conclusion is clear, and save as a `.png` file


### Assessment
You will be assessed according to the [general rubrics](https://wageningenur4-my.sharepoint.com/:w:/g/personal/jan_verbesselt_wur_nl/ERkkjdEWK_dEmWFRVdhWBawBdKDBgjh6lajIaGE-hkz0KA?e=RqoFVC). Ensure you use the proper project structure, pay attention to documentation, Git use and keep the above requirements in mind. The functionality of you code will be assessed on: 

Task 1: pre-processing of the satellite images (load, crop, mask and visualization)

Task 2: NDVI calculation

Task 3: Temporal comparison with appropriate values and visualization/conclusion



### Hints
- `list.files()` with a `pattern =` argument can be used to filter files
- `?untar`
- `?intersect`
- Be sure to check the extents of the images


### Submission
You have until **10/01 16u** to work on the assignment. After the deadline, your repository will be cloned to be reviewed and graded. Make sure you **push your last changes to your repository before the deadline**, otherwise these will not be considered.

Go to Brightspace and follow the submission instructions from there (codegrade environment)
