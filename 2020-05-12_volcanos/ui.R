library(shiny)
library(leaflet)
library(shinythemes)


fluidPage(
  title = "Volcanos!",
  theme = shinytheme("slate"),
  leafletOutput("map", width = "100%", height = '800px'),
  absolutePanel(id = "title", #class = "panel panel-default", 
                fixed = TRUE,
                draggable = FALSE, 
                top = 50, left = 50, right = 'auto', bottom = "auto",
                width = 800,
                h2('Volcanic Eruptions in last 2000 years')
  ),
  absolutePanel(id = "slider", #class = "panel panel-default", 
                fixed = TRUE,
                draggable = TRUE, 
                right = 2, bottom = 20, top = 'auto', left = 'auto', 
                width = 800,
                sliderInput("year", "Eruption Year", 0, 
                            2020,
                            value = 2020,
                            step = 100,
                            animate = TRUE),
                tags$script("$(document).ready(function(){
                        setTimeout(function() {$('.slider-animate-button').click()},10);
                    });")
                )
)

