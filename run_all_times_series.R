###################################################################
#######             Running BFAST Spatial                   ####### 
#######   contributors: Yelena Finegold and Sabina Rosca    #######  
#######           FAO Open Foris SEPAL project              #######
#######   yelena.finegold@fao.org | sabina.rosca@wur.nl     ####### 
#######             Script 1: set parameters                ####### 
###################################################################

####################################################################################
# FAO declines all responsibility for errors or deficiencies in the database or 
# software or in the documentation accompanying it, for program maintenance and 
# upgrading as well as for any # damage that may arise from them. FAO also declines 
# any responsibility for updating the data and assumes no responsibility for errors 
# and omissions in the data provided. Users are, however, kindly asked to report any 
# errors or deficiencies in this product to FAO.
####################################################################################

####################################################################################
## Last update: 2017/10/30
####################################################################################

## input data for BFAST scripts 

# set data directory
data_dir <- "~/test_BFAST/"

# set forest mask directory
mask_dir <- "~/runBFAST/mask/"

# Forest mask, 1 is forest and 0 is nonforest
# forest mask file name
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
output_directory <-paste0(data_dir,"results/",strsplit(NDMIstack_file,".tif"),"/")


# beginning of historical period
historical_year_beg <- 2000
# beginning of monitoring period
monitoring_year_beg <- 2010
# end of monitoring period
monitoring_year_end <- 2017

# do you want to use a forest mask?
# 1 = use a forest mask
# 0 = do not use a forest mask
mask_data <- 0

# do you want to test only NDMI?
# 1 = use NDMI and NDVI
# 0 = use only NDMI
NDMI_only <- 0

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

