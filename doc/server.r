library(shiny)
library(leaflet)
library(leaflet.extras)
library(magrittr)

shinyServer(function(input, output, session) {

load(file="../output/incident_count_aggregate.RData")
  
  # makes the physical map
  output$heatMap = renderLeaflet({leaflet(width="100%") %>% 
      addProviderTiles(providers$Stamen.TonerLabels) %>%
      addProviderTiles(providers$Stamen.TonerLines) %>%
      setView(-73.8767716,40.7379555, zoom = 10) %>%
      addResetMapButton()
    
  })
  
  # creates a reactive dataframe that has the subsetting needed for the heatmap
  incident_data_by_groups <-  reactive({
    subset(count_by_lat_long_incident, INCIDENT_CLASSIFICATION_GROUP %in% c(input$incident))
    
  })
  
  # renders a new heatmap based off of what is selected
  observe({
    leafletProxy(mapId = "heatMap", data=incident_data_by_groups()) %>%
      clearHeatmap() %>%
      addHeatmap(lng = ~LONGITUDE, lat = ~LATITUDE, intensity = ~COUNT,
                 blur = 15, max = 0.05, radius = 12) 
  })
  
  observeEvent(input$click_all_incident_types, {
    updateCheckboxGroupInput(session, "incident",
                             choices = unique(count_by_lat_long_incident$INCIDENT_CLASSIFICATION_GROUP),
                             selected = unique(count_by_lat_long_incident$INCIDENT_CLASSIFICATION_GROUP))
  })
  observeEvent(input$click_no_incident_types, {
    updateCheckboxGroupInput(session, "incident",
                             choices = unique(count_by_lat_long_incident$INCIDENT_CLASSIFICATION_GROUP),
                             selected = NULL)
  })
})