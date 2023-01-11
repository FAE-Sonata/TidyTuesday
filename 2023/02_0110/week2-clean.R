setwd("C:/HY/R_exploration/TidyTuesday")

libraries_needed<-c("stringr", "lubridate", "magrittr", "data.table", "readr",
                    "tidytuesdayR", "ggplot2")
lapply(libraries_needed,require,character.only=T)
rm(libraries_needed)
COLLECTED_REGIONS<-c("US", "CA")
load("2023/02_0110/tues.RData")

PFW_2021_public[,country:=str_sub(subnational1_code, end=2)]
PFW_2021_public[!(country %in% COLLECTED_REGIONS),]
PFW_2021_public[lat < 0, `:=`(lat=-lat, long=-long, subnational1_code="US-GA",
                              country="US")] # 1 row that was input in the "SE" quad-sphere
any(PFW_2021_public$lat < 0)
PFW_2021_public<-PFW_2021_public[country %in% COLLECTED_REGIONS,]