library(shiny)
library(reactable)
library(sf)
library(tigris)
library(leaflet)
library(ggplot2)
library(plotly)
library(shinyjs)
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
    bb_sp$zip, "<br/>",
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
    d <- cbind(zoom = NA, bb_df)
    d <- d %>% SharedData$new(group = "broadband")
    
    sticky_style <- list(position = "sticky", left = 0, background = "#fff", zIndex = 1,
                         borderRight = "1px solid #eee")
    
    tbl <- reactable(
      d,
      selection = "multiple",
      #onClick = "select",
      rowStyle = list(cursor = "pointer"),
      minRows = 10,
      columns = list(
        zoom = colDef(
          align = "center",
          minWidth = 120,
          name = "",
          style = sticky_style,
          headerStyle = sticky_style,
          sortable = FALSE,
          cell = function() htmltools::tags$button("GO TO FIELD",
                                                   class="btn-zoom")
        )
      ),
      onClick = JS("function(rowInfo, colInfo) {
                        // Only handle click events on the 'zoom' column
                        if (colInfo.id !== 'zoom') {
                          return
                        }
                        // Send the click event to Shiny, which will be available in input$clicked_field
                        // Note that the row index starts at 0 in JavaScript, so we add 1
                        if (window.Shiny) {
                          Shiny.setInputValue('clicked_field', { index: rowInfo.index + 1 }, { priority: 'event' })
                        }
                      }")
    )
    
    tbl
    
  })
  
  ######### PLOT ##########
  output$plot <- renderPlotly({
    d <- bb_df %>% SharedData$new(group = "broadband")
    p <- ggplot(d, aes(x = Median, y = `BROADBAND USAGE`,
                           color = `BROADBAND USAGE`, size = Pop)) +
      geom_point(size = 6, alpha = 0.5)
    
    ggplotly(p)
    
  })
  
  
}