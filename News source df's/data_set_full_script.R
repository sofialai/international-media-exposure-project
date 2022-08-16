library(tidyverse)
library(haven)
library(maptools)

setwd("~/Documents/GitHub/Final_Data_Science_Project/News source df's")

daily_mail_df <- read_csv("daily_mail_map.csv")
dominion_post_df <- read_csv("dominion_post_map.csv")
figaro_df<- read_csv("figaro_map.csv")
fox_news_df<- read_csv("fox_news_map.csv")
guardian_df<- read_csv("guardian_map.csv")
hindu_df <- read_csv("hindu_map.csv")
india_times_df <- read_csv("india_times_map.csv")
irish_independent_df <- read_csv("irish_independent_map.csv")
irish_times_df <- read_csv("irish_times_map.csv")
la_times_df<- read_csv("la_times_map.csv")
le_monde_df<- read_csv("le_monde_map.csv")
nz_herald_df<- read_csv("nz_herald_map.csv")
spiegel_df<- read_csv("spiegel_map.csv")
sz_df <- read_csv("sz_map.csv")

data_set_full <- rbind(daily_mail_df, 
                       dominion_post_df, 
                       figaro_df,
                       fox_news_df,
                       guardian_df, 
                       hindu_df, 
                       india_times_df,
                       irish_independent_df, 
                       irish_times_df,
                       la_times_df,
                       le_monde_df, 
                       nz_herald_df, 
                       spiegel_df, 
                       sz_df)

data_set_full <- data_set_full %>%
  select(-one_of('geometry'))

write_csv(data_set_full, "~/Documents/GitHub/Final_Data_Science_Project/News source df's/data_set_full.csv")
