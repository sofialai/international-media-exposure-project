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
guardian_headlines <- read_csv("guardian_headlines.csv")

headlines <- nrow(guardian_headlines)

#Loaded guardian_headlines csv, then put words into one vector
guardian_string <- guardian_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

guardian_string <- removeWords(guardian_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(guardian_string, eng_countries)

#Make value into dataframe
guardian_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
guardian_countries1 <- cbind(eng_countries_full, guardian_countries)

#Make sure count is numeric
guardian_countries1$count <- as.numeric(guardian_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_guardian <- left_join(x = world2, 
                                   y = guardian_countries1, 
                                   by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
guardian_map <- combined_ref_guardian %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "The Guardian (UK)") %>%
  add_column(source_country = "United Kingdom") %>%
  add_column(orientation = "Center left") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "United Kingdom")

write_csv(guardian_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/guardian_map.csv")


