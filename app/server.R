library(shiny)
library(leaflet)
library(data.table)
library(plotly)
library(shinyWidgets)
library(googleVis)
library(geosphere)
library(leaflet.extras)
library(ggmap)
library(purrr)
library(magrittr)

##Data processing

load(file = "/Users/rachel/Documents/GitHub/Spring2020-Project2-group-11/output/clean_fire2.RData")
data = clean_fire2 %>% 
  select(YEAR, TIME, INCIDENT_CLASSIFICATION_GROUP, LATITUDE, LONGITUDE) %>% 
  mutate(Severity = map_dbl(INCIDENT_CLASSIFICATION_GROUP, ~ switch(.x, 
                                                          "Structural Fires" = 6, 
                                                          "NonStructural Fires" = 5, 
                                                          "Medical Emergencies" = 4, 
                                                          "NonMedical Emergencies" = 3, 
                                                          "NonMedical MFAs" = 2, 
                                                          "Medical MFAs" = 1)))

load(file="/Users/rachel/Documents/GitHub/Spring2020-Project2-group-11/output/firehouse_locations.RData")
load(file="/Users/rachel/Documents/GitHub/Spring2020-Project2-group-11/output/incident_count_aggregate.RData")

color = data.frame(
  INCIDENT_CLASSIFICATION_GROUP = c("NonMedical Emergencies", "Medical Emergencies", "NonMedical MFAs", "Medical MFAs", "NonStructural Fires", "Structural Fires"), 
  color = c("#e0f0e9", "#622a1d", "#bbcdc5", "#c3272b", "#808080", "#ff491f"))

incidence <- merge(data, color, by = c("INCIDENT_CLASSIFICATION_GROUP","INCIDENT_CLASSIFICATION_GROUP"), all.y = F)


