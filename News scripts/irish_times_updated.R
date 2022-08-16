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
irish_times_headlines <- read_csv("irish_times_headlines.csv")

headlines <- nrow(irish_times_headlines)

#Loaded irish_times_headlines csv, then put words into one vector
irish_times_string <- irish_times_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

irish_times_string <- removeWords(irish_times_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(irish_times_string, eng_countries)

#Make value into dataframe
irish_times_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
irish_times_countries1 <- cbind(eng_countries_full, irish_times_countries)

#Make sure count is numeric
irish_times_countries1$count <- as.numeric(irish_times_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_irish_times <- left_join(x = world2, 
                                       y = irish_times_countries1, 
                                       by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
irish_times_map <- combined_ref_irish_times %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "Irish Times (Ireland)") %>%
  add_column(source_country = "Ireland") %>%
  add_column(orientation = "Center left") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "Ireland")

write_csv(irish_times_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/irish_times_map.csv")


