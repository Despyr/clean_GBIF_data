library(sqldf)
library(RSQLite)
library(readr)
library(DBI)
library(htmlTable)
library(tidyverse)
library(rgdal)
library(tcltk2)
library(Cairo)
library(plyr)
library(dplyr)
library(rlang)
library(tidyr)
library(broom)
library(sp)
library(raster)
library(dismo)
library(maptools)
library(stats)
library(ggmap)
library(rgeos)
library(tmap)


##########################################Directories defs##########################################
#definition of the directories to be used
#creation of the list of useful directories

d <- list()
d$gb <- "D:/bamboodata/source/grassbasebrut/"
d$wcvp <- "D:/bamboodata/source/theworldchecklistbrut/"
d$sql <- "D:/bamboodata/"
d$mnc <- "D:/bamboodata/source/menace/"
d$shp <- "D:/bamboodata/source/TDWG/level3/"

con <- dbConnect(RSQLite::SQLite(), paste0(d$sql,"bamboo.sqlite")) ## will make, if not present
dbSendStatement(con, "PRAGMA auto_vacuum = 1") #setting this before creation of table allows auto clean



########################################################################################################################
##########################################Database##########################################
########################################################################################################################

qry <- c("SELECT *FROM bambusoideae_brut_sp")
bambusoideae_brut_sp <- dbGetQuery(con, qry)

qry <- c("SELECT *FROM distribution_bambusoideae")
distribution_bambusoideae <- dbGetQuery(con, qry)


qry <- c("SELECT *FROM gbif_bambusoideae_georef")
gbif_bambusoideae_georef <- dbGetQuery(con, qry)

gbif_bambusoideae_acl3 <- sqldf("SELECT d.*, f.area_code_l3 FROM gbif_bambusoideae_georef d, distribution_bambusoideae f WHERE d.accepted_plant_name_id=f.accepted_plant_name_id")



########################################################################################################################
##########################################MAPS PREPARATION TDWG3##########################################
########################################################################################################################

#loading and projection of the level 3 map
shape.file <- paste0(d$shp,"level3.shp")
shape <- readOGR(shape.file)

shape <- spTransform(shape, "+proj=longlat +ellps=WGS84 +no_defs")

# projection in Lambert Azimuthal Equal Area to preserve polygon surface and compute it (as shapelaea)
shapelaea <- spTransform(shape, "+proj=laea +lat_0=0 +lon_0=0 +x_0=0 +y_0=0 +ellps=WGS84 +units=m +no_defs")

shapeb = rgeos::gBuffer(shape, byid = TRUE, width=0)
shape_f <- fortify(shapeb, region = "LEVEL3_COD")

#remove Antarctica from maps
shape_f <- sqldf("SELECT * FROM shape_f WHERE id != 'ANT'")



########################################################################################################################
###########Check whether the coordinates of an occurrence fall within the polygon associated with the species###########
########################################################################################################################

#df = file with occurrences in rows and a column for the lat, long and the associated poly ID similar to the checklist (gbif_bambusoideae_acl3)
#df1 = table of coordinates of each polygon associated with their id (shape_f)

for (i in 1:nrow(df)){
  shape_i= as.data.frame(df[i,"column numbers with polygon ID"]) 
  names(shape_i)[1] <- "id"
  shape_poly <- sqldf("SELECT s.long, s.lat FROM df1 s, shape_i j WHERE s.id = j.id ")
  df[i,"setup an umpty column"] <- point.in.polygon(df[i,"column numbers with long occurrences"], 
                                                    df[i,"column numbers with lat occurrences"], 
                                                    c(shape_poly$long), c(shape_poly$lat),
                                                    mode.checked=FALSE)
}


