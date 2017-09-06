## accuracy assessment for BFAST
## make this more automated!

setwd('~/BFAST_test/results/pugnido/')
results_directory <- getwd()
ref <- read.csv('~/BFAST_test/data/Yelena_collectedData_earthsae_CE_2017-07-18_on_210717_144200_CSV.csv')
head(ref)
table(ref$ref_class_label)
# 1 = stable
# 2 = degraded
# 3 = deforested
# 4 = gain
ref$deg_code[ref$ref_class_label == 'stable forest'] <- 1 
ref$deg_code[ref$ref_class_label == 'stable nonforest'] <- 1 
ref$deg_code[ref$ref_class_label == 'degradation'] <- 2
ref$deg_code[ref$ref_class_label == 'forest loss'] <- 3
ref$deg_code[ref$ref_class_label == 'forest gain'] <- 4
head(ref)
ref1 <- ref[ref$confidence=='hi' & ref$actively_saved=='true',]
table(ref1$deg_code)


#### Accuracy Assessment
i = 1
for(i in 1:10){
 
  example_title <- as.character(i)
  #   example_title <- 2
#   
  # Forest_mask <- raster(file.path(workshop_folder,"data/Fmask_2010_Peru.tif"))
  # validation_forest_map <- raster(file.path(workshop_folder,"data/Validation_forest_2016.tif"))
  try({
    results_directory1 <- file.path(results_directory,paste0("example_",as.character(i)))
    
    def_years<- raster(file.path(results_directory1,paste0("example_",example_title,"_deforestation_dates.grd")))
    def_ndmi <- raster(file.path(results_directory1,paste0("example_",example_title,"_deforestation_magnitude.grd")))
    bfm_ndmi <- brick(file.path(results_directory1, paste0("example_",example_title,".grd")))
    bfm_ndmi_wgs84 <- projectRaster(bfm_ndmi,crs=CRS("+init=epsg:4326"))
    
    change <- raster(bfm_ndmi_wgs84,1)
    magnitude <- raster(bfm_ndmi_wgs84,2)
    error <- raster(bfm_ndmi_wgs84,3)
    
    
    head(ref1[,3])
    def_years_wgs84 <- projectRaster(def_years,crs=CRS("+init=epsg:4326"))
    def_ndmi_wgs84 <- projectRaster(def_ndmi,crs=CRS("+init=epsg:4326"))
    
    ref1$def_year <- extract(def_years_wgs84,cbind(ref1[,3],ref1[,4]))
    ref1$def_ndmi <- extract(def_ndmi_wgs84,cbind(ref1[,3],ref1[,4]))
    ref1$change <- extract(change,cbind(ref1[,3],ref1[,4]))
    ref1$magnitude <- extract(magnitude,cbind(ref1[,3],ref1[,4]))
    ref1$error <- extract(error,cbind(ref1[,3],ref1[,4]))
    
    table(ref1$deg_code,ref1$def_ndmi)
    table(ref1$deg_code,ref1$def_year)
    
    table(ref1$def_year)
    
    colnames(ref1)[colnames(ref1)=="def_year"]  <-   paste0("def_year",example_title)
    colnames(ref1)[colnames(ref1)=="def_ndmi"]  <- paste0("def_ndmi",example_title)
    colnames(ref1)[colnames(ref1)=="change"]    <- paste0("change",example_title)
    colnames(ref1)[colnames(ref1)=="magnitude"] <- paste0("magnitude",example_title)
    colnames(ref1)[colnames(ref1)=="error"]     <- paste0("error",example_title)
    rm(results_directory1)
  })
}
library(reshape)
?melt
names(ref1)
ref_melt <- melt(ref1, id.vars= c('ref_class_label',"deg_code"), measure.vars = c('magnitude1','magnitude2','magnitude3','magnitude4','magnitude5','magnitude6','magnitude7','magnitude8','magnitude9','magnitude10'))
str(ref_melt)
head(ref_melt)
table(ref_melt$variable)

sp <-ggplot(ref_melt, aes(x=ref_class_label  , y=value))+
  geom_boxplot(size=1, alpha=0.4)+
  xlab("degradation class")+
  ylab("BFAST magnitude of degradation")+
  theme_bw()

sp + facet_wrap( ~ variable, ncol=5 ) 
# stat_smooth(method="loess", colour="blue", size=1.5)+

