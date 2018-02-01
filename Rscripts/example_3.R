# Example 3: ####
## modified from https://github.com/rosca002/FAO_Bfast_workshop/tree/master/tutorial

example_title <- 3
results_directory <- file.path(output_directory,paste0("example_",example_title,'/'))
if(!dir.exists(results_directory)){dir.create(results_directory)}
log_filename <- file.path(results_directory, paste0(format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), "_example_", example_title, ".log"))
start_time <- format(Sys.time(), "%Y/%m/%d %H:%M:%S")

result <- file.path(results_directory, paste0("example_", example_title, ".tif"))
time <- system.time(bfmSpatial(NDMIstack, start = c(monitoring_year_beg, 1),
                               dates = dates,
                               formula = response ~ harmon,
                               order = 1, history = c(2005,1),
                               filename = result,
                               mc.cores = detectCores()))

write(paste0("This process started on ", start_time,
             " and ended on ",format(Sys.time(),"%Y/%m/%d %H:%M:%S"),
             " for a total time of ", time[[3]]/60," minutes"), log_filename, append=TRUE)

## Post-processing ####
bfm_ndmi <- brick(result)
#### Change
change <- raster(bfm_ndmi,1)
plot(change, col=rainbow(8),breaks=c(monitoring_year_beg:monitoring_year_end))

#### Magnitude
magnitude <- raster(bfm_ndmi,2)
magn_bkp <- magnitude
magn_bkp[is.na(change)] <- NA
plot(magn_bkp,breaks=c(-5:5*1000),col=rainbow(length(c(-5:5*1000))))
plot(magnitude, breaks=c(-5:5*1000),col=rainbow(length(c(-5:5*1000))))

#### Error
error <- raster(bfm_ndmi,3)
plot(error)

#### Detect deforestation
def_ndmi <- magn_bkp
def_ndmi[def_ndmi>0]=NA
plot(def_ndmi)
plot(def_ndmi,col="black", main="NDMI_deforestation")
writeRaster(def_ndmi,filename = file.path(results_directory,paste0("example_",example_title,"_deforestation_magnitude.grd")),overwrite=TRUE)
writeRaster(def_ndmi,filename = file.path(results_directory,paste0("example_",example_title,"_deforestation_magnitude.tif")),overwrite=TRUE)

def_years <- change
def_years[is.na(def_ndmi)]=NA

years <- c(monitoring_year_beg:monitoring_year_end)
plot(def_years, col=rainbow(length(years)),breaks=years, main=paste0("Detecting deforestation after",monitoring_year_beg))
writeRaster(def_years,filename = file.path(results_directory,paste0("example_",example_title,"_deforestation_dates.grd")),overwrite=TRUE)
writeRaster(def_years,filename = file.path(results_directory,paste0("example_",example_title,"_deforestation_dates.tif")),overwrite=TRUE)

# calculate the mean, standard deviation, minimum and maximum of the magnitude band
# reclass the image into 10 classes
# 0 = no data
# 1 = no change (mean +/- 1 standard deviation)
# 2 = negative small magnitude change      (mean - 2 standard deviations)
# 3 = negative medium magnitude change     (mean - 3 standard deviations)
# 4 = negative large magnitude change      (mean - 4 standard deviations)
# 5 = negative very large magnitude change (mean - 4+ standard deviations)
# 6 = postive small magnitude change       (mean + 2 standard deviations)
# 7 = postive medium magnitude change      (mean + 3 standard deviations)
# 8 = postive large magnitude change       (mean + 4 standard deviations)
# 9 = postive very large magnitude change  (mean + 4+ standard deviations)
tryCatch({
  outputfile <- paste0(results_directory,"example_",example_title,'_threshold.tif')
  means <- system(sprintf("gdalinfo -stats %s | grep 'STATISTICS_MEAN'",result), intern = TRUE)
  means_b2 <- as.numeric(substring(means[2],21))
  mins <- system(sprintf("gdalinfo -mm %s | grep 'Minimum'",result), intern = TRUE)
  mins_b2 <- as.numeric(substring(str_split(mins[2], ', ',, simplify = TRUE )[1],11))
  maxs_b2 <- as.numeric(substring(str_split(mins[2], ', ',, simplify = TRUE )[2],9))
  stdevs <- system(sprintf("gdalinfo -stats %s | grep 'STATISTICS_STDDEV'",result), intern = TRUE)
  stdevs_b2 <- as.numeric(substring(stdevs[2],23))
  system(sprintf("gdal_calc.py -A %s --A_band=2 --co=COMPRESS=LZW --type=Byte --outfile=%s --calc='%s'
                 ",
                 result,
                 outputfile,
                 paste0('(A<=',(maxs_b2),")*",
                        '(A>',(means_b2+(stdevs_b2*4)),")*9+",
                        '(A<=',(means_b2+(stdevs_b2*4)),")*",
                        '(A>',(means_b2+(stdevs_b2*3)),")*8+",
                        '(A<=',(means_b2+(stdevs_b2*3)),")*",
                        '(A>', (means_b2+(stdevs_b2*2)),")*7+",
                        '(A<=',(means_b2+(stdevs_b2*2)),")*",
                        '(A>', (means_b2+(stdevs_b2)),")*6+",
                        '(A<=',(means_b2+(stdevs_b2)),")*",
                        '(A>', (means_b2-(stdevs_b2)),")*1+",
                        '(A>=',(mins_b2),")*",
                        '(A<', (means_b2-(stdevs_b2*4)),")*5+",
                        '(A>=',(means_b2-(stdevs_b2*4)),")*",
                        '(A<', (means_b2-(stdevs_b2*3)),")*4+",
                        '(A>=',(means_b2-(stdevs_b2*3)),")*",
                        '(A<', (means_b2-(stdevs_b2*2)),")*3+",
                        '(A>=',(means_b2-(stdevs_b2*2)),")*",
                        '(A<', (means_b2-(stdevs_b2)),")*2")
                 
  ))
  
}, error=function(e){})
