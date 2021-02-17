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

require(lubridate)

library(httr)
library(rvest)
library(stringr)
library(jsonlite)
#--------------------------------------------------------------------

############################### NYC map data ###############################
# Data Sources
#   nyc Health data
#
# get NYC covid data based on Modified Zip code
# First get ZCTA (zip code) to MODZCTA data:

zcta_to_modzcta <- read.csv( "https://raw.githubusercontent.com/nychealth/coronavirus-data/master/Geography-resources/ZCTA-to-MODZCTA.csv" )

# NYC Covid data by MODZCTA(cummulative):

data_by_modzcta <- read.csv( 'https://raw.githubusercontent.com/nychealth/coronavirus-data/master/totals/data-by-modzcta.csv' )

# get data by nyc neighborhoods
#----  total cases, death, total covid tests by each neighborhood
nyc_neighborhoods <- data_by_modzcta %>%
  select(
    "MODIFIED_ZCTA","NEIGHBORHOOD_NAME", 
    "BOROUGH_GROUP", "COVID_CASE_COUNT", 
    "COVID_CASE_RATE", "PERCENT_POSITIVE", "COVID_DEATH_COUNT",
    "TOTAL_COVID_TESTS"
  )

# import geojson file from NYC open data
nyc_zipcode_geo <- sf::st_read("./output/ZIP_CODE_040114/ZIP_CODE_040114.shp") %>%
  sf::st_transform('+proj=longlat +datum=WGS84')
nyc_zipcode_geo$ZIPCODE <- type.convert(nyc_zipcode_geo$ZIPCODE)

# import longitude and latitude data
nyc_lat_data <- read.csv("./output/zc_geo.csv", sep= ";")

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

nyc_recent_4w_cases <- read.csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/archive/recent-4-week-by-modzcta.csv")

# recent_use_dat
nyc_recent_4w_data <- nyc_recent_4w_cases %>%
  select("MODIFIED_ZCTA","NEIGHBORHOOD_NAME","COVID_CASE_RATE_WEEK4",
         "COVID_CASE_RATE_WEEK3","COVID_CASE_RATE_WEEK2","COVID_CASE_RATE_WEEK1",
         "PERCENT_POSITIVE_4WEEK" )

#data for positive rate in the last 7 days

nyc_7days_masterdata <- read.csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/latest/last7days-by-modzcta.csv")

#7 days data that will be used
nyc_7days_data <- nyc_7days_masterdata %>% 
  select("modzcta", "modzcta_name", "percentpositivity_7day", 
         "median_daily_test_rate")

#data by day (death, confirmed cases, hospitalization) NOT CONCERNING ZIP CODE
#----- Confirmed Cases--------

cases_by_day_masterdata <- read.csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/cases-by-day.csv")

#confirmed cases by day and by borough if needed
cases_by_day_data <- cases_by_day_masterdata %>%
  select("date_of_interest", "CASE_COUNT", "BX_CASE_COUNT", "BK_CASE_COUNT",
         "MN_CASE_COUNT", "QN_CASE_COUNT", "SI_CASE_COUNT")

#death by day and borough if needed

death_by_day_masterdata <- read.csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/deaths-by-day.csv")

death_by_day_data <- death_by_day_masterdata %>%
  select("date_of_interest", "DEATH_COUNT", "BX_DEATH_COUNT",
         "BK_DEATH_COUNT", "MN_DEATH_COUNT", "QN_DEATH_COUNT")

#hospitalization by day and borough if needed

hosp_by_day_masterdata <- read.csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/trends/hosp-by-day.csv")

hosp_by_day_data <- hosp_by_day_masterdata %>%
  select("date_of_interest", "HOSPITALIZED_COUNT", "BX_HOSPITALIZED_COUNT", 
         "BK_HOSPITALIZED_COUNT", "MN_HOSPITALIZED_COUNT", 
         "QN_HOSPITALIZED_COUNT", "SI_HOSPITALIZED_COUNT")

