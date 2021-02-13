#--------------------------------------------------------------------
###############################Install Related Packages #######################
if (!require("dplyr")) {
  install.packages("dplyr")
  library(dplyr)
}
if (!require("tibble")) {
  install.packages("tibble")
  library(tibble)
}
if (!require("tidyverse")) {
  install.packages("tidyverse")
  library(tidyverse)
}
if (!require("shinythemes")) {
  install.packages("shinythemes")
  library(shinythemes)
}

if (!require("sf")) {
  install.packages("sf")
  library(sf)
}
if (!require("RCurl")) {
  install.packages("RCurl")
  library(RCurl)
}
if (!require("tmap")) {
  install.packages("tmap")
  library(tmap)
}
if (!require("rgdal")) {
  install.packages("rgdal")
  library(rgdal)
}
if (!require("leaflet")) {
  install.packages("leaflet")
  library(leaflet)
}
if (!require("shiny")) {
  install.packages("shiny")
  library(shiny)
}
if (!require("shinythemes")) {
  install.packages("shinythemes")
  library(shinythemes)
}
if (!require("plotly")) {
  install.packages("plotly")
  library(plotly)
}
if (!require("ggplot2")) {
  install.packages("ggplot2")
  library(ggplot2)
}
if (!require("viridis")) {
  install.packages("viridis")
  library(viridis)
}
#--------------------------------------------------------------------

############################### NYC map data ###############################
# Data Sources
#   nyc Health data
#
# get NYC covid data based on Modified Zip code
# First get ZCTA (zip code) to MODZCTA data:
zcta_to_modzctaURL <- getURL("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/Geography-resources/ZCTA-to-MODZCTA.csv")
zcta_to_modzcta <- read.csv( text=zcta_to_modzctaURL )

# NYC Covid data by MODZCTA(cummulative):
data_by_modzctaURL <- getURL('https://raw.githubusercontent.com/nychealth/coronavirus-data/master/totals/data-by-modzcta.csv')
data_by_modzcta <- read.csv( text=data_by_modzctaURL )

# get data by nyc neighborhoods
#----  total cases, death, total covid tests by each neighborhood
nyc_neighborhoods <- data_by_modzcta %>%
  select(
    "MODIFIED_ZCTA","NEIGHBORHOOD_NAME", 
    "BOROUGH_GROUP", "COVID_CASE_COUNT", 
    "COVID_CASE_RATE", "PERCENT_POSITIVE", "COVID_DEATH_COUNT",
    "TOTAL_COVID_TEST"
  )

# import geojson file from NYC open data
nyc_zipcode_geo <- sf::st_read("./output/ZIP_CODE_040114/ZIP_CODE_040114.shp") %>%
  sf::st_transform('+proj=longlat +datum=WGS84')
nyc_zipcode_geo$ZIPCODE <- type.convert(nyc_zipcode_geo$ZIPCODE)

# import longitude and latitude data
nyc_lat_data <- read.csv("../data/zc_geo.csv", sep= ";")

nyc_lat_table<-nyc_lat_data %>%
  select("Zip", "Latitude", "Longitude")

# match zipcode with longitude and latitude data and merge new data
nyc_neighborhoods <- nyc_neighborhoods %>%
  mutate(
    LAT_repre = nyc_lat_data$Latitude[
      match(nyc_neighborhoods$MODIFIED_ZCTA, nyc_lat_data$Zip) ]
  ) %>%
  mutate(
    LNG_repre = nyc_lat_data$Longitude[ 
      match(nyc_neighborhoods$MODIFIED_ZCTA, nyc_lat_data$Zip) ]
  )

# data for line chart and positive rate
nyc_recent_4w_URL <- getURL("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/archive/recent-4-week-by-modzcta.csv")
nyc_recent_4w_cases <- read.csv(text = nyc_recent_4w_URL)

# recent_use_dat
nyc_recent_4w_data <- nyc_recent_4w_cases %>%
  select("MODIFIED_ZCTA","NEIGHBORHOOD_NAME","COVID_CASE_RATE_WEEK4",
         "COVID_CASE_RATE_WEEK3","COVID_CASE_RATE_WEEK2","COVID_CASE_RATE_WEEK1",
         "PERCENT_POSITIVE_4WEEK" )

#data for positive rate in the last 7 days
nyc_7days_URL <-getURL("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/latest/last7days-by-modzcta.csv")
nyc_7days_masterdata <- read.csv(text=nyc_7days_URL)

#7 days data that will be used
nyc_7days_data <- nyc_7days_masterdata %>% 
  select("modzcta", "modzcta_name", "percentpositivity_7day", 
         "median_daily_test_rate")

#data by day (death, confirmed cases, hospitalization) NOT CONCERNING ZIP CODE
#----- Confirmed Cases--------
cases_by_day_URL <- getURL("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/cases-by-day.csv")
cases_by_day_masterdata <- read.csv(text=cases_by_day_URL)

#confirmed cases by day and by borough if needed
cases_by_day_data <- cases_by_day_masterdata %>%
  select("date_of_interest", "CASE_COUNT", "BX_CASE_COUNT", "BK_CASE_COUNT",
         "MN_CASE_COUNT", "QN_CASE_COUNT", "SI_CASE_COUNT")

#death by day and borough if needed
death_by_day_URL <- getURL("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/deaths-by-day.csv")
death_by_day_masterdata <- read.csv(text=death_by_day_URL)

death_by_day_data <- death_by_day_masterdata %>%
  select("date_of_interest", "DEATH_COUNT", "BX_DEATH_COUNT",
         "BK_DEATH_COUNT", "MN_DEATH_COUNT", "QN_DEATH_COUNT")

#hospitalization by day and borough if needed
hosp_by_day_URL <- getURL("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/hosp-by-day.csv")
hosp_by_day_masterdata <- read.csv(text=hosp_by_day_URL)

hosp_by_day_data <- hosp_by_day_masterdata %>%
  select("date_of_interest", "HOSPITALIZED_COUNT", "BX_HOSPITALIZED_COUNT", 
         "BK_HOSPITALIZED_COUNT", "MN_HOSPITALIZED_COUNT", 
         "QN_HOSPITALIZED_COUNT", "SI_HOSPITALIZED_COUNT")

#Data by race and sex and borough (cumulative)
racesex_data_URL <- getURL("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/totals/group-data-by-boro.csv")
racesex_data_master <- as.data.frame(read.csv(text=racesex_data_URL))
racesex_data <- racesex_data_master[c(0,13:18), ]





                                              