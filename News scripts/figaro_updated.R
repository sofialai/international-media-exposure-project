library(tidyverse)
library(dplyr)
library(tm)
library(leaflet)
library(pals)
library(htmlwidgets)
library(sf)
library(readr)

#Set working directory
setwd("~/Documents/GitHub/Final_Data_Science_Project/Daily Scraping")

#Import dataset
figaro_headlines <- read_csv("figaro_headlines.csv")

headlines <- nrow(figaro_headlines)

#Loaded figaro_headlines csv, then put words into one vector
figaro_string <- figaro_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

figaro_string <- removeWords(figaro_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(figaro_string, fr_countries)

#Make value into dataframe
figaro_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
figaro_countries1 <- cbind(fr_countries_full, figaro_countries)

#Make sure count is numeric
figaro_countries1$count <- as.numeric(figaro_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_figaro <- left_join(x = world2, 
                                       y = figaro_countries1, 
                                       by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
figaro_map <- combined_ref_figaro %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "Figaro (France)") %>%
  add_column(source_country = "France") %>%
  add_column(orientation = "Center right") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "France") 

write_csv(figaro_map, "~/Documents/GitHub/Final_Data_Science_Project/News source df's/figaro_map.csv")
