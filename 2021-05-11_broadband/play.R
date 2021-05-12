library(reactable)
library(sf)
library(tigris)
library(leaflet)
options(tigris_use_cache = TRUE)


## Get the dater
tuesdata <- tidytuesdayR::tt_load('2021-05-11')

# note: bb availability from end of 2017; usage from Nov 2019
bb <- tuesdata$broadband

# usage from Nov 2020
zips <- tuesdata$broadband_zip
zips <- as.data.frame(zips[zips$ST != 'AK',])
zips$zip <- as.character(zips$`POSTAL CODE`)
zips$bb_use <- as.numeric(zips$`BROADBAND USAGE`)

## Download zip code level shapefile from TIGRIS
geo <- zctas(cb = TRUE)

# join zip boundaries and broadband data 
dater <- geo_join(geo, 
                  zips, 
                  by_sp = "GEOID10", 
                  by_df = "zip",
                  how = "left")

pal <- colorNumeric(
  palette = "Greens",
  domain = dater$`BROADBAND USAGE`)

# create labels for zipcodes
labels <- 
  paste0(
    "Zip Code: ",
    dater$GEOID10, "<br/>",
    "Broadband Usage: ",
    dater$`BROADBAND USAGE`) %>%
  lapply(htmltools::HTML)


dater %>% 
  leaflet %>% 
  # add base map
  addProviderTiles("CartoDB") %>% 
  # add zip codes
  addPolygons(fillColor = ~pal(bb_use),
              weight = 2,
              opacity = 1,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7,
              highlight = highlightOptions(weight = 2,
                                           color = "#666",
                                           dashArray = "",
                                           fillOpacity = 0.7,
                                           bringToFront = TRUE),
              label = labels) %>%
  # add legend
  addLegend(pal = pal, 
            values = ~bb_use, 
            opacity = 0.7, 
            title = htmltools::HTML("Broadband usage <br> 
                                    by Zip Code <br>
                                    2018"),
            position = "bottomright")



## Overall shapefile of US states
states <- st_as_sf(states(cb=TRUE))
#For plotting, all the maps should have the same crs
states=st_transform(states,st_crs(geo))

## Merge bb data with go
zips.sf=merge(geo, zips)
