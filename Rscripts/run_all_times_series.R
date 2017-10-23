

## input data for BFAST scripts 


# set data directory
data_dir <- "~/BFAST_test/data/uganda/input/"

# Forest mask, 1 is forest and 0 is nonforest
mask_dir <- "~/uganda/sieved_maps/"
forestmask_file <- 'sieved_LC_2010_forestmask.tif'
forestmask <- paste0(mask_dir,forestmask_file) 
# NDMI raster stack
NDMIstack_file <- "time_series_stack_Kyanja.tif"
NDMIstack_input <- paste0(data_dir,NDMIstack_file) 

# list of scene ID for each image in the raster stack
NDMIsceneID_file <- paste0(data_dir,'time_series_scene_ids_Kyanja.csv')
# NDVI raster image
# NDVIstack <- paste0(data_dir,'All_NDVI_rci_20171009.tif')
# # NDVI raster image
# NDVIsceneID <- paste0(data_dir,'tableID_NDVI_rci_20171009.csv')

# set results directory
output_directory <-paste0("~/BFAST_test/data/uganda/results/",strsplit(NDMIstack_file,".tif"),"/")
if(!dir.exists(output_directory)){dir.create(output_directory)}
setwd(output_directory)

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
source("~/BFAST_test/data/uganda/input_data_times_series.R")
# run BFAST with 10 different parameters
source("~/BFAST_test/Rscripts/example_1.R")
source("~/BFAST_test/Rscripts/example_2.R")
source("~/BFAST_test/Rscripts/example_3.R")
source("~/BFAST_test/Rscripts/example_4.R")
source("~/BFAST_test/Rscripts/example_5.R")
source("~/BFAST_test/Rscripts/example_6.R")
source("~/BFAST_test/Rscripts/example_7.R")
# source("~/BFAST_test/Rscripts/example_8.R")
# source("~/BFAST_test/Rscripts/example_9.R")
source("~/BFAST_test/Rscripts/example_10.R")

# compare reference data from the study area to the magnitude of change
# source("~/BFAST_test/Rscripts/reference_data.R")
# classification of magnitude of change based on standard deviation-- loops through all the results
source("~/BFAST_test/Rscripts/magnitude_threshold.R")