#Data by race and sex and borough (cumulative)
racesex_data_master <- as.data.frame(read.csv("https://raw.githubusercontent.com/nychealth/coronavirus-data/master/totals/group-data-by-boro.csv"))
racesex_data <- racesex_data_master[c(0,13:18), ]



#######-----------------NYC Business ---------------------#################

lic <-  read_csv("./data/License_Applications.csv")
legal_b <-  read_csv("./data/Legally_Operating_Businesses.csv")

str(lic)
str(legal_b)

# group License application data into 4 industries
lic%>%count(`License Category`, sort = TRUE)
licence_app = lic %>% mutate(business_type = ifelse(grepl("Cafe", `License Category`), "food_beverage", 
                                                    ifelse(grepl("Catering", `License Category`), "food_beverage",
                                                           ifelse(grepl("Amusement", `License Category`), "entertainment",
                                                                  ifelse(grepl("Games", `License Category`), "entertainment",
                                                                         ifelse(grepl("Cabaret", `License Category`), "entertainment",
                                                                                ifelse(grepl("Pool", `License Category`), "entertainment",
                                                                                       ifelse(grepl("Improvement", `License Category`), "service", ifelse(grepl("Sightseeing", `License Category`), "service", ifelse(grepl("Picture", `License Category`), "service", ifelse(grepl("Laundr", `License Category`), "service", ifelse(grepl("Locksmith", `License Category`), "service", ifelse(grepl("Serv", `License Category`), "service", ifelse(grepl("Agency", `License Category`), "service", ifelse(grepl("Garage", `License Category`), "service", ifelse(grepl("Driver", `License Category`), "service", ifelse(grepl("Business", `License Category`), "service", ifelse(grepl("Company", `License Category`), "service", ifelse(grepl("Wash", `License Category`), "service", ifelse(grepl("Tow", `License Category`), "service", ifelse(grepl("Parking", `License Category`), "service", ifelse(grepl("Auction", `License Category`), "service", ifelse(grepl("Pawnbroker", `License Category`), "service", ifelse(grepl("Processor", `License Category`), "service", ifelse(grepl("Owner", `License Category`), "service", ifelse(grepl("Repair", `License Category`), "service", ifelse(grepl("Lessor", `License Category`), "service", ifelse(grepl("Distributor", `License Category`), "service", ifelse(grepl("Storage", `License Category`), "service", "retail")))))))))))))))))))))))))))),
                             ID = gsub("-DCA" , "" ,`License Number`)) %>%
  filter(State == "NY") %>%
  select(ID, name = `Business Name`, NeworOld= `Application or Renewal`, end_date = `End Date`, start_date = `Start Date`, business_type, license_cate = `License Category`, zip = Zip) %>%
  drop_na()
str(licence_app)
#head(licence_app)

#group legal business data into 4 industries

