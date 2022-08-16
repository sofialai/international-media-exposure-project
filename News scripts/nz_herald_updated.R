library(tidyverse)
library(dplyr)
library(tm)
library(leaflet)
library(pals)
library(htmlwidgets)
library(sf)
library(readr)

#Set working directory
setwd("~/Documents/GitHub/data-project-world_media_international_coverage/Daily Scraping")

#Import dataset
nz_herald_headlines <- read_csv("nz_herald_headlines.csv")

headlines <- nrow(nz_herald_headlines)

#Put words into one vector
nz_herald_string <- nz_herald_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

nz_herald_string <- removeWords(nz_herald_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(nz_herald_string, eng_countries)

#Make value into dataframe
nz_herald_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
nz_herald_countries1 <- cbind(eng_countries_full, nz_herald_countries)

#Make sure count is numeric
nz_herald_countries1$count <- as.numeric(nz_herald_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_nz_herald <- left_join(x = world2, 
                                            y = nz_herald_countries1, 
                                            by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
nz_herald_map <- combined_ref_nz_herald %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "New Zealand Herald (New Zealand)") %>%
  add_column(source_country = "New Zealand") %>%
  add_column(orientation = "Center right") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "New Zealand")

write_csv(nz_herald_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/nz_herald_map.csv")

