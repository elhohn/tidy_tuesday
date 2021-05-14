library(shiny)
library(reactable)
library(sf)
library(leaflet)
library(ggplot2)
library(plotly)
#library(shinyjs)
library(crosstalk)
library(reactablefmtr)

server <- function(input, output) {
  
  ######## MAP ##########
  output$map <- renderLeaflet({
    bb_sp %>% 
      SharedData$new(group = "broadband") %>%
      leaflet %>% 
      addProviderTiles("CartoDB.DarkMatter") %>% 
      setView(-120.393, 44.066, zoom = 8) %>%
      addPolygons(fillColor = ~pal(`BROADBAND USAGE`),
                  weight = 0,
                  opacity = 1,
                  color = "white",
                  fillOpacity = 0.7,
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
    d <- d %>%
       select(zoom, zip, `COUNTY NAME`, Pop, Median, `BROADBAND USAGE`) %>%
       SharedData$new(group = "broadband")
    
    sticky_style <- list(position = "sticky", left = 0, background = "black", zIndex = 1,
                         borderRight = "1px solid #eee")
    
    tbl <- reactable(
      d,
      filterable = TRUE,
      striped = TRUE,
      highlight = TRUE,
      minRows = 10,
      defaultColDef = colDef(
        align = "center",
        minWidth = 70
        ),
      columns = list(
        zip = colDef(name = "ZIP", width = 55),
        `COUNTY NAME` = colDef(name = "COUNTY"),
        Pop = colDef(name = "POP"),
        Median = colDef(name = "MED INCOME",
                        format = colFormat(prefix = "$")),
        `BROADBAND USAGE` = colDef(name = "BROADBAND USE",
                                   format = colFormat(percent = TRUE)),
        zoom = colDef(
          align = "center",
          width = 110,
          name = "",
          sortable = FALSE,
          cell = function() htmltools::tags$button("ZOOM TO ZIP",
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
  
  
  # when zoom button clicked, zoom map to that polygon
  observeEvent(input$clicked_field, {
    #browser()
    f <- input$clicked_field
    selected_zip <- bb_sp[as.numeric(f),]$zip
 
    d <- bb_sp %>%
      filter(zip == selected_zip)
    
    bbox <- st_bbox(d)
    
    print(nrow(d))
    isolate({
      map <- leafletProxy("map", data = d)
      map %>% clearPopups()
      
      map %>% fitBounds(lng1 = bbox[['xmin']],
                        lat1 = bbox[['ymin']],
                        lng2 = bbox[['xmax']],
                        lat2 = bbox[['ymax']]) %>%
        clearGroup('highlight') %>%
        addPolygons(data = d,
                    group = 'highlight',
                    color = 'white',
                    weight = 10,
                    fillColor = 'transparent',
                    fillOpacity = 0.5,
                    label = labels
                    )
      
    })

  })
  
  ######### PLOT ##########
  output$plot <- renderPlotly({
    d <- bb_df %>% SharedData$new(group = "broadband")
    p <- ggplot(d, aes(x = Median, y = `BROADBAND USAGE`,
                           color = `BROADBAND USAGE`, size = Pop)) +
      geom_point(alpha = 0.5) +
      scale_y_continuous(labels = scales::percent) +
      scale_x_continuous(labels=scales::dollar_format()) +
      labs(title = "Broadband usage vs. median household\nincome in Oregon") +
      xlab("Median household income, 2019") +
      ylab("Broadband usage") +
      theme(plot.background = element_rect(fill = "#121212"),
            panel.background = element_rect(fill = "#121212",
                                            colour = "#121212",
                                            size = 0.0, linetype = "solid"),
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            legend.position = "none",
            plot.title = element_text(size = 14, margin = margin(l = 0, b = 10), 
                                      hjust = -10, color = 'white'),
            axis.text.x = element_text(face="bold", color="white", 
                                       size=12),
            axis.title.y = element_text(face="bold", color="white", size=12),
            axis.text.y = element_text(color="white", size=9),
            axis.title.x = element_text(face="bold", color="white", size=12)
            )
    
    ggplotly(p)
    
  })
  
  
}