library(tidyverse)
library(dplyr)
library(tm)
library(leaflet)
library(pals)
library(htmlwidgets)
library(sf)
library(readr)

#Set working directory
setwd("~/Documents/GitHub/data-project-world_media_international_coverage/Archive scraping")

#Import dataset
hindu_headlines <- read_csv("headlines_hindu.csv")

headlines <- nrow(hindu_headlines)

#Loaded hindu_headlines csv, then put words into one vector
hindu_string <- hindu_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

hindu_string <- removeWords(hindu_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(hindu_string, eng_countries)

#Make value into dataframe
hindu_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
hindu_countries1 <- cbind(eng_countries_full, hindu_countries)

#Make sure count is numeric
hindu_countries1$count <- as.numeric(hindu_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_hindu <- left_join(x = world2, 
                                   y = hindu_countries1, 
                                   by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
hindu_map <- combined_ref_hindu %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "The Hindu (India)") %>%
  add_column(source_country = "India") %>%
  add_column(orientation = "Center left") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "India")

write_csv(hindu_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/hindu_map.csv")

