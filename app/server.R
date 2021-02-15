#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#
#-------------------------------------------------App Server----------------------------------
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

#can run RData directly to get the necessary date for the app
#global.r will enable us to get new data everyday
#update data with automated script
#source("global.R") 
#load('./output/covid-19.RData')
shinyServer(function(input, output) {
    #nothing in here
})