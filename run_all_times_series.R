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
data_dir <- '/home/finegold/downloads/wesley_iran_test/' # timeseries directory

# beginning of historical period
historical_year_beg <- 2014
# beginning of monitoring period
monitoring_year_beg <- 2016
# end of monitoring period
monitoring_year_end <- 2017

##############################################
##       OPTIONAL SETTING             ########
## do you want to use a forest mask?  ########
##############################################

# 1 = use a forest mask
# 0 = do not use a forest mask
mask_data <- 0

# set forest mask directory
mask_dir <- "~/runBFAST/example/mask/"

# Forest mask, 1 is forest and 0 is nonforest
# forest mask file name
forestmask_file <- 'sieved_LC_2010_forestmask.tif'

#################################
# Run R scripts
#################################
## if you runBFAST folder is not saved in your home directory, change the file path for these scripts to coorspond where you cloned the scripts
# process input data
source("~/runBFAST/Rscripts/input_data_times_series.R")
# run BFAST with 4 different parameters
source("~/runBFAST/Rscripts/example_1.R")
source("~/runBFAST/Rscripts/example_2.R")
source("~/runBFAST/Rscripts/example_3.R")
source("~/runBFAST/Rscripts/example_5.R")

# compare reference data from the study area to the magnitude of change
# source("~/BFAST_test/Rscripts/reference_data.R")
