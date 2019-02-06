#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(dataRetrieval)
library(dplyr)
library(smwrBase)
source("functions.R")

# Define server logic
shinyServer(function(input, output) {
  
  #Download the flow data
  flowData <- eventReactive(input$go, {
    
    stationID <- input$stationID
    dateRange <- input$dateRangeInput
    maxDiff <- input$maxDiff
    method <- input$mergeMethod

    showNotification("Working...", duration=NULL, id="wrk")
    
    sq <- getSampleQ(stationID, dateRange[1], dateRange[2], maxDiff, method)
    
    removeNotification("wrk")
    
    if(class(sq) == "character") {
      msg <- sq
      showNotification(msg, duration = 10, id="err", type="error")
    }
    sq
    
  })
  
  #Display of the flow data before you download it 
  output$flowDataTable <- renderTable({
    flowData()
  })
  
  #Download handler for the interpolated flow data
  output$downloadFlow <- downloadHandler(
    filename = function() {
      paste0("intFlow", input$stationID, ".csv")
    },
    content = function(file) {
      write.csv(flowData(), file, row.names=FALSE)
    }
  )
  
})
