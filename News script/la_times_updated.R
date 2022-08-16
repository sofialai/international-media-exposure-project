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
la_times_headlines <- read_csv("./la_times_headlines.csv")

headlines <- nrow(la_times_headlines)

#Loaded la_times_headlines csv, then put words into one vector
la_times_string <- la_times_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

la_times_string <- removeWords(la_times_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(la_times_string, eng_countries)

#Make value into dataframe
la_times_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
la_times_countries1 <- cbind(eng_countries_full, la_times_countries)

#Make sure count is numeric
la_times_countries1$count <- as.numeric(la_times_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_la_times <- left_join(x = world2, 
                                     y = la_times_countries1, 
                                     by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
la_times_map <- combined_ref_la_times %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "LA Times (USA)") %>%
  add_column(source_country = "United States of America") %>%
  add_column(orientation = "Center left") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "United States of America")

write_csv(la_times_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/la_times_map.csv")