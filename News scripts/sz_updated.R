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
sz_headlines <- read_csv("sz_headlines.csv")

headlines <- nrow(sz_headlines)

#Loaded sz_headlines csv, then put words into one vector
sz_string <- sz_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

sz_string <- removeWords(sz_string, oman_words)

sz_string

#Count number of matches between headlines and list of countries
count <- str_count(sz_string, ger_countries)

#Make value into dataframe
sz_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
sz_countries1 <- cbind(ger_countries_full, sz_countries)

#Make sure count is numeric
sz_countries1$count <- as.numeric(sz_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_sz <- left_join(x = world2, 
                                   y = sz_countries1, 
                                   by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
sz_map <- combined_ref_sz %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "Süddeutsche Zeitung (Germany)") %>%
  add_column(source_country = "Germany") %>%
  add_column(orientation = "Center left") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "Germany")

write_csv(sz_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/sz_map.csv")

