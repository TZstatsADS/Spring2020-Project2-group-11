library(shiny)
library(leaflet)
library(data.table)
library(plotly)
library(shinythemes)
library(shinyWidgets)

shinyUI(fluidPage(
  tabPanel("Heatmap Fire Department Calls",
           titlePanel("Heat Map: Number of Fire Department Calls in NYC"),
           
           sidebarLayout(
             
             # Main panel for displaying outputs ----
             mainPanel(
               
               # Output: Heat Map ----
               leafletOutput("heatMap",width="100%",height=700)),
                  sidebarPanel(
                    checkboxGroupInput("incident", "Types of Fire Department Calls:",
                        choices = c("Medical Emergencies","Medical MFAs","NonMedical Emergencies", 
                                    "NonMedical MFAs", "Structural Fires", "NonStructural Fires"),
                        selected = c("Medical Emergencies","Medical MFAs","NonMedical Emergencies", 
                                     "NonMedical MFAs", "Structural Fires", "NonStructural Fires")),
                    actionButton("click_all_incident_types", "Select ALL"),
                    actionButton("click_no_incident_types", "Select NONE")
                              )
                      )
                  )
))