legal_business = legal_b %>% mutate(business_type = ifelse(grepl("Cafe", `Industry`), "food_beverage", 
                                                           ifelse(grepl("Catering", `Industry`), "food_beverage",
                                                                  ifelse(grepl("Amusement", `Industry`), "entertainment",
                                                                         ifelse(grepl("Games", `Industry`), "entertainment",
                                                                                ifelse(grepl("Cabaret", `Industry`), "entertainment",
                                                                                       ifelse(grepl("Pool", `Industry`), "entertainment",
                                                                                              ifelse(grepl("Improvement", `Industry`), "service", ifelse(grepl("Sightseeing", `Industry`), "service", ifelse(grepl("Picture", `Industry`), "service", ifelse(grepl("Laundr", `Industry`), "service", ifelse(grepl("Locksmith", `Industry`), "service", ifelse(grepl("Serv", `Industry`), "service", ifelse(grepl("Agency", `Industry`), "service", ifelse(grepl("Garage", `Industry`), "service", ifelse(grepl("Driver", `Industry`), "service", ifelse(grepl("Business", `Industry`), "service", ifelse(grepl("Company", `Industry`), "service", ifelse(grepl("Wash", `Industry`), "service", ifelse(grepl("Tow", `Industry`), "service", ifelse(grepl("Parking", `Industry`), "service", ifelse(grepl("Auction", `Industry`), "service", ifelse(grepl("Pawnbroker", `Industry`), "service", ifelse(grepl("Processor", `Industry`), "service", ifelse(grepl("Owner", `Industry`), "service", ifelse(grepl("Repair", `Industry`), "service", ifelse(grepl("Lessor", `Industry`), "service", ifelse(grepl("Distributor", `Industry`), "service", ifelse(grepl("Storage", `Industry`), "service", "retail")))))))))))))))))))))))))))),
                                    ID = gsub("-DCA" , "" ,`DCA License Number`),
                                    `Borough Code` = ifelse(`Borough Code` == 1, "Manhattan",
                                                            ifelse(`Borough Code` == 2, "Bronx",
                                                                   ifelse(`Borough Code` == 3, "Brooklyn",
                                                                          ifelse(`Borough Code` == 4, "Queens",
                                                                                 ifelse(`Borough Code` == 5, "Staten Island", NA)))))) %>%
  filter(`Address State` == "NY") %>%
  select(ID, name = `Business Name`, status = `License Status`, creation = `License Creation Date`, expiration = `License Expiration Date`, business_type, licence_cate = Industry, borough = `Borough Code`, zip = `Address ZIP`) %>%
  drop_na()
str(legal_business)
date = legal_business %>% filter(status == "Active") %>% 
  mutate(expiration = mdy(expiration)) %>% 
  select(expiration)

#join 2 business data
#join 2 business data
business_data = left_join(legal_business, licence_app) %>% distinct(ID, .keep_all = TRUE)

business_data_closed = left_join(legal_business, licence_app) %>% distinct(ID, .keep_all = TRUE)%>% filter(status == "Inactive")
######## ----------- NYC business data NEEDED ---------------~####

business_type_sum_2022= business_data_closed%>%filter(grepl("2022", expiration)) %>% group_by(business_type) %>% summarise("2022"=n())
business_type_sum_2021= business_data_closed%>%filter(grepl("2021", expiration)) %>% group_by(business_type) %>% summarise("2021"=n())
business_type_sum_2019= business_data_closed%>%filter(grepl("2019", expiration)) %>% group_by(business_type) %>% summarise("2019"=n())
business_type_sum_2020= business_data_closed%>%filter(grepl("2020", expiration)) %>% group_by(business_type) %>% summarise("2020"=n())
business_type_sum_2018= business_data_closed%>%filter(grepl("2018", expiration)) %>% group_by(business_type) %>% summarise("2018"=n())
business_type_sum_2017= business_data_closed%>%filter(grepl("2017", expiration)) %>% group_by(business_type) %>% summarise("2017"=n())
business_type_sum_2016= business_data_closed%>%filter(grepl("2016", expiration)) %>% group_by(business_type) %>% summarise("2016"=n())
business_type_sum_2015= business_data_closed%>%filter(grepl("2015", expiration)) %>% group_by(business_type) %>% summarise("2015"=n())
business_type_sum_2014= business_data_closed%>%filter(grepl("2014", expiration)) %>% group_by(business_type) %>% summarise("2014"=n())
business_type_sum_2013= business_data_closed%>%filter(grepl("2013", expiration)) %>% group_by(business_type) %>% summarise("2013"=n())
business_type_sum_2012= business_data_closed%>%filter(grepl("2012", expiration)) %>% group_by(business_type) %>% summarise("2012"=n())

business_type_sum1 = left_join(business_type_sum_2021,business_type_sum_2022)
business_type_sum2 = left_join(business_type_sum_2020,business_type_sum1)
business_type_sum3 = left_join(business_type_sum_2019,business_type_sum2)
business_type_sum4 = left_join(business_type_sum_2018,business_type_sum3)
business_type_sum5 = left_join(business_type_sum_2017,business_type_sum4)
business_type_sum6 = left_join(business_type_sum_2016,business_type_sum5)
business_type_sum7 = left_join(business_type_sum_2015,business_type_sum6)
business_type_sum8 = left_join(business_type_sum_2014,business_type_sum7)
business_type_sum9 = left_join(business_type_sum_2013,business_type_sum8)
business_type_sum = left_join(business_type_sum_2012,business_type_sum9)
years = c("2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022")
t1 <- t(data.frame(business_type_sum,row.names=1))
t2 <- as.data.frame(t1,row.names=F)
business_type_sum_closed <- as.data.frame(cbind(years,t2))
business_type_sum_closed

