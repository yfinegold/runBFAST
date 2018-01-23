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
data_dir <- '/home/finegold/downloads/Ethiopia_BG_bamboo_testsite_again3/' # timeseries directory


# set forest mask directory
mask_dir <- "~/runBFAST/example/mask/"

# Forest mask, 1 is forest and 0 is nonforest
# forest mask file name
forestmask_file <- 'sieved_LC_2010_forestmask.tif'


# # basename for the raster stacks and CSV files
# # if the file is called ndmi_time_series_stack_Kyanja.tif the basename is Kyanja
# basename <- "Menagesha"
# 
# 
# ####### Run the GEE script: https://code.earthengine.google.com/bb245767014bc48657d121e1a8747098
# 
# ####### Transfer data from Google Drive to SEPAL
# ####### Example of authorization key : 4/QHH2DucZ-MI-GY0HnG6JyEfjMpfVvJsu6_TmHqbxBgQ
# 
# setwd(data_dir)
# ## paste the long link into the browser, follow the instructions to connect to your google account
# ## then copy the key and replace PASTE_THE_KEY_HERE with your authorization key
# system(sprintf("echo %s | drive init",
#                "4/-RHV07YV7jM90vTZR2KfG-tdzd7lGuGgvgrjaGcR9bU"))
# 
# # system(sprintf("echo %s | drive init"))
# system(sprintf("drive list"))
# 
# data_input <- c(paste0(c('ndmi_time_series_stack_','ndvi_time_series_stack_'),basename,'.tif'),
#                 paste0(c('ndmi_time_series_stack_','ndmi_time_series_stack_'),basename,'.csv')
# )
# 
# for(data in data_input){
#   system(sprintf("drive pull %s",
#                  data))
# }
# 
dates <- unlist(read.csv(paste0(data_dir, '/1/dates.csv')))
data_input <- paste0(data_dir, '/1/stack_1.vrt')

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
output_directory <-paste0(data_dir,"results/")

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

