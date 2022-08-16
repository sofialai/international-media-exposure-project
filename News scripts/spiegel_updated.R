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
spiegel_headlines <- read_csv("spiegel_headlines.csv")

headlines <- nrow(spiegel_headlines)

#Loaded spiegel_headlines csv, then put words into one vector
spiegel_string <- spiegel_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

spiegel_string <- removeWords(spiegel_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(spiegel_string, ger_countries)

#Make value into dataframe
spiegel_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
spiegel_countries1 <- cbind(ger_countries_full, spiegel_countries)

#Make sure count is numeric
spiegel_countries1$count <- as.numeric(spiegel_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_spiegel <- left_join(x = world2, 
                                 y = spiegel_countries1, 
                                 by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
spiegel_map <- combined_ref_spiegel %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "Der Spiegel (Germany)") %>%
  add_column(source_country = "Germany") %>%
  add_column(orientation = "Center left") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "Germany")

write_csv(spiegel_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/spiegel_map.csv")

