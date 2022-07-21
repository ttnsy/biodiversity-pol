# Libraries ---------------------------------------------------------------
library(shiny)
library(dplyr)
library(sf)
library(leaflet)
library(htmltools)
library(lubridate)
library(ggplot2)
library(plotly)
library(glue)


# Read data ---------------------------------------------------------------
occurence_clean <- readRDS("data_inputs/occurence_clean.RDS") 
shapefile <- readRDS("data_inputs/POL_adm2.sf.rds")

## global variable
list_vernacularName <- sort(unique(occurence_clean$vernacularName))
list_scientificName <- sort(unique(occurence_clean$scientificName))