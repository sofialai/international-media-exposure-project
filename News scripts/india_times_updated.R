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
india_times_headlines <- read_csv("india_times_headlines.csv")

headlines <- nrow(india_times_headlines)

#Loaded india_times_headlines csv, then put words into one vector
india_times_string <- india_times_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

india_times_string <- removeWords(india_times_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(india_times_string, eng_countries)

#Make value into dataframe
india_times_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
india_times_countries1 <- cbind(eng_countries_full, india_times_countries)

#Make sure count is numeric
india_times_countries1$count <- as.numeric(india_times_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_india_times <- left_join(x = world2, 
                                y = india_times_countries1, 
                                by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
india_times_map <- combined_ref_india_times %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "The Times of India (India)") %>%
  add_column(source_country = "India") %>%
  add_column(orientation = "Center right") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "India")

setwd("~/Documents/GitHub/Final_Data_Science_Project/News source df's")

write_csv(india_times_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/india_times_map.csv")

