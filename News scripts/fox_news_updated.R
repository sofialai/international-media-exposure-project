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
fox_news_headlines <- read_csv("fox_news_headlines.csv")

headlines <- nrow(fox_news_headlines)

#Loaded fox_news_headlines csv, then put words into one vector
fox_news_string <- fox_news_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ") 

fox_news_string <- removeWords(fox_news_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(fox_news_string, eng_countries)

#Make value into dataframe
fox_news_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
fox_news_countries1 <- cbind(eng_countries_full, fox_news_countries)

#Make sure count is numeric
fox_news_countries1$count <- as.numeric(fox_news_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_fox_news <- left_join(x = world2, 
                                    y = fox_news_countries1, 
                                    by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
fox_news_map <- combined_ref_fox_news %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "Fox News (USA)") %>%
  add_column(source_country = "United States of America") %>%
  add_column(orientation = "Center right") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "United States of America")

write_csv(fox_news_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/fox_news_map.csv")


