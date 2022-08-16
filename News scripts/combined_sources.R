library(htmltools)
library(htmlwidgets)
library(leaflet)
library(sf)

combined_sources <- rbind(dominion_post_map, figaro_map, fox_news_map,
                          guardian_map, irish_independent_map, 
                          irish_times_map,
                          nz_herald_map)

setwd("~/Documents/GitHub/Final_Data_Science_Project/media_dashboard")

write_csv(combined_sources, "~/Documents/GitHub/Final_Data_Science_Project/media_dashboard/news_source_shiny/combined_sources.csv")

saveRDS(combined_sources, "combined_sources.RDS")








