

## input data for BFAST scripts 


# set data directory
data_dir <- "~/BFAST_test/data/test_sites/test_sites/"
# NDMI raster stack
NDMIstack <- paste0(data_dir,'All_NDMI_ethiopia_degrad_7.tif') # tile3
# list of scene ID for each image in the raster stack
NDMIsceneID <- paste0(data_dir,'All_NDMI_ethiopia_degrad_7.csv')
# NDVI raster image
NDVIstack <- paste0(data_dir,'All_NDVI_transitional_rainforest_deg_7km.tif')
# NDVI raster image
NDVIsceneID <- paste0(data_dir,'All_NDVI_transitional_rainforest_deg_7km.csv')

# set results directory
results_directory <-"~/BFAST_test/results/test_sites/ethiopia_degrad_7/"
setwd(results_directory)

# beginning of historical period
historical_year_beg <- 2001
# beginning of monitoring period
monitoring_year_beg <- 2010
# end of monitoring period
monitoring_year_end <- 2017

#################################
# Run R scripts
#################################
# process input data
source("~/BFAST_test/Rscripts/input_data.R")
# run BFAST with 10 different parameters
source("~/BFAST_test/Rscripts/example_1.R")
source("~/BFAST_test/Rscripts/example_2.R")
source("~/BFAST_test/Rscripts/example_3.R")
source("~/BFAST_test/Rscripts/example_4.R")
source("~/BFAST_test/Rscripts/example_5.R")
source("~/BFAST_test/Rscripts/example_6.R")
source("~/BFAST_test/Rscripts/example_7.R")
source("~/BFAST_test/Rscripts/example_8.R")
source("~/BFAST_test/Rscripts/example_9.R")
source("~/BFAST_test/Rscripts/example_10.R")

# compare reference data from the study area to the magnitude of change
# source("~/BFAST_test/Rscripts/reference_data.R")
# classification of magnitude of change based on standard deviation-- loops through all the results
source("~/BFAST_test/Rscripts/magnitude_threshold.R")
