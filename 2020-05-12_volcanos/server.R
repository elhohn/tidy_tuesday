library(shiny)
library(leaflet)
library(sp)
library(viridis)

# load the dater
eruptions <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-12/eruptions.csv')
coordinates(eruptions) <- ~longitude+latitude
spdf <- SpatialPointsDataFrame(coords = eruptions@coords,
                               data = eruptions@data,
                               proj4string = CRS("+init=epsg:28992"))

shinyServer(function(input, output, session) {
  pal <- colorNumeric(palette = 'inferno', domain = spdf$vei, reverse = TRUE)
  
  points <- reactive({
    subset(spdf, start_year == input$year)
    #spdf[spdf@data$start_year==input$year,]
  })
  
  
  output$map <- renderLeaflet({
    leaflet() %>%
      setView(lng = 23.434077, lat = 14.127021, zoom = 3) %>%
      addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012) %>%
      addLegend('topright',
                pal = pal,
                values = spdf[!is.na(spdf$vei),]$vei,
                opacity = 1, 
                title = 'Volcano</br>Explosivity</br>Index')
  })
  
  observeEvent(points(), {
    leafletProxy('map', data = points()) %>%
      addCircleMarkers(data = points(),
                       radius = ~vei*10,
                       color = ~pal(vei)
      )
  }
  )
  
  observeEvent(input$year, {
    if (input$year == 0) {
    leafletProxy('map') %>%
      clearMarkers()
    }
  }
  )
  
  output$yearText <- renderText({ 
    print(paste("Year: ", input$year, " A.D."))
    })
  
}
)

 
  
