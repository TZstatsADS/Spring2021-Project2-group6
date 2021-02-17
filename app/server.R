#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
# Define server ----
server <- function(input, output) {
    
    business_type_data <- reactive({
        if ( "retail" %in% input$business_type){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "retail")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))) 
        }
        if ( "service" %in% input$business_type){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "service")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
        }
        if ( "food and beverage" %in% input$business_type){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "food_beverage")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
        }
        if ( "entertainment" %in% input$business_type){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), business_type == "entertainment")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
        }
    })
    
    borough_data <- reactive({
        if ( "Manhattan" %in% input$borough){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Manhattan")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = ""))) 
        }
        if ( "Bronx" %in% input$borough){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Bronx")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
        }
        if ( "Brooklyn" %in% input$borough){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Brooklyn")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
        }
        if ( "Queens" %in% input$borough){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Queens")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
        }
        if ( "Staten Island" %in% input$borough){
            data = business_data %>% filter(grepl("2020", expiration) | grepl("2019", expiration), borough == "Staten Island")
            return(data %>% count(date = format(as.Date(expiration, format = "%m/%d/%Y"), "%Y/%m")) %>% mutate(date = paste(date,"/01", sep = "")))
        }
    })
    
    output$tsPlot1 <- renderPlot({
        data = borough_data()
        plot(n ~ as.Date(date), data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2, 
             ylab = "monthly business closed", xlab = "",
             main = paste("Number of  business closed in ",  input$borough, " from 2019 to 2020"))
        axis.Date(1, at = data$date, format= "%m-%Y", las = 1)
    })
    
    output$tsPlot2 <- renderPlot({
        data = business_type_data()
        plot(n ~ as.Date(date), data, xaxt = "n", type = "o", pch = 22, lty = 1, pty = 2, ylab = "monthly new business", xlab = "",
             main = paste("Number of ",  input$business_type, " business closed in NYC from 2019 to 2020"))
        axis.Date(1, at = data$date, format= "%m-%Y", las = 1)
    })
}


