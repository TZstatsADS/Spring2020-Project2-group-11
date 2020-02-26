shinyServer(function(input, output, session) {
  
  ## Map Tab section
  # creates the physical base map for the heatmap
  output$map <- renderLeaflet({
    leaflet(data = firehouses, width="100%") %>% 
      addProviderTiles(providers$Hydda.Full) %>%
      setView(-73.8767716,40.7379555,zoom = 13) %>%
      addResetMapButton()
    
  })
  
  # creates a reactive dataframe that has the subsetting needed for the heatmap
  incident_data_by_groups <-  reactive({
    subset(count_by_lat_long_incident, INCIDENT_CLASSIFICATION_GROUP %in% c(input$click_incidence_type))
  })
  
  # Add heatmap
  observe({
    # renders a new heatmap based off of what is selected by the user
    leafletProxy(mapId = "map", data=incident_data_by_groups()) %>%
      clearHeatmap() %>%
      addHeatmap(lng = ~LONGITUDE, lat = ~LATITUDE, group = "heatmap", intensity = ~COUNT,
                 blur = 15, max = 0.05, radius = 12) %>%
      addMarkers(lng=firehouses$Longitude, lat=firehouses$Latitude, group="firehouses", popup = firehouses$FacilityName,
                 icon = list(iconUrl = "https://classroomclipart.com/images/gallery/Clipart/Emergency/TN_firestation-firehouse-clipart.jpg",
                             iconSize = c(15,15)))
    
  })
  
  #enable/disable markers of specific group; provides colors for each of the groups
  incident_type = c("Structural Fires", "NonStructural Fires", "Medical Emergencies", "NonMedical Emergencies", "NonMedical MFAs", "Medical MFAs")
  ac_color = c("#9d2933", "#ff4e20", "#faff72", "#ffc773", "#e9e7ef", "#ffffff")
  
  # renders circles for incidents based off of click on the map by user
  observeEvent(input$map_click, {
    leafletProxy("map") %>% clearGroup(c("circles","centroids",incident_type))
    click <- input$map_click
    clat <- click$lat
    clong <- click$lng
    radius <- input$click_radius
    
    #output info
    output$click_coord <- renderText(paste("Latitude:",round(clat,7),", Longitude:",round(clong,7)))
    year_select <- as.numeric(input$year)
    month_select <- as.numeric(input$month)
    
    # determines the range of incidents that are included in the click (selects year and month and then uses radius size)
    incidence <- incidence[incidence$YEAR == year_select,]
    incidence <- incidence[incidence$MONTH == month_select,]
    inc_within_range <- incidence[distCosine(c(clong,clat),incidence[,c("LONGITUDE","LATITUDE")]) <= input$click_radius,]
    
    
    ### need weighted avg here to determine the danger
    inc_total <- nrow(inc_within_range)
    inc_per_day <- inc_total / 365
    total_index <- sum(inc_within_range$Severity)
    
    
    # alarm index
    alarm_index <- (total_index/(radius/1000)^2)*24
    
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
    
    
    # Add click circle for map
    leafletProxy('map') %>%
      addCircles(lng = clong, lat = clat, group = 'circles',
                 stroke = TRUE, radius = radius,popup = paste("SEVERITY LEVEL: ", round(alarm_index,2), sep = ""),
                 color = 'black', weight = 1
                 ,fillOpacity = 0.5)%>%
      addCircles(lng = clong, lat = clat, group = 'centroids', radius = 1, weight = 2,
                 color = 'black',fillColor = 'black',fillOpacity = 1)
    
    leafletProxy('map', data = inc_within_range) %>%
      addCircles(~LONGITUDE,~LATITUDE, group =~INCIDENT_CLASSIFICATION_GROUP, stroke = F,
                 radius = 12, fillOpacity = 0.8,fillColor=~color)
    
    
    # Distribution of the Types of Incidence
    output$click_inc_pie <- renderPlotly({
      ds <- table(inc_within_range$INCIDENT_CLASSIFICATION_GROUP)
      pie_title <- paste("Incidence Categories", sep="")
      ds <- ds[incident_type]
      ds[is.na(ds)] <- 0
      plot_ly(labels=incident_type, values=ds, type = "pie",
              marker=list(colors=ac_color)) %>%
        layout(title = pie_title,showlegend=F,
               xaxis=list(showgrid=F,zeroline=F,showline=F,autotick=T,ticks='',showticklabels=F),
               yaxis=list(showgrid=F,zeroline=F,showline=F,autotick=T,ticks='',showticklabels=F))
      
    })
  })
  
  # Select the types of the incidents to be visualized
  observeEvent(input$click_incidence_type, {
    
    for(type in incident_type){
      if(type %in% input$click_incidence_type) leafletProxy("map") %>% showGroup(type)
      else{leafletProxy("map") %>% hideGroup(type)}
    }
    
  }, ignoreNULL = FALSE)
  
  # Select all or none of the incidents to be visualize
  observeEvent(input$click_all_incident_type, {
    updateCheckboxGroupInput(session, "click_incidence_type",
                             choices = incident_type,
                             selected = incident_type)
  })
  observeEvent(input$click_none_incident_type, {
    updateCheckboxGroupInput(session, "click_incidence_type",
                             choices = incident_type,
                             selected = NULL)
  })
  
  # allows you to select or deselect to show firehouses
  observeEvent(input$show_firehouses, {
    if("" %in% input$show_firehouses) leafletProxy("map") %>% showGroup("firehouses")
    else{leafletProxy("map") %>% hideGroup("firehouses")}
  }, ignoreNULL = FALSE)
  
  # allows you to select or deselect to show heatmap
  observeEvent(input$show_heatmap, {
    if("" %in% input$show_heatmap) leafletProxy("map") %>% showGroup("heatmap")
    else{leafletProxy("map") %>% hideGroup("heatmap")}
  }, ignoreNULL = FALSE)
  
  ## Analysis Part
  output$dplot1 <- renderPlotly({
    
    v <-  switch(input$a1,
                 c1=T,
                 F)
    if(v==T){
      ggplotly(class1)
    }
    else{
      ggplotly(class2)
    }
  })
  
  output$dplot2 <- renderPlotly({
    
    v <-  switch(input$b1,
                 c1=T,
                 F)
    if(v==T){
      ggplotly(rt)
    }
    else{
      ggplotly(rt2)  
    }
  })
  
  output$dplot3 <- renderPlotly({
    
    v <-  switch(input$c1,
                 c1=T,
                 F)
    
    if(v==T){
      ggplotly(au)
    }
    else{
      ggplotly(au2)  
    }
  })
  
  output$dplot4 <- renderPlotly({
    
    v <- switch(input$d1,
                c1="c1",
                c2="c2",
                c3="c3",
                "c1")
    
    if(v=="c1"){
      ggplotly(seasonal_fires)
    }
    else if(v=="c2"){
      ggplotly(seasonal_medical)
    }
    else if(v=="c3"){
      ggplotly(seasonal_mfa)
    }
  })
  
  
  ## Personalized Stat Part
  # creates a reactive dataframe that has the subsetting needed for the tab1/plot1
  data_stat1 <- reactive(
    clean_fire2_stat1 %>% 
      filter(INCIDENT_BOROUGH == input$stat_borough1,
             INCIDENT_CLASSIFICATION_GROUP %in% input$stat_incident1) %>%
      group_by(YEAR,MONTH) %>%
      summarise(Calls = sum(c1))) 
  
  # make the tab1/plot1: monthly fire department calls by borough by year with selected types of incidents
  output$stat_output1 <- renderPlotly({
    g1 <- ggplot(data_stat1(),aes(x = MONTH,y = Calls,color = factor(YEAR)))+
      geom_point()+
      geom_line()+
      scale_x_continuous(breaks=seq(1, 12, 1))+
      theme_light()+
      labs(x = "Month", y = "Incidents",color = "YEAR",
           title = paste("Monthly Fire Department Calls of",input$stat_borough1,sep = " "))+
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(g1)
  })
  
  # creates a reactive dataframe that has the subsetting needed for the tab1/plot2
  data_stat2 <- reactive(
    clean_fire2_stat1 %>% 
      filter(INCIDENT_BOROUGH %in% input$stat_borough2,
             INCIDENT_CLASSIFICATION_GROUP %in% input$stat_incident2) %>%
      group_by(YEAR,MONTH,INCIDENT_BOROUGH) %>%
      summarise(Calls = sum(c1)))
  
  # make the tab1/plot2: monthly fire department calls by borough from 2013-2018 with selected types of incidents
  output$stat_output2 <- renderPlotly({
    g2 <- data_stat2() %>%
      mutate(Time = MONTH+(YEAR-2013)*12) %>%
      ggplot(aes(x = Time, y = Calls,color = INCIDENT_BOROUGH))+
      geom_point()+
      geom_line()+
      scale_x_continuous(breaks = seq(1,72,2))+
      theme_light()+
      labs(x = "Time", y = "Incidents", color = "Selected Borough",
           title = "Fire Department Calls of Different Borough from 2013-2018")+
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(g2)
  })
  
  # creates a reactive dataframe that has the subsetting needed for the tab2/plot1
  data_stat3 <- reactive(
    clean_fire2_stat2 %>% 
      filter(ZIPCODE == input$stat_zipcode1,
             INCIDENT_CLASSIFICATION_GROUP %in% input$stat_incident3) %>%
      group_by(YEAR,MONTH) %>%
      summarise(Calls = sum(c1)))
  
  # make the tab2/plot1: monthly fire department calls by zipcode by year with selected types of incidents
  output$stat_output3 <- renderPlotly({
    g3 <- ggplot(data_stat3(),aes(x = MONTH,y = Calls,color = factor(YEAR)))+
      geom_point()+
      geom_line()+
      scale_x_continuous(breaks=seq(1, 12, 1))+
      theme_light()+
      labs(x = "Month", y = "Incidents",color = "YEAR",
           title = paste("Monthly Fire Department Calls of",input$stat_zipcode1,sep = " "))+
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(g3)
  })
  
  # creates a reactive dataframe that has the subsetting needed for the tab2/plot2
  data_stat4 <- reactive(
    clean_fire2_stat2 %>% 
      filter(ZIPCODE %in% c(input$stat_zipcode2,input$stat_zipcode3,input$stat_zipcode4),
             INCIDENT_CLASSIFICATION_GROUP %in% input$stat_incident4) %>%
      group_by(ZIPCODE,YEAR,MONTH) %>%
      summarise(Calls = sum(c1)))
  
  # make the tab2/plot2: monthly fire department calls of 3 zipcode from 2013-2018 with selected types of incidents
  output$stat_output4 <- renderPlotly({
    g4 <- data_stat4() %>%
      mutate(Time = MONTH+(YEAR-2013)*12) %>%
      ggplot(aes(x = Time,y = Calls,color = factor(ZIPCODE)))+
      geom_point()+
      geom_line()+
      scale_x_continuous(breaks = seq(1,72,2))+
      theme_light()+
      labs(x = "Time", y = "Incidents", color = "Selected Zipcode",
           title = "Fire Department Calls of Different Zipcode from 2013-2018")+
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(g4)
  })
  
  # creates a reactive dataframe that has the subsetting needed for the tab3/plot1
  data_stat5 <- reactive(
    clean_fire2_stat3 %>%
      filter(INCIDENT_BOROUGH %in% input$stat_borough3,
             INCIDENT_CLASSIFICATION_GROUP %in% input$stat_incident5)
  )
  # make the tab3/plot1: point plot,x = engines assigned, y = ladders assigned
  output$stat_output5 <- renderPlotly({
    g5 <- ggplot(data_stat5(),
                 aes(x = ENGINES_ASSIGNED_QUANTITY, y = LADDERS_ASSIGNED_QUANTITY,color = INCIDENT_CLASSIFICATION_GROUP))+
      geom_point(aes(x = ENGINES_ASSIGNED_QUANTITY, y = LADDERS_ASSIGNED_QUANTITY,color = INCIDENT_CLASSIFICATION_GROUP))+
      geom_abline(slope = 1, intercept = 0)+theme_light()+
      labs(x = "the number of engine units assigned", y = "the number of ladders assigned",color = "Incident Types",
           title = paste(input$stat_borough3,": Engines Assigned * Ladders Assigned"))+
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(g5)
  })
  
  # creates a reactive dataframe that has the subsetting needed for the tab3/plot2
  data_stat6 <- reactive(
    clean_fire2_stat4 %>%
      filter(YEAR == input$stat_year1,MONTH == input$stat_month1,
             INCIDENT_CLASSIFICATION_GROUP %in% input$stat_incident6)
  )
  
  # make the tab3/plot2: assignment of engines of different borough and incident types in one specific month
  output$stat_output6 <- renderPlotly({
    g6 <- ggplot(data_stat6(),aes(x = INCIDENT_BOROUGH, y = c, fill = ENGINES))+
      geom_bar(stat='identity',position='dodge')+ theme_light()+
      labs(x = "Borough", y = "Incidents",color = "Incident Types",
           title = paste("The Number of Engine Units Assigned of Different Borough in ",
                         input$stat_month1,"/",input$stat_year1,sep = ""))+
      theme(plot.title = element_text(hjust = 0.5))
    ggplotly(g6)
    
  })
  
   # creates a reactive dataframe that has the subsetting needed for the tab4
  data_stat7 <- reactive(
    clean_fire2_stat1 %>%
      filter(INCIDENT_BOROUGH == input$stat_borough4,
             INCIDENT_CLASSIFICATION_GROUP %in% input$stat_incident7) %>%
      group_by(YEAR,MONTH) %>%
      summarise(Calls = sum(c1))
  )
  
  #  make the tab4 plot: prediction of one borough/NYC for some selected incidents types
  output$stat_output7 <- renderPlot({
    g7 <- data_stat7()$Calls %>%
      ts(start = c(2013,1),end = c(2018,12),frequency = 12) %>%
      auto.arima() %>%
      forecast(h = 24, level = c(90)) %>%
      autoplot() + theme_light() +
      labs(x = "Year", y = "Incidents",
           title = paste("Forecast of Incidents in",input$stat_borough4, sep = " "))+
      theme(plot.title = element_text(hjust = 0.5))
    g7
  })
  
  output$stat_output8 <- renderText({
    g8 <- data_stat7()$Calls %>%
      ts(start = c(2013,1),end = c(2018,12),frequency = 12) %>%
      auto.arima() %>%
      forecast(h = 24, level = c(90))
    paste("Note: The model is",g8$method, sep = " ")
  })
})
