####################################################################################################
####################################################################################################
## Run BFAST over multiple indeces and many points
## First download the timeseries for all the indeces of interest in SEPAL then save the time series in
## one folder, the 'time_series_dir'
## Contact yelena.finegold@fao.org
## 2018/08/11 
####################################################################################################
####################################################################################################
##############################################################
######## USER PARAMETERS
##############################################################
#import packages
# library(foreach)
# library(doParallel)
library(bfastSpatial)
library(raster)
library(rgdal)
library(raster)

#  enter the directory where the time series is downloaded
# use tab at the end of the line after time-series to autocomplete the next line
time_series_dir <- '~/downloads/suba/'
# file with your point data
fielddata_file <- '/home/finegold/degrad/natural_plantation_wgs84.shp'

# specify the beginning of the historical period and monitoring period
monitoring_year_beg <- 2013
# specify the parameters for BFAST, options are in comments for each parameter
formula <- 'response ~ harmon'  # 'response ~ harmon', "response ~  trend", 'response ~ trend + harmon'
orders <-   3                   # 1,2,3,4,5
types <-   'OLS-CUSUM'          # 'OLS-CUSUM', "OLS-MOSUM" 
historys <-  "ROC"              # "BP","ROC", "all", or specify history start date such as c(2005,1)

############################################################################################################################
##############################################################
######## RUNS FROM HERE
##############################################################
setwd(time_series_dir)

# read all the stack.vrt files in the time series directory folder
timeseries <- list.files(path=time_series_dir, pattern = "^stack.vrt$", recursive = TRUE, full.names = T)
fielddata <- readOGR(fielddata_file)
fielddata$magnitude <- 0
fielddata$breakpoint <- 0

# create initial dataframe
# loop through timeseries and points
for(tsfile in 1:length(timeseries)){
  timeseries.file <- timeseries[tsfile]
  brick.timeseries.file <- raster::brick(timeseries.file)
  print(timeseries.file)
  ts.date <- unlist(read.csv(paste0(dirname(timeseries[1]),'/dates.csv')))
  # foreach(n=1:nrow(fielddata), .packages = c("raster","bfast", "foreach"))  %dopar%  {
  for(n in 1:nrow(fielddata)){
    n.plot <- raster::extract(brick.timeseries.file,fielddata[n,])
    ts.plot <- bfastts(as.vector(n.plot), ts.date, type = "irregular")
    print(paste0('Plot number: ',fielddata[n,1]$No.Plot))
    print(paste0('Parameters: ',formula, '  ', orders, '  ', types, '  ', historys))
    out2 <- bfastmonitor(ts.plot,
                               start= c(monitoring_year_beg,1),
                               formula = as.Formula(formula),
                               order = orders,
                               type = types,
                               history = historys,
                               hpc = 'foreach'
          )
          print(paste0('Magnitude value: ',out2$magnitude))
          print(paste0('Breakpoint value: ',out2$breakpoint))
          # append results to shapefile
          fielddata$magnitude[n] <-  out2$magnitude
          fielddata$breakpoint[n] <-  out2$breakpoint
        }
      }

# write output to SHP in the timeseries directory
outputname <- paste0(strsplit(basename(fielddata_file), '.shp'),'_',paste0(gsub(' ~ ',"",formula,orders),'_',types,'_', historys),'.shp')
writeOGR(fielddata, dsn = time_series_dir, layer = outputname, driver = "ESRI Shapefile", overwrite=TRUE)
