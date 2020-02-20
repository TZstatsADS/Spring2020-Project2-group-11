library(shiny)
library(leaflet)
library(leaflet.extras)
library(magrittr)

shinyServer(function(input, output, session) {

  load(file="../output/firehouse_locations.RData")
  load(file="../output/incident_count_aggregate.RData")

  # makes the physical map
  output$heatMap <- renderLeaflet({leaflet(data = firehouses, width="100%") %>% 
      addProviderTiles(providers$Hydda.Full) %>%
      setView(-73.8767716,40.7379555, zoom = 11) %>%
      addResetMapButton()
    
  })
  
  # creates a reactive dataframe that has the subsetting needed for the heatmap
  incident_data_by_groups <-  reactive({
    subset(count_by_lat_long_incident, INCIDENT_CLASSIFICATION_GROUP %in% c(input$incident))
    
  })
  
  # allows you to select or deselect to show firehouses
  observeEvent(input$show_firehouses, {
    if("" %in% input$show_firehouses) leafletProxy("heatMap") %>% showGroup("firehouses")
    else{leafletProxy("heatMap") %>% hideGroup("firehouses")}
  }, ignoreNULL = FALSE)
  
  
  # renders a new heatmap based off of what is selected
  observe({
    leafletProxy(mapId = "heatMap", data=incident_data_by_groups()) %>%
      clearHeatmap() %>%
      addHeatmap(lng = ~LONGITUDE, lat = ~LATITUDE, intensity = ~COUNT,
                 blur = 15, max = 0.05, radius = 12) %>%
      addMarkers(lng=firehouses$Longitude, lat=firehouses$Latitude, group="firehouses", popup = firehouses$FacilityName,
                 icon = list(iconUrl = "https://classroomclipart.com/images/gallery/Clipart/Emergency/TN_firestation-firehouse-clipart.jpg"
                             ,iconSize = c(20,20)))
  })
  
  # allows you to select all of the incident types
  observeEvent(input$click_all_incident_types, {
    updateCheckboxGroupInput(session, "incident",
                             choices = unique(count_by_lat_long_incident$INCIDENT_CLASSIFICATION_GROUP),
                             selected = unique(count_by_lat_long_incident$INCIDENT_CLASSIFICATION_GROUP))
  })
  
  # allows you to select none of the incident types
  observeEvent(input$click_no_incident_types, {
    updateCheckboxGroupInput(session, "incident",
                             choices = unique(count_by_lat_long_incident$INCIDENT_CLASSIFICATION_GROUP),
                             selected = NULL)
  })
  
  
})