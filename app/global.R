knitr::opts_chunk$set(echo = TRUE)
# load packages needed
require(tidyverse)
require(dplyr)
require(lubridate)
setwd("C:/Users/liqia/Spring2021-Project2-group-6/data") 
lic = read_csv("License_Applications.csv")
legal_b = read_csv("Legally_Operating_Businesses.csv")
str(lic)
str(legal_b)
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
  select(ID, name = `Business Name`, new_renewl = `Application or Renewal`, start_date = `Start Date`,end_date = `End Date`, business_type, license_cate = `License Category`, zip = Zip) %>%
  drop_na()
str(licence_app)
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

<<<<<<< HEAD
date = legal_business %>% filter(status == "Active") %>% mutate(expiration = mdy(expiration)) %>% select(expiration)
summary(date)
business_data = left_join(legal_business, licence_app) %>% distinct(ID, .keep_all = TRUE)%>% filter(status == "Inactive")

close_bus_reta = business_data  %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "retail")
close_bus_serv = business_data  %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "service")
close_bus_f_b = business_data  %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "food_beverage")
close_bus_ent = business_data  %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "entertainment")
data = business_data  %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Staten Island")
data = data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))
plot(data$n, type = "o", pch = 22, lty = 1, pty = 2, 
     ylab = "monthly closed business", 
     main = "Business closed by month from 2019 to 2020")
axis.Date(1, at=seq(as.Date("01-01-2019"), as.Date("12-01-2020"), by="months"), format="%m-%Y")
plot(n ~ as.Date(date), data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2)
axis.Date(1, at = data$date, format= "%m-%Y", las = 1)
=======
#join 2 business data
#join 2 business data
business_data = left_join(legal_business, licence_app) %>% distinct(ID, .keep_all = TRUE)


######## ----------- NYC business data NEEDED ---------------~####

Business_closed <- business_data %>% filter(status == "Inactive") %>% 
  filter(grepl("2020",expiration)) %>%
  select(name, business_type, borough, zip, expiration) %>%
  group_by(zip=as.integer(zip)) %>%
  summarize(no=n()) %>%
  mutate(depth= ifelse(no <= 9, "light", 
                       ifelse(no <= 32 & no >9, "intermediate", 
                              ifelse(no > 32 & no <= 50 , "serious", "very serious"))))

>>>>>>> 35dfe6585ddf0921397673764bee3c43853a2166


