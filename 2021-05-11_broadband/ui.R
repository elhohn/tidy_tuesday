library(shiny)
library(leaflet)
library(reactable)
library(plotly)
library(shinyWidgets)

ui <- fluidPage(
  setBackgroundColor(
    color = "#121212",
    gradient = c("linear", "radial"),
    direction = c("bottom", "top", "right", "left"),
    shinydashboard = FALSE
  ),
  includeCSS('style.css'),
  fluidRow(style='height:40vh',
    column(12,
           leafletOutput('map')
    )
  ),
  
  fluidRow(style = 'height:30vh',
    column(6,
           reactableOutput('table')
           ),
    column(6,
           plotlyOutput('plot')
           )
    )

  
)
