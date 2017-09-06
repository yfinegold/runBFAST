############
## bfast set threshold 
############
# set working directory
setwd(results_directory)

# read the tif files to be reclassified
# first make an empty list
fileslist <- list()
# loop through all the folders and write the file names into the list
for (i in 1:10){
  files <- list.files(path=getwd(), pattern=paste0('example_',i,'.tif'), full.names=T, recursive=T)
  fileslist[[i]] <- files
}
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

for(i in 1:length(fileslist)){
  for(j in 1:sapply(fileslist[i], length)){
    tryCatch({
      print(fileslist[[i]][j])
      inputfile <- fileslist[[i]][j]
      outputfile <- paste0(strsplit(inputfile,'.tif'),'threshold.tif')
      means <- system(sprintf("gdalinfo -stats %s | grep 'STATISTICS_MEAN'",inputfile), intern = TRUE)
      means_b2 <- as.numeric(substring(means[2],21))
      mins <- system(sprintf("gdalinfo -mm %s | grep 'Minimum'",inputfile), intern = TRUE)
      mins_b2 <- as.numeric(substring(str_split(mins[2], ', ',, simplify = TRUE )[1],11))
      maxs_b2 <- as.numeric(substring(str_split(mins[2], ', ',, simplify = TRUE )[2],9))
      stdevs <- system(sprintf("gdalinfo -stats %s | grep 'STATISTICS_STDDEV'",inputfile), intern = TRUE)
      stdevs_b2 <- as.numeric(substring(stdevs[2],23))
      system(sprintf("gdal_calc.py -A %s --A_band=2 --co=COMPRESS=LZW --type=Byte --outfile=%s --calc='%s'
",
                     inputfile,
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
  } 
}


