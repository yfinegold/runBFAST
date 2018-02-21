# Example 5: ####
## modified from https://github.com/rosca002/FAO_Bfast_workshop/tree/master/tutorial
## BFAST settings
# option: “all”
# stack subset: no
# option: Sequential monitoring period approach
# Regression model: harmonic order 1

for(i in list.dirs(data_dir, recursive=FALSE)){
  if(file.exists(paste0(i,'/','stack.vrt'))){
    print(paste0('BFASTing stack in: ', basename(i)))
    output_directory <-paste0(i,'/',basename(i),"_results/")
    if(!dir.exists(output_directory)){dir.create(output_directory, recursive = T)}
    setwd(output_directory)
    output_directory <- getwd()
    dates <- unlist(read.csv(paste0(i,'/','dates.csv'),header = FALSE))
    data_input_vrt <- paste0(i,'/','stack.vrt')
    data_input <- paste0(i,'/','stack.tif')
    NDMIstack <- brick(data_input) 
        
    example_title <- 5
    results_directory <- file.path(output_directory,paste0("example_",example_title,'/'))
    if(!dir.exists(results_directory)){dir.create(results_directory)}
    log_filename <- file.path(results_directory, paste0(format(Sys.time(), "%Y-%m-%d-%H-%M-%S"), "_example_", example_title, ".log"))
    start_time <- format(Sys.time(), "%Y/%m/%d %H:%M:%S")
    
    result <- file.path(results_directory, paste0("example_", example_title, ".tif"))
    bfmSpatialSq <- function(start, end, timeStack, outdir, ...){
      bfm_seq <- lapply(start:end,
                        function(year){
                          outfl <- paste0(outdir, "/bfm_NDMI_", year, ".tif")
                          bfm_year <- bfmSpatial(timeStack, start = c(year, 1), monend = c(year + 1, 1),
                                                 dates = dates,
                                                 formula = response~harmon,
                                                 order = 1, history = "all", filename = outfl, ...)
                          outfl
                        })
    }
    time <- system.time(bfmSpatialSq(monitoring_year_beg,monitoring_year_end,NDMIstack,results_directory, mc.cores = detectCores()))
    
    calcDefSeqYears2 <- function(outdir,outfile,start,end,parameter_value){
      bfast_result_fnames <- list.files(outdir, pattern=glob2rx('*.tif'), full.names=TRUE)
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
    
    def_years_2005 <- calcDefSeqYears2(results_directory,result,monitoring_year_beg,monitoring_year_end,historical_year_beg)
    plot(def_years_2005)
    write(paste0("This process started on ", start_time,
                 " and ended on ",format(Sys.time(),"%Y/%m/%d %H:%M:%S"),
                 " for a total time of ", time[[3]]/60," minutes"), log_filename, append=TRUE)
    plot(result)
    
    ## Post-processing ####
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
      means_b2 <- cellStats( raster(result,band=2) , "mean") 
      mins_b2 <- cellStats(raster(result,band=2) , "min")
      maxs_b2 <- cellStats( raster(result,band=2) , "max")
      stdevs_b2 <- cellStats( raster(result,band=2) , "sd")
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
    ####################  CREATE A PSEUDO COLOR TABLE
    ?col2
    cols <- col2rgb(c("white","beige","yellow","orange","red","darkred","palegreen","green2","forestgreen",'darkgreen'))
    colors()
    pct <- data.frame(cbind(c(0:9),
                            cols[1,],
                            cols[2,],
                            cols[3,]
    ))
    
    write.table(pct,paste0(results_directory,"color_table.txt"),row.names = F,col.names = F,quote = F)
    
    
    ################################################################################
    ## Add pseudo color table to result
    system(sprintf("(echo %s) | oft-addpct.py %s %s",
                   paste0(results_directory,"color_table.txt"),
                   paste0(results_directory,"tmp_example_",example_title,'_threshold.tif'),
                   paste0(results_directory,"/","tmp_colortable.tif")
    ))
    ## Compress final result
    system(sprintf("gdal_translate -ot byte -co COMPRESS=LZW %s %s",
                   paste0(results_directory,"/","tmp_colortable.tif"),
                   outputfile
    ))
    ## Clean all
    system(sprintf(paste0("rm ",results_directory,"/","tmp*.tif")))
    
  }}

# ## BFAST pixel on the output
# plot(raster(result, band =2))
# pixelResult = bfmPixel(
#   NDMIstack,
#   dates = dates,
#   history = c(historical_year_beg, 1),
#   start = c(monitoring_year_beg, 1),
#   interactive= TRUE,
#   # cell = 17000, # Can be tricky to pick a cell that got data
#   plot = TRUE
# )
