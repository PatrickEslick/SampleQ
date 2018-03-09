#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Interpolated discharge data for QW sample times"),
  fluidRow(
    column(12, includeMarkdown("help.Rmd"))
  ),
  
  fluidRow(
    column(2, textInput("stationID", "Location", value="", placeholder="12345678")),
    column(3, dateRangeInput("dateRangeInput", "Dates", start="2017-01-01", format="yyyy-mm-dd")),
    column(4, sliderInput("maxDiff", "Maximum gap to use for interpolation (in hours)", min=1, max=5, value=4, step=1))
  ),
  fluidRow(
    column(8,
      helpText("Click 'Get data' and wait for the data to load before downloading it")       
    )
  ),
  fluidRow(
    column(1, actionButton("go", "Get data")),
    column(1, downloadButton("downloadFlow", "Download"))
  ),
  fluidRow(
    column(4,
      tableOutput("flowDataTable")
    )
  )
  

))