shinyServer(function(input, output, session) {
  
  ## Map Tab section
  
  output$map <- renderLeaflet({
    leaflet() %>%
     addProviderTiles("Hydda.Full", 
                       options = providerTileOptions(noWrap = TRUE)) %>%
      setView(-73.8767716,40.7379555,zoom = 13) %>%
      addResetMapButton()
  })
  
  # makes the physical map
  #output$heatMap <- renderLeaflet({
  #leaflet(data = firehouses, width="100%") %>% 
  #    addProviderTiles(providers$Hydda.Full) %>%
  #    setView(-73.8767716,40.7379555, zoom = 11) %>%
   #   addResetMapButton()
    
  #})
  
  # allows you to select or deselect to show firehouses
  #observeEvent(input$show_firehouses, {
   # if("" %in% input$show_firehouses) leafletProxy("heatMap") %>% showGroup("firehouses")
    #else{leafletProxy("heatMap") %>% hideGroup("firehouses")}
  #}, ignoreNULL = FALSE)
  

  #enable/disable markers of specific group
  
  #alarm_level = c("All Hands Working", "First Alarm","Second Alarm", "Third Alarm", "Forth Alarm", "Fifth Alarm and Higher")
  #al_color = c("#c9dd22", "#fff143", "#ff8c31", "#ff7500", "#9d2933", "#622a1d")
  
  incident_type = c("NonMedical Emergencies", "Medical Emergencies", "NonMedical MFAs", "Medical MFAs", "NonStructural Fires", "Structural Fires")
  ac_color = c("#e0f0e9", "#622a1d", "#bbcdc5", "#c3272b", "#808080", "#ff491f")
  
  observeEvent(input$map_click, {
    #if(!input$click_multi) 
    leafletProxy("map") %>% clearGroup(c("circles","centroids",incident_type))
    click <- input$map_click
    clat <- click$lat
    clong <- click$lng
    radius <- input$click_radius
    
    #output info
    output$click_coord <- renderText(paste("Latitude:",round(clat,7),", Longitude:",round(clong,7)))
    year_select <-as.numeric(input$year)
    f_hour <- input$from_hour 
    t_hour <- input$to_hour
    
    incidence <- incidence[incidence$YEAR == year_select,]
    inc_within_range <- incidence[distCosine(c(clong,clat),incidence[,c("LONGITUDE","LATITUDE")]) <= input$click_radius,]
    if(input$from_hour <= input$to_hour){
      inc_within_range  <- inc_within_range[(inc_within_range$TIME>=f_hour)&(inc_within_range$TIME<=t_hour),]
    }
    else{
      inc_within_range  <- inc_within_range[(inc_within_range$TIME>=f_hour)|(inc_within_range$TIME<=t_hour),]
    }
    
    
    
    ### need weighted avg here
    
    inc_total <- nrow(inc_within_range)
    inc_per_day <- inc_total / 365
    total_index <- sum(inc_within_range$Severity)
    
    
    # alarm index
    if(t_hour==f_hour){
      alarm_index <- (total_index/(radius/1000)^2)*24
    }
    else if(t_hour>f_hour){
      alarm_index <- (total_index/(radius/1000)^2)*24/(t_hour-f_hour)
    }
    else{
      alarm_index <- (total_index/(radius/1000)^2)*24/(24+t_hour-f_hour)
    }
    
    if(alarm_index> 40000){
      output$click_alarm_index_red <- renderText(round(alarm_index,2))
      output$click_alarm_index_green <- renderText({})
      output$click_alarm_index_orange <- renderText({})
    }
    else if(alarm_index<15000){
      output$click_alarm_index_green <- renderText(round(alarm_index,2))
      output$click_alarm_index_red <- renderText({})
      output$click_alarm_index_orange <- renderText({})
    }
    else{
      output$click_alarm_index_orange <- renderText(round(alarm_index,2))
      output$click_alarm_index_green <- renderText({})
      output$click_alarm_index_red <- renderText({})
    }
    
    output$click_inc_total <-renderText(inc_total)
    output$click_inc_per_day <- renderText(round(inc_per_day,2))
    output$click_alarm_index <- renderText(round(alarm_index, 2))
    
    # creates a reactive dataframe that has the subsetting needed for the heatmap
    incident_data_by_groups <-  reactive({
      subset(count_by_lat_long_incident, INCIDENT_CLASSIFICATION_GROUP %in% c(input$click_incident_type))
    })
    
    # renders a new heatmap based off of what is selected
    leafletProxy(mapId = "map", data=incident_data_by_groups()) %>%
      clearHeatmap() %>%
      addHeatmap(lng = ~LONGITUDE, lat = ~LATITUDE, intensity = ~COUNT,
                 blur = 15, max = 0.05, radius = 12) %>%
      addMarkers(lng=firehouses$Longitude, lat=firehouses$Latitude, group="firehouses", popup = firehouses$FacilityName,
                 icon = list(iconUrl = "https://classroomclipart.com/images/gallery/Clipart/Emergency/TN_firestation-firehouse-clipart.jpg",
                             iconSize = c(20,20)))
    
    
    leafletProxy('map') %>%
      addCircles(lng = clong, lat = clat, group = 'circles',
                 stroke = TRUE, radius = radius,popup = paste("SEVERITY LEVEL: ", round(alarm_index,2), sep = ""),
                 color = 'black', weight = 1
                 ,fillOpacity = 0.5)%>%
      addCircles(lng = clong, lat = clat, group = 'centroids', radius = 1, weight = 2,
                 color = 'black',fillColor = 'black',fillOpacity = 1)
    
    #incidence_within_range <- merge(incidence_within_range, color, by = c("INCIDENT_CLASSIFICATION_GROUP","INCIDENT_CLASSIFICATION_GROUP"), all.y = F)
    
    leafletProxy('map', data = inc_within_range) %>%
      addCircles(~LONGITUDE,~LATITUDE, group =~INCIDENT_CLASSIFICATION_GROUP, stroke = F,
                 radius = 12, fillOpacity = 0.8,fillColor=~color)
    
    
    
    
    
    
    
    #Distribution of the Types of Incidence
    output$click_inc_pie <- renderPlotly({
      ds <- table(inc_within_range$INCIDENT_CLASSIFICATION_GROUP)
      pie_title <- paste("Incidence categories ","from ",input$from_hour,"h to ",input$to_hour,"h",sep="")
      ds <- ds[incident_type]
      ds[is.na(ds)] <- 0
      plot_ly(labels=incident_type, values=ds, type = "pie",
              marker=list(colors=ac_color)) %>%
        layout(title = pie_title,showlegend=F,
               xaxis=list(showgrid=F,zeroline=F,showline=F,autotick=T,ticks='',showticklabels=F),
               yaxis=list(showgrid=F,zeroline=F,showline=F,autotick=T,ticks='',showticklabels=F))
      
    })
    
  })
  
  # Select the types of the incidence to be visualized
  observeEvent(input$click_incident_type, {
    
    for(type in incident_type){
      if(type %in% input$click_incident_type) leafletProxy("map") %>% showGroup(type)
      else{leafletProxy("map") %>% hideGroup(type)}
    }
    
  }, ignoreNULL = FALSE)
  
  # Select all or none of the incidence to be visualize
  observeEvent(input$click_all_incident_type, {
    updateCheckboxGroupInput(session, "click_incident_type",
                             choices = incident_type,
                             selected = incident_type)
  })
  observeEvent(input$click_none_incident_type, {
    updateCheckboxGroupInput(session, "click_incident_type",
                             choices = incident_type,
                             selected = NULL)
  })
  
  # allows you to select or deselect to show firehouses
  observeEvent(input$show_firehouses, {
    if("" %in% input$show_firehouses) leafletProxy("map") %>% showGroup("firehouses")
    else{leafletProxy("map") %>% hideGroup("firehouses")}
  }, ignoreNULL = FALSE)
  
})