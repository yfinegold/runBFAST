# Example 9: ####
# source("~/BFAST_test/Rscripts/input_data.R")
example_title <- 9
results_directory <- file.path(output_directory,paste0("example_",example_title))
if(!dir.exists(results_directory)){dir.create(results_directory)}
log_filename <- file.path(results_directory, paste0(format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), "_example_", example_title, ".log"))
start_time <- format(Sys.time(), "%Y/%m/%d %H:%M:%S")

result <- file.path(results_directory, paste0("example_", example_title, ".tif"))
time <- system.time(bfmSpatial(ndviStack, start = c(monitoring_year_beg, 1),
                               formula = response ~ harmon,
                               order = 1, history = "all",
                               filename = result,
                               mc.cores = detectCores()))

write(paste0("This process started on ", start_time,
             " and ended on ",format(Sys.time(),"%Y/%m/%d %H:%M:%S"),
             " for a total time of ", time[[3]]/60," minutes"), log_filename, append=TRUE)

## Post-processing ####
bfm_ndvi <- brick(result)
#### Change
change <- raster(bfm_ndvi,1)
plot(change, col=rainbow(8),breaks=c(monitoring_year_beg:monitoring_year_end))

#### Magnitude
magnitude <- raster(bfm_ndvi,2)
magn_bkp <- magnitude
magn_bkp[is.na(change)] <- NA
plot(magn_bkp,breaks=c(-5:5*1000),col=rainbow(length(c(-5:5*1000))))
plot(magnitude, breaks=c(-5:5*1000),col=rainbow(length(c(-5:5*1000))))

#### Error
error <- raster(bfm_ndvi,3)
plot(error)

#### Detect deforestation
def_ndvi <- magn_bkp
def_ndvi[def_ndvi>0]=NA
plot(def_ndvi)
plot(def_ndvi,col="black", main="NDVI_deforestation")
writeRaster(def_ndvi,filename = file.path(results_directory,paste0("example_",example_title,"_deforestation_magnitude.grd")),overwrite=TRUE)
writeRaster(def_ndvi,filename = file.path(results_directory,paste0("example_",example_title,"_deforestation_magnitude.tif")),overwrite=TRUE)

def_years <- change
def_years[is.na(def_ndvi)]=NA

years <- c(monitoring_year_beg:monitoring_year_end)
plot(def_years, col=rainbow(length(years)),breaks=years, main=paste0("Detecting deforestation after ",monitoring_year_beg))
writeRaster(def_years,filename = file.path(results_directory,paste0("example_",example_title,"_deforestation_dates.grd")),overwrite=TRUE)
writeRaster(def_years,filename = file.path(results_directory,paste0("example_",example_title,"_deforestation_dates.tif")),overwrite=TRUE)
