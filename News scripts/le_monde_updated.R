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
le_monde_headlines <- read_csv("le_monde_headlines.csv")

headlines <- nrow(le_monde_headlines)

#Loaded le_monde_headlines csv, then put words into one vector
le_monde_string <- le_monde_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

le_monde_string <- removeWords(le_monde_string, oman_words)

le_monde_string

#Count number of matches between headlines and list of countries
count <- str_count(le_monde_string, fr_countries)

#Make value into dataframe
le_monde_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
le_monde_countries1 <- cbind(fr_countries_full, le_monde_countries)

#Make sure count is numeric
le_monde_countries1$count <- as.numeric(le_monde_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_le_monde <- left_join(x = world2, 
                                       y = le_monde_countries1, 
                                       by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
le_monde_map <- combined_ref_le_monde %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "Le Monde (France)") %>%
  add_column(source_country = "France") %>%
  add_column(orientation = "Center left") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "France")

write_csv(le_monde_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/le_monde_map.csv")
