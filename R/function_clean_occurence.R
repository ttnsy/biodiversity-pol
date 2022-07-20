library(dplyr)
library(data.table)
library(sf)
library(GADMTools)

clean_occurence <- function(occurence_csv){
  cols <- fread(cmd = paste('head -n 1', occurence_csv))
  dat <- fread(cmd = paste("grep", "Poland", occurence_csv), col.names = colnames(cols))
  
  map <- gadm_sf_loadCountries(c("POL"), level=2, basefile = "../data_inputs")
  
  dat <- dat %>% 
    rename(
      latitude = latitudeDecimal,
      longitude = longitudeDecimal
    )
  
  loc_ref <- dat %>% 
    select(id, latitude, longitude) %>% 
    st_as_sf(coords = c("longitude", "latitude"), crs = "WGS84") %>% 
    st_join(shapefile,st_nearest_feature) %>% 
    as.data.frame() %>% 
    select(id, NAME_1, NAME_2)
  
  dat <- dat %>% 
    left_join(loc_ref)  %>% 
    select(
      id, 
      eventDate, eventTime,
      NAME_1, NAME_2, 
      latitude, longitude, 
      coordinateUncertaintyInMeters,
      taxonRank, kingdom, family, 
      scientificName, vernacularName, 
      individualCount
    )
  
  saveRDS(dat, "../data_inputs/occurence_clean.RDS")
}