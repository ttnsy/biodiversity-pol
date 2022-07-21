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
occurence_clean <- readRDS("data/occurence_clean.RDS") 
multimedia_clean <- readRDS("data/multimedia_clean.RDS") 
shapefile <- readRDS("data/POL_adm2.sf.rds")

## global variable
list_vernacularName <- sort(unique(occurence_clean[!occurence_clean$vernacularName == "",]$vernacularName))
list_scientificName <- sort(unique(occurence_clean$scientificName))