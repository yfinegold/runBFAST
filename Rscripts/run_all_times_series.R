## This script was created by Yelena Finegold and Sabina Rosca
## contact: yelena.finegold@fao.org 
## input data for BFAST scripts 

# set data directory
data_dir <- "~/runBFAST/input/"

# Forest mask, 1 is forest and 0 is nonforest
mask_dir <- "~/runBFAST/mask/"
forestmask_file <- 'sieved_LC_2010_forestmask.tif'

# NDMI raster stack
NDMIstack_file <- "ndmi_time_series_stack_Kyanja.tif"

# list of scene ID for each image in the raster stack
NDMIsceneID_file <- 'ndmi_time_series_stack_Kyanja.csv'

# NDVI raster image
NDVIstack_file <- "ndvi_time_series_stack_Kyanja.tif"

# list of scene ID for each image in the raster stack
NDVIsceneID_file <- 'ndvi_time_series_stack_Kyanja.csv'

# set results directory
output_directory <-paste0("~/runBFAST/results/",strsplit(NDMIstack_file,".tif"),"/")


# beginning of historical period
historical_year_beg <- 2000
# beginning of monitoring period
monitoring_year_beg <- 2010
# end of monitoring period
monitoring_year_end <- 2017

#################################
# Run R scripts
#################################
# process input data
source("~/runBFAST/Rscripts/input_data_times_series.R")
# run BFAST with 10 different parameters
source("~/runBFAST/Rscripts/example_1.R")
source("~/runBFAST/Rscripts/example_2.R")
source("~/runBFAST/Rscripts/example_3.R")
source("~/runBFAST/Rscripts/example_4.R")
source("~/runBFAST/Rscripts/example_5.R")
source("~/runBFAST/Rscripts/example_6.R")
source("~/runBFAST/Rscripts/example_7.R")
source("~/runBFAST/Rscripts/example_8.R")
source("~/runBFAST/Rscripts/example_9.R")
source("~/runBFAST/Rscripts/example_10.R")

# compare reference data from the study area to the magnitude of change
# source("~/BFAST_test/Rscripts/reference_data.R")
# classification of magnitude of change based on standard deviation-- loops through all the results
source("~/runBFAST/Rscripts/magnitude_threshold.R")

