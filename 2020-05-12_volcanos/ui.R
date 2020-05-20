library(shiny)
library(leaflet)
library(shinythemes)


fluidPage(
  title = "Volcanos!",
  theme = shinytheme("slate"),
  leafletOutput("map", width = "100%", height = '800px')
)

