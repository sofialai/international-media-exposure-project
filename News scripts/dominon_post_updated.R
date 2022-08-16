library(tidyverse)
library(dplyr)
library(tm)
library(leaflet)
library(pals)
library(htmlwidgets)
library(sf)
library(readr)

setwd("~/Documents/GitHub/data-project-world_media_international_coverage/Daily Scraping")

#Import dataset
dominion_post_headlines <- read_csv("./dominion_post_headlines.csv")

headlines <- nrow(dominion_post_headlines)

#Loaded dominion_post_headlines csv, then put words into one vector
dominion_post_string <- dominion_post_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

dominion_post_string <- removeWords(dominion_post_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(dominion_post_string, eng_countries)

#Make value into dataframe
dominion_post_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
dominion_post_countries1 <- cbind(eng_countries_full, dominion_post_countries)

#Make sure count is numeric
dominion_post_countries1$count <- as.numeric(dominion_post_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_dominion_post <- left_join(x = world2, 
                                   y = dominion_post_countries1, 
                                   by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
dominion_post_map <- combined_ref_dominion_post %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "Dominion Post (New Zealand)") %>%
  add_column(source_country = "New Zealand") %>%
  add_column(orientation = "Center left") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "New Zealand")

write_csv(dominion_post_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/dominion_post_map.csv")

