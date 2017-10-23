# Example 6: ####
example_title <- 6
results_directory <- file.path(output_directory,paste0("example_",example_title))
if(!dir.exists(results_directory)){dir.create(results_directory)}
log_filename <- file.path(results_directory, paste0(format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), "_example_", example_title, ".log"))
start_time <- format(Sys.time(), "%Y/%m/%d %H:%M:%S")

result <- file.path(results_directory, paste0("example_", example_title, ".tif"))
subsetTimeStack <- function(timestack,year){
  timespan <- which(timestack@z$time>as.Date(paste0(year,"-01-01"),"%Y-%m-%d"))
  result <- brick(timestack[[timespan]])
  result@z$time <- timestack@z$time[timespan]
  result
}

ndmiStack_example_6 <- subsetTimeStack(ndmiStack,2008)

bfmSpatialSq <- function(start, end, timeStack, outdir, ...){
  bfm_seq <- lapply(start:end,
                    function(year){
                      outfl <- paste0(outdir, "/bfm_NDMI_", year, ".grd")
                      bfm_year <- bfmSpatial(timeStack, start = c(year, 1), monend = c(year + 1, 1), formula = response~harmon,
                                             order = 1, history = "all", filename = outfl, ...)
                      outfl
                    })
}
time <- system.time(bfmSpatialSq(monitoring_year_beg,monitoring_year_end,ndmiStack_example_6,results_directory, mc.cores = detectCores()))

calcDefSeqYears2 <- function(outdir,outfile,start,end,parameter_value){
  bfast_result_fnames <- list.files(outdir, pattern=glob2rx('*.grd'), full.names=TRUE)
  yearly_def <- lapply(bfast_result_fnames,function(file_name){
    bfm_year <- brick(file_name)
    bfm_year[[1]][bfm_year[[2]]>0] <- NA
    bfm_year[[2]][is.na(bfm_year[[1]])] <- NA
    bfm_year
  })
  bfm_summary <- yearly_def[[length(yearly_def)]]
  for (i in (length(yearly_def)-1):1) {
    bfm_summary[!is.na(yearly_def[[i]][[1]])] <- yearly_def[[i]][!is.na(yearly_def[[i]][[1]])]
  }
  writeRaster(bfm_summary,file.path(outfile))
}

def_years_2005 <- calcDefSeqYears2(results_directory,result,monitoring_year_beg,monitoring_year_end,2005)

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