a = t(business_type_sum[,2:10])  
#matplot(a,type="b",lty=1:4,col=1:4,xlab = "years",ylab = "went out of business",pch=1,xaxt="n")+
#    axis(side=1,at=1:9,labels=c("2012","2013","2014","2015","2016","2017","2018","2019","2020"),cex.axis=0.6)+
# legend(x="topright",legend= c("retail","service","food and beverage","entertainment"),lty=1:4,col=1:4,text.width = 1,cex=0.7)

borough_sum_2022= business_data_closed%>%filter(grepl("2022", expiration)) %>% group_by(borough) %>% summarise("2022"=n())
borough_sum_2021= business_data_closed%>%filter(grepl("2021", expiration)) %>% group_by(borough) %>% summarise("2021"=n())
borough_sum_2019= business_data_closed%>%filter(grepl("2019", expiration)) %>% group_by(borough) %>% summarise("2019"=n())
borough_sum_2020= business_data_closed%>%filter(grepl("2020", expiration)) %>% group_by(borough) %>% summarise("2020"=n())
borough_sum_2018= business_data_closed%>%filter(grepl("2018", expiration)) %>% group_by(borough) %>% summarise("2018"=n())
borough_sum_2017= business_data_closed%>%filter(grepl("2017", expiration)) %>% group_by(borough) %>% summarise("2017"=n())
borough_sum_2016= business_data_closed%>%filter(grepl("2016", expiration)) %>% group_by(borough) %>% summarise("2016"=n())
borough_sum_2015= business_data_closed%>%filter(grepl("2015", expiration)) %>% group_by(borough) %>% summarise("2015"=n())
borough_sum_2014= business_data_closed%>%filter(grepl("2014", expiration)) %>% group_by(borough) %>% summarise("2014"=n())
borough_sum_2013= business_data_closed%>%filter(grepl("2013", expiration)) %>% group_by(borough) %>% summarise("2013"=n())
borough_sum_2012= business_data_closed%>%filter(grepl("2012", expiration)) %>% group_by(borough) %>% summarise("2012"=n())

borough_sum1 = left_join(borough_sum_2021,borough_sum_2022)
borough_sum2 = left_join(borough_sum_2020,borough_sum1)
borough_sum3 = left_join(borough_sum_2019,borough_sum2)
borough_sum4 = left_join(borough_sum_2018,borough_sum3)
borough_sum5 = left_join(borough_sum_2017,borough_sum4)
borough_sum6 = left_join(borough_sum_2016,borough_sum5)
borough_sum7 = left_join(borough_sum_2015,borough_sum6)
borough_sum8 = left_join(borough_sum_2014,borough_sum7)
borough_sum9 = left_join(borough_sum_2013,borough_sum8)
borough_sum = left_join(borough_sum_2012,borough_sum9)

years = c("2012","2013","2014","2015","2016","2017","2018","2019","2020","2021","2022")
t3 <- t(data.frame(borough_sum,row.names=1))
t4 <- as.data.frame(t3,row.names=F)
borough_sum_closed <- as.data.frame(cbind(years,t4))
borough_sum_closed

Business_closed <- business_data %>% filter(status == "Inactive") %>% 
  filter(grepl("2020",expiration)) %>%
  select(name, business_type, borough, zip, expiration) %>%
  group_by(zip=as.integer(zip)) %>%
  summarize(no=n()) %>%
  mutate(depth= ifelse(no <= 9, "light", 
                       ifelse(no <= 32 & no >9, "intermediate", 
                              ifelse(no > 32 & no <= 50 , "serious", "very serious"))))
