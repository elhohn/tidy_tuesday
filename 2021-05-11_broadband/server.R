library(shiny)
library(reactable)
library(sf)
library(tigris)
library(leaflet)
library(ggplot2)
library(plotly)
options(tigris_use_cache = TRUE)

# Load data (prepped with data_prep.R)
bb_df <- readRDS('data/bb_df.Rds')
bb_sp <- readRDS('data/bb_sp.Rds')

pal <- colorNumeric(
  palette = "Greens",
  domain = bb_sp$`BROADBAND USAGE`)

# create labels for zipcodes
labels <- 
  paste0(
    "Zip Code: ",
    bb_sp$GEOID10, "<br/>",
    "Broadband Usage: ",
    bb_sp$`BROADBAND USAGE`) %>%
  lapply(htmltools::HTML)


server <- function(input, output) {
  
  ######## MAP ##########
  output$map <- renderLeaflet({
    bb_sp %>% 
      leaflet %>% 
      # add base map
      addProviderTiles("CartoDB") %>% 
      setView(-122.675, 45.519, zoom = 10) %>%
      # add zip codes
      addPolygons(fillColor = ~pal(`BROADBAND USAGE`),
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
                values = ~`BROADBAND USAGE`, 
                opacity = 0.7, 
                title = htmltools::HTML("Broadband usage <br> 
                                    by Zip Code"),
                position = "bottomright")
  })
  
  
  ######## TABLE ##########
  output$table <- renderReactable({
    tbl <- reactable(
      bb_df,
      selection = "multiple",
      onClick = "select",
      rowStyle = list(cursor = "pointer"),
      minRows = 10
    )
    
    tbl
    
  })
  
  ######### PLOT ##########
  output$plot <- renderPlotly({
    
    p <- ggplot(bb_df, aes(x = Median, y = `BROADBAND USAGE`,
                           color = `BROADBAND USAGE`, size = Pop)) +
      geom_point(size = 6, alpha = 0.5)
    
    ggplotly(p)
    
  })
  
  
}