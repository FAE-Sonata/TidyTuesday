libraries_needed<-c("data.table", "tidytuesdayR", "rstudioapi")
lapply(libraries_needed,require,character.only=T)
rm(libraries_needed)

# Getting the path of your current open file
current_path<-rstudioapi::getActiveDocumentContext()$path 
setwd(dirname(current_path ))
print( getwd() )

tuesdata <- tidytuesdayR::tt_load('2023-01-31')

cats_uk <- as.data.table(tuesdata$cats_uk)
cats_uk_reference <- as.data.table(tuesdata$cats_uk_reference)
rm(tuesdata)
save(list=ls(.GlobalEnv), file="cats_uk.Rdata")