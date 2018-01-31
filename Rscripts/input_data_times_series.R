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
set_fast_options() # Optional, but should give some speed up

# set results directory
if(!dir.exists(output_directory)){dir.create(output_directory, recursive = T)}
setwd(output_directory)
## input file locations
forestmask <- paste0(mask_dir,forestmask_file)

## name of raster stack with 0 as no data
NDMIstack_mask <- paste0(strsplit(data_input,".tif"),"_masked.tif")
# NDVIstack_mask <- paste0(strsplit(NDVIstack_input,".tif"),"_masked.tif")

NDMIstack_outputfile <- paste0(strsplit(data_input,'.tif'),'0NA.tif')
# NDVIstack_outputfile <- paste0(strsplit(NDVIstack_input,'.tif'),'0NA.tif')
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
# (strsplit(r.map1.proj,'+ellps='))
# r.map1.proj
# +proj=longlat +datum=WGS84 +no_defs'
if(mask_data==1){
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
                 paste0(strsplit(NDMIstack_file,".tif"),"_masked.tif"),
                 "(A*B)"
  ))
  system(sprintf("gdal_translate -co COMPRESS=LZW  -a_nodata 0  %s %s",
                 paste0(getwd(),'/',strsplit(NDMIstack_file,".tif"),"_masked.tif"),
                 NDMIstack_outputfile
  ))
  if(NDMI_only==1){
    system(sprintf("gdal_calc.py -A %s -B %s --A_band=1 --co COMPRESS=LZW --NoDataValue=0 --allBands=A --overwrite --outfile=%s --calc=\"%s\"",
                   NDVIstack_input,
                   paste0(data_dir, 'tmp_warp_',forestmask_file),
                   paste0(strsplit(NDVIstack_file,".tif"),"_masked.tif"),
                   "(A*B)"
    ))
    system(sprintf("gdal_translate -co COMPRESS=LZW -a_nodata 0 %s %s",
                   paste0(getwd(),'/',strsplit(NDVIstack_file,".tif"),"_masked.tif"),
                   NDVIstack_outputfile
    ))
  }
}else{
  # system(sprintf("gdal_translate -co COMPRESS=LZW  -a_nodata 0  %s %s",
  #                data_input,
  #                NDMIstack_outputfile
  # ))
  if(NDMI_only==1){
    # system(sprintf("gdal_translate -co COMPRESS=LZW -a_nodata 0 %s %s",
    #                NDVIstack_input,
    #                NDVIstack_outputfile
    # ))
  }
}

if(NDMI_only==1){
  NDVIstack <- brick(NDVIstack_input)
}

## read images as raster stack
NDMIstack <- brick(data_input) 
