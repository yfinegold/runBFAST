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
data_dir <- '/home/finegold/downloads/ETH_kamashi/' # timeseries directory

# beginning of historical period
historical_year_beg <- 2008
# beginning of monitoring period
monitoring_year_beg <- 2013
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

