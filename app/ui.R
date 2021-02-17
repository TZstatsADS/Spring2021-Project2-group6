

#load('./output/covid-19.RData')
library(viridis)
library(dplyr)
library(tibble)
library(tidyverse)
library(shinythemes)
library(sf)
library(RCurl)
library(tmap)
library(rgdal)
library(leaflet)
library(shiny)
library(shinythemes)
library(plotly)
library(ggplot2)
library(shinydashboard)


# Define UI ----
body <- dashboardBody(
    
    tabItems(
        # ------------------ Home ----------------------------------------------------------------
        
        tabItem(tabName = "Home", fluidPage(
            fluidRow(box(width = 15, title = "Introduction", status = "primary",
                         solidHeader = TRUE, h3("Covid-19 and NYC business"),
                         h4("By Wendy Doan, Qizhen Yang, Qiao Li, Yandong Xiong, James Bergin Smiley"),
                         h5("Drawing data from multiple sources, this application provides insight into the economic impact of coronavirus 2019 (COVID-19) on New York’s city economy. The results shed light on both the financial fragility of many businesses, and the significant impact COVID-19 had on these businesses in the weeks after the COVID-19–related disruptions began."),
                         h5("The application will mainly track down the change in the number of businesses being closed or newly opened across Covid timeline. We divided the businesses into 4 types:", strong("Retail, Service, Food and Beverage, Entertainment")))),
            fluidRow(box(width = 15, title = "Targeted User", status = "primary", solidHeader=TRUE,
                         h5("We believe that the application would be useful for anyone who are interested in learning more about the effects of Covid 19"))),
            fluidRow(box(width = 15, title = "How to Use The App", status = "primary",
                         solidHeader = TRUE,
                         h5("The application is divided into 5 separate tabs"),
                         tags$div(tags$ul(
                             tags$li("The", strong("first"), "tab: Introduction"),
                             tags$li("The", strong("second"), "tab: The detailed ZIP code map shows the extent of Covid 19 outbreak in NYC. It provided key information including: confirmed cases, infection rate, number of business that are closed in the neighborhood"),
                             tags$li("The", strong("third and fourth"), "tab: stats on recently opened/ closed business during Covid 19, tracked separately for different industries"),
                             tags$li("The", strong("fifth"),"tab: Appendix and data sources")
                             
                         ))
            ))
        )), # end of home 
        # ------------------ Map-----------------------------------
        tabItem(tabName = "Map",
                h2("How Many Business Were Closed In Each Neighborhood?", align = 'center'),
                leafletOutput("nyc_map_covid", width = "100%", height = 800)
        ),
        
        #------------------New Business----------------------------
        tabItem(tabName = "New_Business", fluidPage(
            
            # App title ----
            titlePanel("New Business"),
            
            # Sidebar layout with input and output definitions ----
            sidebarLayout(
                
                # Sidebar panel for inputs ----
                sidebarPanel(
                    
                    # Input: Select for the borough ----
                    selectInput(inputId = "borough",
                                label = "Choose a borough:",
                                choices = c("Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island")),
                    
                    # Input: Select for the business type ----
                    selectInput(inputId = "business_type",
                                label = "Choose a business type:",
                                choices = c("retail", "service", "food and beverage", "entertainment"))
                    
                ),
                
                # Main panel for displaying outputs ----
                mainPanel(
                    
                    # Output: tsPlot on borough ----
                    plotOutput(outputId = "tsPlot0"),
                    
                    # Output: tsPlot on borough ----
                    plotOutput(outputId = "tsPlot1"),
                    
                    # Output: tsPlot on business type ----
                    plotOutput(outputId = "tsPlot2")
                    
                )
            )
        )
        ), 

        #------------------closed Business----------------------------
        tabItem(tabName = "Closed_Business", fluidPage(
            
            # App title ----
            titlePanel("Closed Business"),
            
            # Sidebar layout with input and output definitions ----
            sidebarLayout(
                
                # Sidebar panel for inputs ----
                sidebarPanel(
                    # Input: Select for the borough ----
                    
                    
                    # Input: Select for the borough ----
                    selectInput(inputId = "Borough",
                                label = "Choose a borough:",
                                choices = c("Manhattan", "Bronx", "Brooklyn", "Queens", "Staten Island")),
                    
                    # Input: Select for the business type ----
                    selectInput(inputId = "Business_type",
                                label = "Choose a business type:",
                                choices = c("retail", "service", "food and beverage", "entertainment")),
                    numericInput("obs", "lines", 5)
                    
                ),
                
                # Main panel for displaying outputs ----
                mainPanel(
                    
                    # Output: tsPlot on borough ----
                    plotOutput(outputId = "tsPlot00"),
                    
                    # Output: tsPlot on borough ----
                    plotOutput(outputId = "tsPlot_closed_borough"),
                    
                    # Output: tsPlot on borough ----
                    plotOutput(outputId = "tsPlot_borough"),
                    
                    tableOutput("view"),
                    
                    # Output: tsPlot on business type ----
                    plotOutput(outputId = "tsPlot_closed_business_type"),
                    
                    # Output: tsPlot on business type ----
                    plotOutput(outputId = "tsPlot_business_type")
                )
            )
        )
        ),
        


        
        # ------------------ Appendix --------------------------------
        tabItem(tabName = "Appendix", fluidPage( 
            HTML(
                "<h2> Data Sources </h2>
                <h4> <p><li>NYC Covid 19 Data: <a href='https://github.com/nychealth/coronavirus-data'>NYC covid 19 github database</a></li></h4>
                <h4><li>NYC COVID-19 Policy : <a href='https://www1.nyc.gov/site/coronavirus/businesses/businesses-and-nonprofits.page' target='_blank'> NYC Citywide Information Portal</a></li></h4>
                <h4><li>NYC Business data : <a href='https://data.cityofnewyork.us/Business/Legally-Operating-Businesses/w7w3-xahh' target='_blank'>NYC Open Data</a></li></h4>
                <h4><li>NYC Business Application Data : <a href='https://data.cityofnewyork.us/Business/License-Applications/ptev-4hud' target='_blank'>NYC Open Data</a></li></h4>
                <h4><li>NYC Minority Owned Business : <a href='https://data.cityofnewyork.us/Business/M-WBE-LBE-and-EBE-Certified-Business-List/ci93-uc8s' target='_blank'>NYC Health + Hospitals</a></li></h4>
                <h4><li>NYC Geo Data : <a href='https://github.com/ResidentMario/geoplot-data-old' target='_blank'> Geoplot Github</a></li></h4>"
            ),
            
            titlePanel("Disclaimers "),
            
            HTML(
                " <p>We drew our business insights from NYC Open data, specifically business expiration databases. We recognized that there would be a lag between when the business is closed and when the expiration date, status are updated.</p>",
                " <p>Thus our app may understate the number of businesses that were actually closed. Furthermore, due to the lag between the time point where the business were closed, with when the expiration date be updated, there could be some uncertainty to define on which day, month the businesses were fully closed
 </p>"),
            
            titlePanel("Acknowledgement  "),
            
            HTML(
                " <p>This application is built using R shiny app.</p>",
                "<p>The following R packages were used in to build this RShiny application:</p>
                <li>Shinytheme</li>
                <li>Tidyverse</li>
                <li>Dyplr</li><li>Tibble</li><li>Rcurl</li><li>Plotly</li>
                <li>ggplot2</li>"
            ),
            
            titlePanel("Contacts"),
            
            HTML(
                " <p>For more information please feel free to contact</p>",
                " <p>Wendy Doan(ad3801@columbia.edu) </p>",
                " <p>Qizhen Yang(qy2446@columbia.edu)</p>",
                " <p>Yandong Xiong(yx2659@columbia.edu) </p>",
                " <p>TQiao Li(ql2403@columbia.edu)</p>",
                " <p>James Smiley(jbs2253@columbia.edu) </p>")
        )) # end of tab
        
    ) # end of tab items
) # end of body



ui <- dashboardPage(
    title="Covid 19 and The effect on Business in NYC",
    skin = "blue", 
    dashboardHeader(title=span("Covid 19 and NYC Business",style="font-size: 16px")),
    
    dashboardSidebar(sidebarMenu(
        menuItem("Home", tabName = "Home", icon = icon("home")),
        menuItem("Map", tabName = "Map", icon = icon("compass")),
        menuItem("New Business", tabName = "New_Business", icon = icon("dollar-sign")),
        menuItem("Closed Business", tabName = "Closed_Business", icon = icon("dollar-sign")),
        menuItem("Appendix", tabName = "Appendix", icon = icon("fas fa-asterisk"))
    )),
    body 
)