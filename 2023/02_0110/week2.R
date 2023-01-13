# Get the Data

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!
setwd("C:/HY/R_exploration/TidyTuesday")

libraries_needed<-c("stringr", "lubridate", "magrittr", "data.table", "readr",
                    "tidytuesdayR", "ggplot2")
lapply(libraries_needed,require,character.only=T)
rm(libraries_needed)
COLLECTED_REGIONS<-c("US", "CA")
US_CA_LIMITS<-list(lat=c(15,85), long=c(-180,-50))

# tuesdata <- tidytuesdayR::tt_load('2023-01-10')
# saveRDS(tuesdata, "2023/02_0110/tues.Rdata")
# readRDS("2023/02_0110/tues.Rdata")

# PFW_2021_public<-as.data.table(tuesdata$PFW_2021_public)
# count_site_data<-as.data.table(tuesdata$PFW_count_site_data_public_2021)
# saveRDS(ls(), "2023/02_0110/tues.Rdata")
load("2023/02_0110/tues.RData")

# EDA ---------------------------------------------------------------------
PFW_2021_public$loc_id %>% unique %>% length
count_site_data$loc_id %>% unique %>% length

PFW_2021_public$species_code %>% unique %>% length

any(!(PFW_2021_public$loc_id %in% count_site_data$loc_id))
sum(PFW_2021_public$loc_id %in% count_site_data$loc_id, na.rm=T) / nrow(PFW_2021_public)

setnames(PFW_2021_public, c("latitude", "longitude"), c("lat", "long"))

# search for nonsensical geo-points
world<-map_data("world") %>% as.data.table
ggplot() +
  geom_polygon(data=world,
               aes(x=long, y = lat, group = group), fill="grey", alpha=0.3) +
  geom_point(data=PFW_2021_public, aes(x=long, y=lat, colour=how_many)) +
  scale_x_continuous(-180,180) + scale_y_continuous(-90,90) + coord_map()

ggplot() +
  geom_polygon(data=world[region %in% COLLECTED_REGIONS,],
               aes(x=long, y = lat, group = group), fill="grey", alpha=0.3) +
  geom_point(data=PFW_2021_public, aes(x=long, y=lat, colour=how_many)) +
  scale_x_continuous(min(US_CA_LIMITS$long), max(US_CA_LIMITS$long)) +
  scale_y_continuous(min(US_CA_LIMITS$lat[1]), max(US_CA_LIMITS$lat)) + coord_map()

SEMIARID_LIMIT<- -100
ggplot() +
  geom_polygon(data=world[region %in% COLLECTED_REGIONS,],
               aes(x=long, y = lat, group = group), fill="grey", alpha=0.3) +
  geom_point(data=PFW_2021_public[long >= SEMIARID_LIMIT,] , aes(x=long, y=lat, colour=how_many)) +
  scale_x_continuous(SEMIARID_LIMIT, max(US_CA_LIMITS$long)) +
  scale_y_continuous(min(US_CA_LIMITS$lat[1]), max(US_CA_LIMITS$lat)) + coord_map()

# NY only
ggplot() +
  geom_polygon(data=world[region %in% COLLECTED_REGIONS,],
               aes(x=long, y = lat, group = group), fill="grey", alpha=0.3) +
  geom_point(data=PFW_2021_public[subnational1_code == "US-NY",],
             aes(x=long, y=lat, colour=how_many)) +
  scale_x_continuous(-80, -65) +
  scale_y_continuous(40, 46) + coord_map()