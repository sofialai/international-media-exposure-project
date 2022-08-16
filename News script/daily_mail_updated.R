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
daily_mail_headlines <- read_csv("./daily_mail_headlines.csv")

headlines <- nrow(daily_mail_headlines)

#Loaded daily_mail_headlines csv, then put words into one vector
daily_mail_string <- daily_mail_headlines %>%
  str_c(collapse = " ") %>%
  tolower() %>% 
  str_replace_all("[[:punct:]]", " ") %>%
  str_replace_all("[[:digit:]]", " ")

daily_mail_string <- removeWords(daily_mail_string, oman_words)

#Count number of matches between headlines and list of countries
count <- str_count(daily_mail_string, eng_countries)

#Make value into dataframe
daily_mail_countries <- data_frame(count)

#Combine this dataframe with countries dataframe (see: eng_countries script)
daily_mail_countries1 <- cbind(eng_countries_full, daily_mail_countries)

#Make sure count is numeric
daily_mail_countries1$count <- as.numeric(daily_mail_countries1$count)

#left_join dataframes: countries2 and world3 (see world_shape_df script)
combined_ref_daily_mail <- left_join(x = world2, 
                                        y = daily_mail_countries1, 
                                        by = "ADMIN2")

#Combine all country reference information into single values (ie aghani + anghan => Afghanistan)
daily_mail_map <- combined_ref_daily_mail %>%
  group_by(ADMIN2, CONTINENT, INCOME_GRP) %>%
  summarise(count = sum(count)) %>%
  mutate(rate = (count/headlines)*100) %>%
  add_column(source = "Daily Mail (UK)") %>%
  add_column(source_country = "United Kingdom") %>%
  add_column(orientation = "Center right") %>%
  dplyr::filter(count > 0) %>%
  filter(ADMIN2 != "Republic of the Congo") %>%
  filter(ADMIN2 != "Aland") %>%
  filter(ADMIN2 != "United Kingdom")

write_csv(daily_mail_map, "~/Documents/GitHub/data-project-world_media_international_coverage/News source df's/daily_mail_map.csv")

