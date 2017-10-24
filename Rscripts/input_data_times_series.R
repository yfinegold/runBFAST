## test BFAST
## load libraries
options(stringsAsFactors = FALSE)
library(raster)
library(rgdal)
library(bfastSpatial)
library(stringr)
library(parallel)
library(devtools)
library(ggplot2)

# set results directory
if(!dir.exists(output_directory)){dir.create(output_directory)}
setwd(output_directory)
## input file locations
NDVIsceneID_input<- paste0(data_dir, NDVIsceneID_file)
NDVIstack_input <- paste0(data_dir,NDVIstack_file) 
NDMIsceneID_input<- paste0(data_dir, NDMIsceneID_file)
NDMIstack_input <- paste0(data_dir,NDMIstack_file) 
## name of raster stack with 0 as no data
NDMIstack_mask <- paste0(strsplit(NDMIstack_input,".tif"),"_masked.tif")
NDVIstack_mask <- paste0(strsplit(NDVIstack_input,".tif"),"_masked.tif")



NDMIstack_outputfile <- paste0(strsplit(NDMIstack_input,'.tif'),'0NA.tif')
NDVIstack_outputfile <- paste0(strsplit(NDVIstack_input,'.tif'),'0NA.tif')
# crop mask to AOI 
# parameters
resamp <- "near" #near (default), bilinear, cubic, cubicspline, lanczos, average, mode,  max, min, med, Q1, Q3

# step 1
r.map1 <- raster(NDMIstack_input)
r.map1.xmin <- as.matrix(extent(r.map1))[1]
r.map1.ymin <- as.matrix(extent(r.map1))[2]
r.map1.xmax <- as.matrix(extent(r.map1))[3]
r.map1.ymax <- as.matrix(extent(r.map1))[4]
r.map1.xres <- res(r.map1)[1]
r.map1.yres <- res(r.map1)[2]
r.map1.maxval <- maxValue(r.map1)
# r.map1.maxval <- system(sprintf("oft-mm -um %s %s | grep 'Band 1 max = '",paste0(inputdir, map1), paste0(inputdir, map1)), intern = TRUE)
r.map1.maxval <- as.numeric(substring(r.map1.maxval,14))
r.map1.proj <- as.character(projection(r.map1))
# ?CRS
# crs
# +proj=utm +zone=XX +datum=WGS84
# (strsplit(r.map1.proj,'+ellps='))
# r.map1.proj
# +proj=longlat +datum=WGS84 +no_defs'

r.map2 <- raster(forestmask)
r.map2.xmin <- as.matrix(extent(r.map2))[1]
r.map2.ymin <- as.matrix(extent(r.map2))[2]
r.map2.xmax <- as.matrix(extent(r.map2))[3]
r.map2.ymax <- as.matrix(extent(r.map2))[4]
r.map2.xres <- res(r.map2)[1]
r.map2.yres <- res(r.map2)[2]
# r.map2.maxval <- system(sprintf("oft-mm -um %s %s | grep 'Band 1 max = '",paste0(inputdir, map2), paste0(inputdir, map2)), intern = TRUE)
r.map2.maxval <- as.numeric(substring(r.map2.maxval,14))
r.map2.proj <- as.character(projection(r.map2))


