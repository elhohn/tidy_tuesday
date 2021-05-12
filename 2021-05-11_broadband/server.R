library(shiny)
library(reactable)
library(sf)
library(tigris)
library(leaflet)
library(ggplot2)
library(plotly)
options(tigris_use_cache = TRUE)

## Get the dater
tuesdata <- tidytuesdayR::tt_load('2021-05-11')

# note: bb availability from end of 2017; usage from Nov 2019
bb <- tuesdata$broadband

# usage from Nov 2020
zips <- tuesdata$broadband_zip
zips <- as.data.frame(zips[zips$ST == 'OR',])
zips$zip <- as.character(zips$`POSTAL CODE`)
zips$bb_use <- as.numeric(zips$`BROADBAND USAGE`)

# zip code level income data
income <- read.csv('data/income_zip.csv')
zips <- merge(zips, income, by.x = "COUNTY ID", by.y = 'Zip')

## Download zip code level shapefile from TIGRIS
geo <- zctas(cb = TRUE, starts_with = zips$zip)

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


server <- function(input, output) {
  
  ######## MAP ##########
  output$map <- renderLeaflet({
    dater %>% 
      leaflet %>% 
      # add base map
      addProviderTiles("CartoDB") %>% 
      setView(-122.675, 45.519, zoom = 10) %>%
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
      addLegend(pal = pal, 
                values = ~bb_use, 
                opacity = 0.7, 
                title = htmltools::HTML("Broadband usage <br> 
                                    by Zip Code <br>
                                    2018"),
                position = "bottomright")
  })
  
  
  ######## TABLE ##########
  output$table <- renderReactable({
    tbl <- reactable(
      dater,
      selection = "multiple",
      onClick = "select",
      rowStyle = list(cursor = "pointer"),
      minRows = 10
    )
    
    tbl
    
  })
  
  ######### PLOT ##########
  output$plot <- renderPlotly({
    
    p <- ggplot(dater, aes(x = Pop, y = bb_use, color = bb_use)) +
      geom_point(size = 6, alpha = 0.5)
    
    ggplotly(p)
    
  })
  
  
}