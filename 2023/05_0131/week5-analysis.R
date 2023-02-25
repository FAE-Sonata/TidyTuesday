libraries_needed<-c("data.table", "rstudioapi", "dplyr", "skimr", "ggplot2", "RColorBrewer")
lapply(libraries_needed,require,character.only=T)
rm(libraries_needed)

# Getting the path of your current open file
current_path<-rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path))

load("cats_uk.Rdata")

# EDA (no maps) -----------------------------------------------------------
glimpse(cats_uk)
non_id_cols<-Filter(function(x) !grepl("^event_id", x), names(cats_uk))
dropid<-cats_uk[,..non_id_cols]
summary(dropid); skim(dropid)
dropid<-dropid[,marked_outlier:=algorithm_marked_outlier | manually_marked_outlier]

# Map viz -----------------------------------------------------------------
world<-map_data("world") |> as.data.table()
## UK-wide; adapted from https://bookdown.org/yann_ryan/r-for-newspaper-data/mapping-with-r-geocode-and-map-the-british-librarys-newspaper-collection.html
ggplot() +
  geom_polygon(data=world, #[region %in% COLLECTED_REGIONS,],
               aes(x=long, y = lat, group = group), fill="grey", alpha=0.3) +
  coord_fixed(xlim = c(-10,3), 
              ylim = c(50.3, 59)) +
  geom_point(data=dropid,
             aes(x=location_long, y=location_lat, colour=marked_outlier)) # +
# scale_x_continuous(-10, 5) +
# scale_y_continuous(47, 61) + coord_map()

## SW England only
sw_eng_plot<-function(dt) {
  return(ggplot() +
           geom_polygon(data=world, #[region %in% COLLECTED_REGIONS,],
                        aes(x=long, y = lat, group = group), fill="grey", alpha=0.3) +
           coord_fixed(xlim = c(dt$location_long |> min() |> round() - 1,
                                dt$location_long |> max() |> round() + 1), 
                       ylim = c(dt$location_lat |> min() |> round() - 0.5,
                                dt$location_lat |> max() |> round() + 0.5)))
}

sw_eng_plot(dropid) +
  geom_point(data=dropid,
             aes(x=location_long, y=location_lat, colour=marked_outlier))

## separate facet height by whether the OBS point was marked as an outlier
# from https://stackoverflow.com/a/21538521
rainbow_palette <- colorRampPalette(rev(brewer.pal(11, "Spectral")))
get_gradientn<-function(dt){
  return(scale_colour_gradientn(colours = rainbow_palette(100), limits=c(
    min(dt$height_above_ellipsoid),
    max(dt$height_above_ellipsoid))))
}

sw_eng_plot(dropid) +
  geom_point(data=dropid,
             aes(x=location_long, y=location_lat, colour=height_above_ellipsoid)) + 
  get_gradientn(dropid) +
  facet_wrap(~marked_outlier)

## non-outliers, only
non_outlier<-dropid[marked_outlier==F,]
sw_eng_plot(non_outlier) +
  geom_point(data=non_outlier,
             aes(x=location_long, y=location_lat, colour=height_above_ellipsoid)) + 
  get_gradientn(non_outlier)