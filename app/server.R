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
        
        
        business_type_data <- reactive({
                if ( "retail" %in% input$business_type){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), business_type == "retail")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))) 
                }
                if ( "service" %in% input$business_type){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), business_type == "service")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "food and beverage" %in% input$business_type){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), business_type == "food_beverage")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "entertainment" %in% input$business_type){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), business_type == "entertainment")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
        })
        
        borough_data <- reactive({
                if ( "Manhattan" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), borough == "Manhattan")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))) 
                }
                if ( "Bronx" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), borough == "Bronx")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Brooklyn" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), borough == "Brooklyn")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Queens" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), borough == "Queens")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
                if ( "Staten Island" %in% input$borough){
                        data = business_data %>% filter(grepl("2020", creation) | grepl("2019", creation), borough == "Staten Island")
                        return(data %>% count(date = format(as.Date(creation, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
                }
        })
        
        output$tsPlot1 <- renderPlot({
                data = borough_data()
                plot(n ~ as.Date(date), data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2, 
                     ylab = "monthly new business", xlab = "",
                     main = paste("Number of new business created in ",  
                                  input$borough, " from 2019 to 2020"))
                axis.Date(1, at = data$date, format= "%m-%Y", las = 1)
        })
        
        output$tsPlot2 <- renderPlot({
                data = business_type_data()
                plot(n ~ as.Date(date), data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2, 
                     ylab = "monthly new business", xlab = "",
                     main = paste("Number of ", 
                                  input$business_type, " business created in NYC from 2019 to 2020"))
                axis.Date(1, at = data$date, format= "%m-%Y", las = 1)
        })
})
