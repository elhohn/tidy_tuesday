library(shiny)

ui <- fluidPage(
  fluidRow(height = '40vh',
    column(12,
           leafletOutput('map')
           )
  ),
  
  fluidRow(height = '60vh',
    column(6,
           reactableOutput('table')
           ),
    column(6,
           plotlyOutput('plot')
           )
    )

  
)