# step 2
# reproject if needed and warp
proj_match <- r.map2.proj==r.map1.proj
proj_match
if(proj_match==FALSE){
  system(sprintf("gdalwarp -t_srs \"%s\" -r %s -of GTiff -overwrite %s %s",
                 r.map2.proj,
                 resamp,
                 paste0(mask_dir, forestmask_file),
                 paste0(data_dir, 'tmp_reproj_',forestmask_file)
  ))
  system(sprintf("gdalwarp -te %s %s %s %s -tr %s %s -tap -co COMPRESS=LZW -ot Byte -overwrite %s %s",
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
  system(sprintf("gdalwarp -te %s %s %s %s -tr %s %s -co COMPRESS=LZW -ot UInt16 -dstnodata 0 -overwrite %s %s",
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

# system(sprintf("gdal_translate -a_nodata 0 -projwin %s %s %s %s -co COMPRESS=LZW -ot UInt16 %s %s",
#                468798.817851,
#                5093.3067275,
#                485412.18759,
#                -8906.72395118,
#                paste0(data_dir, NDMIstack_file),
#                paste0(data_dir, 'tmp_warp_',NDMIstack_file)
# ))

# system(sprintf("gdal_translate -b 1 -co INTERLEAVE=BAND %s %s",
#                NDMIstack,
#                paste0(data_dir, 'tmp_1band_',NDMIstack_file)
# ))
# mask out non-forest
system(sprintf("gdal_calc.py -A %s -B %s --A_band=1 --co COMPRESS=LZW --NoDataValue=0 --allBands=A --overwrite --outfile=%s --calc=\"%s\"",
               NDMIstack_input,
               paste0(data_dir, 'tmp_warp_',forestmask_file),
               paste0(strsplit(NDMIstack_file,".tif"),"_masked.tif"),
               "(A*B)"
))
system(sprintf("gdal_calc.py -A %s -B %s --A_band=1 --co COMPRESS=LZW --NoDataValue=0 --allBands=A --overwrite --outfile=%s --calc=\"%s\"",
               NDVIstack_input,
               paste0(data_dir, 'tmp_warp_',forestmask_file),
               paste0(strsplit(NDVIstack_file,".tif"),"_masked.tif"),
               "(A*B)"
))

# 
# system(sprintf("gdal_calc.py -A %s -B %s --co COMPRESS=LZW --allBands=A --outfile=%s --calc=\"%s\"",
#                NDMIstack,
#                forestmask,
#                NDMIstack_mask,
#                "(A*B)"
# ))


system(sprintf("gdal_translate -co COMPRESS=LZW  -a_nodata 0  %s %s",
               paste0(getwd(),'/',strsplit(NDMIstack_file,".tif"),"_masked.tif"),
               NDMIstack_outputfile
))
system(sprintf("gdal_translate -co COMPRESS=LZW -a_nodata 0 %s %s",
               paste0(getwd(),'/',strsplit(NDVIstack_file,".tif"),"_masked.tif"),
               NDVIstack_outputfile
))


## read images as raster stack
NDMIstack <- stack(NDMIstack_outputfile) 
NDVIstack <- stack(NDVIstack_outputfile)

## read scene IDs
NDMIsceneID <- read.csv(NDMIsceneID_input)
NDVIsceneID <- read.csv(NDVIsceneID_input)

## assign the scene id as the name for each band in the stack
names(NDMIstack) <- NDMIsceneID$scene_id

## head(NDMIsceneID$scene_id)
## remove duplicates
scenes <- NDMIsceneID$scene_id
s <- as.data.frame(scenes)
s$scenes2 <- substr(scenes, 10, 16)
nodup <- s[!duplicated(s$scenes2),]
ndmiStack<-subset(NDMIstack,nodup$scenes)

## extract date of images
year <- substr(nodup$scenes2, 1,4)
julianday <- substr(nodup$scenes2, 5,8)
nodup$date <- as.Date(as.numeric(julianday),  origin = paste0(year,"-01-01"))

## set date as Z in the raster stack
ndmiStack <- setZ(ndmiStack,nodup$date)

## remove duplicates
names(NDVIstack) <- NDVIsceneID$scene_id
scenes <- NDVIsceneID$scene_id
s <- as.data.frame(scenes)
s$scenes2 <- substr(scenes, 10, 16)
nodup <- s[!duplicated(s$scenes2),]
ndviStack<-subset(NDVIstack,nodup$scenes)

## extract date of images
year <- substr(s$scenes2, 1,4)
julianday <- substr(s$scenes2, 5,8)
s$date <- as.Date(as.numeric(julianday),  origin = paste0(year,"-01-01"))

## set date as Z in the raster stack
ndviStack <- setZ(ndviStack,s$date)

