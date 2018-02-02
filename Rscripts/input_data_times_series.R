###################################################################
#######             Running BFAST Spatial                   ####### 
#######      Scripts by Yelena Finegold and Sabina Rosca    #######       
#######        contact: yelena.finegold@fao.org             ####### 
#######         contact: sabina.rosca@wur.nl                ####### 
#######             Script 2: prepare data                  ####### 
###################################################################

## test BFAST
## load libraries
options(stringsAsFactors = FALSE)
packages <- function(x){
  x <- as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
}
packages(raster)
packages(rgdal)
packages(bfastSpatial)
packages(stringr)
packages(parallel)
packages(devtools)
packages(ggplot2)
packages(ncdf4)

set_fast_options() # Optional, but should give some speed up

# set results directory
output_directory <-paste0(data_dir,"results/")
if(!dir.exists(output_directory)){dir.create(output_directory, recursive = T)}
setwd(output_directory)

dates <- unlist(read.csv(paste0(data_dir, '1/dates.csv'),header = FALSE))
data_input_vrt <- paste0(data_dir, '1/stack.vrt')
data_input <- paste0(data_dir, '1/stack.tif')

# 
# data_input_netcdf <- paste0(data_dir,paste('stacktif_netcdf.nc'))
# 
# system(sprintf("gdal_translate -of netCDF %s %s",
#                data_input_vrt,
#                data_input_netcdf))
## convert the VRT file to a TIF for faster processing and write the process duration to a log file

log_filename <- file.path(data_dir, paste0(format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), "_gdalwarp",  ".log"))
start_time <- format(Sys.time(), "%Y/%m/%d %H:%M:%S")

# time <- system.time(system(sprintf("gdal_translate -co COMPRESS=LZW %s %s",
#                                    data_input_vrt,
#                                    data_input
# )))
## use gdal warp because it can run on multi cores
time <- system.time(system(sprintf("gdalwarp -of GTiff -multi -wo NUM_THREADS=ALL_CPUS -co COMPRESS=LZW %s %s",
                                   data_input_vrt,
                                   data_input
)))
write(paste0("This gdalwarp process started on ", start_time,
             " and ended on ",format(Sys.time(),"%Y/%m/%d %H:%M:%S"),
             " for a total time of ", time[[3]]/60," minutes"), log_filename, append=TRUE)


## Set a conditional statement to check if the available dates are within range of the parameter dates
if(substr(dates[1],1,4)<=historical_year_beg &
substr(tail(dates, n=1),1,4)>= monitoring_year_end){
  print(paste0('Setting parameters... '))


## name of raster stack with 0 as no data
stack_outputfile <- paste0(strsplit(data_input,'.tif'),'0NA.tif')

# crop mask to AOI 
# parameters
resamp <- "near" #near (default), bilinear, cubic, cubicspline, lanczos, average, mode,  max, min, med, Q1, Q3

# step 1
r.map1 <- raster(data_input)
r.map1.xmin <- as.matrix(extent(r.map1))[1]
r.map1.ymin <- as.matrix(extent(r.map1))[2]
r.map1.xmax <- as.matrix(extent(r.map1))[3]
r.map1.ymax <- as.matrix(extent(r.map1))[4]
r.map1.xres <- res(r.map1)[1]
r.map1.yres <- res(r.map1)[2]
# r.map1.maxval <- system(sprintf("oft-mm -um %s %s | grep 'Band 1 max = '",paste0(inputdir, map1), paste0(inputdir, map1)), intern = TRUE)
r.map1.proj <- as.character(projection(r.map1))

if(mask_data==1){
  ## input file locations
  forestmask <- paste0(mask_dir,forestmask_file)
  r.map2 <- raster(forestmask)
  r.map2.xmin <- as.matrix(extent(r.map2))[1]
  r.map2.ymin <- as.matrix(extent(r.map2))[2]
  r.map2.xmax <- as.matrix(extent(r.map2))[3]
  r.map2.ymax <- as.matrix(extent(r.map2))[4]
  r.map2.xres <- res(r.map2)[1]
  r.map2.yres <- res(r.map2)[2]
  # r.map2.maxval <- system(sprintf("oft-mm -um %s %s | grep 'Band 1 max = '",paste0(inputdir, map2), paste0(inputdir, map2)), intern = TRUE)
  r.map2.proj <- as.character(projection(r.map2))
  
  # step 2
  # reproject if needed and warp
  proj_match <- r.map2.proj==r.map1.proj
  proj_match
  if(proj_match==FALSE){
    system(sprintf("gdalwarp -multi -wo NUM_THREADS=ALL_CPUS -t_srs \"%s\" -r %s -of GTiff -overwrite %s %s",
                   r.map2.proj,
                   resamp,
                   paste0(mask_dir, forestmask_file),
                   paste0(data_dir, 'tmp_reproj_',forestmask_file)
    ))
    system(sprintf("gdalwarp -multi -wo NUM_THREADS=ALL_CPUS -te %s %s %s %s -tr %s %s -tap -co COMPRESS=LZW -ot Byte -overwrite %s %s",
                   r.map1.xmin,
                   r.map1.ymin,
                   r.map1.xmax,
                   r.map1.ymax,
                   r.map1.xres,
                   r.map1.yres,
                   paste0(data_dir, 'tmp_reproj_',forestmask_file),
                   paste0(data_dir, 'tmp_warp_',forestmask_file)
    ))
  }else{
    system(sprintf("gdalwarp -multi -wo NUM_THREADS=ALL_CPUS -te %s %s %s %s -tr %s %s -co COMPRESS=LZW -ot UInt16 -dstnodata 0 -overwrite %s %s",
                   r.map1.xmin,
                   r.map1.ymin,
                   r.map1.xmax,
                   r.map1.ymax,
                   r.map1.xres,
                   r.map1.yres,
                   paste0(mask_dir, forestmask_file),
                   paste0(data_dir, 'tmp_warp_',forestmask_file)
    ))
  }
  # mask out non-forest
  system(sprintf("gdal_calc.py -A %s -B %s --A_band=1 --co COMPRESS=LZW --NoDataValue=0 --allBands=A --overwrite --outfile=%s --calc=\"%s\"",
                 data_input,
                 paste0(data_dir, 'tmp_warp_',forestmask_file),
                 paste0(strsplit(stack_file,".tif"),"_masked.tif"),
                 "(A*B)"
  ))
  system(sprintf("gdal_translate -co COMPRESS=LZW  -a_nodata 0  %s %s",
                 paste0(getwd(),'/',strsplit(stack_file,".tif"),"_masked.tif"),
                 stack_outputfile
  ))
  NDMIstack <- brick(stack_outputfile) 

}else{
## read images as raster stack
NDMIstack <- brick(data_input) 
}
}else{print('ERROR. Check your dates for historical and monitoring year end, they are outside your available data range')}

