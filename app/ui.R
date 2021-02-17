#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
ui <- fluidPage(
    
    # App title ----
    titlePanel("Business Closed"),
    
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
            plotOutput(outputId = "tsPlot1"),
            
            # Output: tsPlot on business type ----
            plotOutput(outputId = "tsPlot2")
            
        )
    )
)


