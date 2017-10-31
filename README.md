# runBFAST
## Step 1: 
Upload your AOI(saved as a shapefile) as an table assest in [Google Earth Engine](https://code.earthengine.google.com/). Make sure you select all supporting files (.shp, .shx, .prj, .dbf, .sbn)

## Step 2:
Set the custom parameters and run the GEE scripts to download time series stacks for [NDMI and NDVI](https://code.earthengine.google.com/4cba7fdd19c5e61794c6cd02f06f4df4)

## Step 3:
Set your custom parameters in the R script run_all_time_series.R
Run the script run_all_time_series.R to preprocess the data and run BFAST with different parameters

