####################################################################################
##############                    Running BFAST Spatial               ############## 
##############       contributors: Yelena Finegold, Sabina Rosca      ##############
##############             Remi d'Annunzio, Erik Lindquist            ##############  
##############              FAO Open Foris SEPAL project              ##############
##############      yelena.finegold@fao.org | sabina.rosca@wur.nl     ############## 
##############             Script 1: set parameters and run           ############## 
####################################################################################

####################################################################################
## Last update: 2017/10/31
####################################################################################

## input data for BFAST scripts 

# set data directory
data_dir <- '~/test_BFAST/'

# set forest mask directory
mask_dir <- "~/runBFAST/example/mask/"

# Forest mask, 1 is forest and 0 is nonforest
# forest mask file name
forestmask_file <- 'sieved_LC_2010_forestmask.tif'


######## if you data is already in your data directory enter the file name here
######## otherwise use the code after to download the data directly from your google drive
base <- 'Kyanja'


####### Google Earth Engine script : https://code.earthengine.google.com/68f81d93314b5f30aa1c5dfbf91aa88b

####### Transfer data from Google Drive to SEPAL
####### Example of authorization key : 4/QHH2DucZ-MI-GY0HnG6JyEfjMpfVvJsu6_TmHqbxBgQ
setwd(data_dir)
## paste the long link into the browser, follow the instructions to connect to your google account
## then copy the key and replace PASTE_THE_KEY_HERE with your authorization key
system(sprintf("echo %s | drive init",
               "PASTE_THE_KEY_HERE"))

system(sprintf("echo %s | drive init"))
system(sprintf("drive list"))

data_input <- c(paste0(c('ndmi_time_series_stack_','ndvi_time_series_stack_'),base,'.tif'),
                paste0(c('ndmi_time_series_stack_','ndmi_time_series_stack_'),base,'.csv')
)

for(data in data_input){
  system(sprintf("drive pull %s",
                 data))
}


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

# set results directory
output_directory <-paste0(data_dir,"results/",base,"/")

# # NDMI raster stack
NDMIstack_file <- paste0('ndmi_time_series_stack_',base,'.tif')
# # list of scene ID for each image in the raster stack
NDMIsceneID_file <- paste0('ndmi_time_series_stack_',base,'.csv')
# # NDVI raster image
NDVIstack_file <- paste0('ndvi_time_series_stack_',base,'.tif')
# # list of scene ID for each image in the raster stack
NDVIsceneID_file <- paste0('ndvi_time_series_stack_',base,'.csv')

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

