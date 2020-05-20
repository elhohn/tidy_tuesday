library(shiny)
library(leaflet)
library(leaflet.esri)
library(sp)
library(viridis)


# load the dater
volcano <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-12/volcano.csv')
eruptions <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-12/eruptions.csv')
events <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-05-12/events.csv')

coordinates(eruptions) <- ~longitude+latitude
spdf <- SpatialPointsDataFrame(coords = eruptions@coords,
                               data = eruptions@data,
                               proj4string = CRS("+init=epsg:28992"))

shinyServer(function(input, output, session) {
  pal <- colorNumeric(palette = 'plasma', domain = spdf$vei)
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012) %>%
      addCircleMarkers(data = spdf,
                       radius = ~vei*4,
                       color = 'transparent',
                       fillColor = ~pal(vei),
                       fillOpacity = 0.2
                       ) %>%
      addLegend('topright',
                pal = pal,
                values = spdf[!is.na(spdf$vei),]$vei,
                opacity = 1, 
                title = 'Volcano\nExplosivity\nIndex')
  })
  
  }
)

 
  
