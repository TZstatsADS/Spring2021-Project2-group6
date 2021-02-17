#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#-------------------------------------------------App Server----------------------------------


#can run RData directly to get the necessary date for the app
#global.r will enable us to get new data everyday
#update data with automated script
#source("global.R") 
#load('./output/covid-19.RData')
# Define server ----

shinyServer(function(input, output) {
        ####################### Tab 2 Map ##################
        map_base <-
                leaflet(options = leafletOptions(dragging = T, minZoom = 10, maxZoom = 16)) %>%
                setView(lng = -73.92,lat = 40.72, zoom = 11) %>% 
                addTiles() %>%
                addProviderTiles("CartoDB.Positron")
        
        # join zipcode geo with covid data from nyc_recent_4w_data
        nyc_zipcode_geo = nyc_zipcode_geo %>%
                left_join(nyc_neighborhoods, by = c("ZIPCODE"="MODIFIED_ZCTA")) %>%
                #left_join(nyc_recent_4w_data, by = c("ZIPCODE"="MODIFIED_ZCTA")) %>%
                left_join(nyc_7days_data, by = c("ZIPCODE"="modzcta")) %>%
                left_join(Business_closed, by = c("ZIPCODE"="zip"))
        
        pal <- colorFactor(
                palette = c('yellow', 'green', 'orange', 'red'), # 2134
                domain = nyc_zipcode_geo$depth
        )
        
        observe({
                output$nyc_map_covid = renderLeaflet({
                        
                        nyc_map_output = map_base %>% 
                                addPolygons( 
                                        data = nyc_zipcode_geo,
                                        weight = 0.5, color = "#41516C", fillOpacity = 0,
                                        popup = ~(paste0( 
                                                "<b>Zip Code: ",ZIPCODE ,
                                                "</b><br/>Borough: ",BOROUGH_GROUP,
                                                "<br/>Infection Rate: ", percentpositivity_7day,
                                                "<br/>Confirmed Cases: ", COVID_CASE_COUNT,
                                                "</br><b>Number of Business closed: ", no
                                        )),
                                        highlight = highlightOptions(
                                                weight = 2, color = "red", bringToFront = F) ) %>%
                                addCircleMarkers(
                                        data = nyc_zipcode_geo,
                                        lng = ~LNG_repre, lat = ~LAT_repre,
                                        color = ~pal(depth), fillOpacity = 0.7,
                                        radius = ~(COVID_CASE_COUNT)/200, 
                                        popup = ~(paste0(
                                                "<b>Zip Code: ", ZIPCODE,
                                                "<br/>Infection Rate: ", percentpositivity_7day,
                                                "</b><br/>Confirmed Cases: ", COVID_CASE_COUNT,
                                                "</br><b>Number of Business closed: ", no
                                        )),
                                        group = "Covid Cases"
                                )            
                }) # end of observe
                
                leafletProxy("nyc_map_covid")
                
        })
        # end of tab
        
        
        ####################### Tab 3 New Business ##################
        
         business_type_data <- reactive({
                if ( "retail" %in% input$business_type){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        business_type == "retail",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))) 
                }
                if ( "service" %in% input$business_type){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        business_type == "retail",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "food and beverage" %in% input$business_type){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        business_type == "retail",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "entertainment" %in% input$business_type){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        business_type == "retail",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
        })
        
        borough_data <- reactive({
                if ( "Manhattan" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        borough == "Manhattan",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))) 
                }
                if ( "Bronx" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        borough == "Bronx",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Brooklyn" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        borough == "Brooklyn",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Queens" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        borough == "Queens",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Staten Island" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", start_date) | grepl("2019", start_date), 
                                                        borough == "Staten Island",
                                                        NeworOld == "Application")
                        return(data %>% count(date = format(as.Date(start_date, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
        })
        
        output$tsPlot1 <- renderPlot({
                borough_data = borough_data()
                plot(n ~ as.Date(date), borough_data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2, 
                     ylab = "monthly new business", xlab = "",
                     main = paste("Number of new business created in ",  
                                  input$borough, " from 2019 to 2020"))
                abline(v = c(as.Date("2020/03/01","%Y/%m/%d"), 
                             as.Date("2020/06/01","%Y/%m/%d"),
                             as.Date("2020/07/01","%Y/%m/%d"),
                             as.Date("2020/09/01","%Y/%m/%d")), 
                       col = c("red","purple","green","blue"))
                legend("topright", legend=c("Non Essentials Stay Home", "Phase 1 & 2 Reopening",
                                            "Phase 2 & 3 Reopening", "Phase 4 Reopening"),
                       col=c("red","purple","green","blue"), lty=1, cex=0.8)
                axis.Date(1, at = borough_data$date, format= "%m-%Y", las = 1)
        })
        
        output$tsPlot2 <- renderPlot({
                business_type_data = business_type_data()
                plot(n ~ as.Date(date), business_type_data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2, 
                     ylab = "monthly new business", xlab = "",
                     main = paste("Number of ", 
                                  input$business_type, " business created in NYC from 2019 to 2020"))
                abline(v = c(as.Date("2020/03/01","%Y/%m/%d"), 
                             as.Date("2020/06/01","%Y/%m/%d"),
                             as.Date("2020/07/01","%Y/%m/%d"),
                             as.Date("2020/09/01","%Y/%m/%d")), 
                       col = c("red","purple","green","blue"))
                legend("topright", legend=c("Non Essentials Stay Home", "Phase 1 & 2 Reopening",
                                            "Phase 2 & 3 Reopening", "Phase 4 Reopening"),
                       col=c("red","purple","green","blue"), lty=1, cex=0.8)
                axis.Date(1, at = business_type_data$date, format= "%m-%Y", las = 1)
        })
        
        
        business_type_data_closed <- reactive({
                if ( "retail" %in% input$business_type){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "retail")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))) 
                }
                if ( "service" %in% input$business_type){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "service")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "food and beverage" %in% input$business_type){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "food_beverage")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "entertainment" %in% input$business_type){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "entertainment")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
        })
        
        borough_data_closed <- reactive({
                if ( "Manhattan" %in% input$borough){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Manhattan")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))) 
                }
                if ( "Bronx" %in% input$borough){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Bronx")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Brooklyn" %in% input$borough){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Brooklyn")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Queens" %in% input$borough){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Queens")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Staten Island" %in% input$borough){
                        data = business_data_closed %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Staten Island")
                        return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
        })
        
        output$tsPlot_closed_borough <- renderPlot({
                data = borough_data_closed()
                plot(n ~ as.Date(date), data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2, 
                     ylab = "monthly business closed", xlab = "",
                     main = paste("Number of  business closed in ",  input$borough, " from 2019 to 2020"))
                abline(v = c(as.Date("2020/03/01","%Y/%m/%d"), 
                             as.Date("2020/06/01","%Y/%m/%d"),
                             as.Date("2020/07/01","%Y/%m/%d"),
                             as.Date("2020/09/01","%Y/%m/%d")), 
                       col = c("red","purple","green","blue"))
                legend("topright", legend=c("Non Essentials Stay Home", "Phase 1 & 2 Reopening",
                                            "Phase 2 & 3 Reopening", "Phase 4 Reopening"),
                       col=c("red","purple","green","blue"), lty=1, cex=0.8)
                axis.Date(1, at = data$date, format= "%m-%Y", las = 1)
        })
        
        
        output$tsPlot_borough <- renderPlot({
                data = borough_sum
                matplot(t(borough_sum[,2:10]),type="b",lty=1:5,col=1:5,xlab = "years",ylab = "went out of business",main = paste("Business closed 5 boroughs"),pch=1,xaxt="n")+
                        axis(side=1,at=1:9,labels=c("2012","2013","2014","2015","2016","2017","2018","2019","2020"),cex.axis=0.6)
                legend(x="topright",legend= c("Bronx","Brooklyn","Manhattan","Queens","Staten Island"),lty=1:5,col=1:5,text.width = 1,cex=0.7)
        })
        #show data
        output$view <- renderTable({
                data = borough_sum_closed
                head(data, n = input$obs)
        })
        
        output$tsPlot_closed_business_type <- renderPlot({
                data = business_type_data_closed()
                plot(n ~ as.Date(date), data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2, ylab = "monthly new business", xlab = "",
                     main = paste("Number of ",  input$business_type, " business closed in NYC from 2019 to 2020"))
                abline(v = c(as.Date("2020/03/01","%Y/%m/%d"), 
                             as.Date("2020/06/01","%Y/%m/%d"),
                             as.Date("2020/07/01","%Y/%m/%d"),
                             as.Date("2020/09/01","%Y/%m/%d")), 
                       col = c("red","purple","green","blue"))
                legend("topright", legend=c("Non Essentials Stay Home", "Phase 1 & 2 Reopening",
                                            "Phase 2 & 3 Reopening", "Phase 4 Reopening"),
                       col=c("red","purple","green","blue"), lty=1, cex=0.8)
                axis.Date(1, at = data$date, format= "%m-%Y", las = 1)
        })
        
        
        output$tsPlot_business_type <- renderPlot({
                data = business_type_sum
                matplot(t(business_type_sum[,2:10]),type="b",lty=1:4,col=1:4,xlab = "years",ylab = "went out of business",main = paste("Business closed 4 business type"),pch=1,xaxt="n")+
                        axis(side=1,at=1:9,labels=c("2012","2013","2014","2015","2016","2017","2018","2019","2020"),cex.axis=0.6)
                legend(x="topright",legend= c("entertainment","food and beverage","retail","service"),lty=1:4,col=1:4,text.width = 1,cex=0.7)
        })
})
