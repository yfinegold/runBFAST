# runBFAST
## Step 1: 
Upload your AOI(saved as a KML) as a fusion table via [fusiontables.google.com](fusiontables.google.com)

## Step 2:
Set the custom parameters and run the GEE scripts to download time series stacks for [NDMI](https://code.earthengine.google.com/68c79000cbe1a54db282211d8d8affba) and [NDVI](https://code.earthengine.google.com/d50f7d7de252fc317d29ea117197428e)

## Step 3:
Set your custom parameters in the R script run_all.R
Run the script run_all.R to preprocess the data and run BFAST with different parameters

