library(shiny)
library(leaflet)
library(shinythemes)


fluidPage(
  title = "Volcanos!",
  theme = shinytheme("slate"),
  
  tags$head(
    tags$style(HTML("
                    @import url('//fonts.googleapis.com/css?family=Quicksand|Cabin:400,700');
                    h2 {
                    font-family: 'Quicksand';
                    font-weight: 200;
                    line-height: 1.1;
                    font-size: 40px;
                    color: 'white';
                    }
                    
                    "),
               "body { word-wrap: break-word; }",
               "#yearText{color: 'white';
                          font-family: 'Quicksand';
                          font-weight: 200;
                          line-height: 1.1;
                          font-size: 30px;
               }"
               )
    ),
  
  
  
  leafletOutput("map", width = "100%", height = '1200px'),
  absolutePanel(id = "title", #class = "panel panel-default", 
                fixed = TRUE,
                draggable = FALSE, 
                top = 50, left = 80, right = 'auto', bottom = "auto",
                width = 800,
                h2('Volcanic Eruptions in last 2000 years')
  ),
  absolutePanel(id = "slider", #class = "panel panel-default", 
                fixed = TRUE,
                draggable = TRUE, 
                right = 500, bottom = 50, top = 'auto', left = 'auto', 
                sliderInput("year", "Eruption Year", 0, 
                            2020,
                            value = 2020,
                            step = 100,
                            animate = TRUE),
                tags$script("$(document).ready(function(){
                        setTimeout(function() {$('.slider-animate-button').click()},10);
                    });")
                ),
  absolutePanel(id = "yearpanel", #class = "panel panel-default", 
                fixed = TRUE,
                draggable = FALSE, 
                top = 'auto', left = 'auto', right = 200, bottom = 100,
                textOutput('yearText')
  )
)

