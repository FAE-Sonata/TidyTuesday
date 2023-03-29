libraries_needed<-c("data.table", "tidytuesdayR", "rstudioapi", "skimr",
                    "tidyverse")
lapply(libraries_needed,require,character.only=T)
rm(libraries_needed)
# Get the Data

# Read in with tidytuesdayR package 
# Install from CRAN via: install.packages("tidytuesdayR")
# This loads the readme and all the datasets for the week of interest

# Either ISO-8601 date or year/week works!

tuesdata <- tidytuesdayR::tt_load(2023, week = 12) # 03-21

languages <- tuesdata$languages |> as.data.table()

current_path<-rstudioapi::getActiveDocumentContext()$path
setwd(dirname(current_path ))
print( getwd() )
save(list=ls(.GlobalEnv), file="global_langs.Rdata")

skim(languages)
hist(languages$appeared)
languages[appeared <= 0,] # Euclidean geometry, Babylonian numerals, etc.
languages$type |> unique() |> sort()

languages[grepl("SQL", title, ignore.case=T),.(title, type)]

languages$type |> table() |> sort() |> rev()
languages[type=="database",title]

# Programming languages only ----------------------------------------------
programming_only<-languages[type=='pl' &  number_of_users > 1,]
programming_only<-programming_only[,`:=`(
  f_rank=as.factor(language_rank),
  f_appeared=as.factor(appeared),
  log_n_users = log(number_of_users),
  log_n_jobs = log(number_of_jobs))]

rank_model<-lm(language_rank ~ appeared + book_count + number_of_users +
                 number_of_jobs, programming_only)
rank_model |> broom::tidy() # not good
summary(rank_model)

anova(rank_model)

hist(programming_only$number_of_users)
summary(programming_only$number_of_users)

## GGally
GGally::ggpairs(programming_only[,.(language_rank,
                                    appeared,
                                    book_count,
                                    log_n_users,
                                    log_n_jobs)])

## Tidymodels recipes for feature engineering: e.g. can move 5% or fewer frequencies to "other
### build out "recipe" above using the package
### build model using parsnip, 'train', evaluate, compare against alternatives
### 11 Apr for re-visiting the above

### Plumber for model APIs