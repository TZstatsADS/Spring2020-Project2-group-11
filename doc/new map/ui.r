library(shiny)
library(leaflet)
library(data.table)
library(plotly)
library(shinythemes)
library(shinyWidgets)
library(shinydashboard)




shinyUI(
  div(id="canvas",
      
      navbarPage(strong("Emergency Response of FDNY",style="color: white;"),
                 theme = shinytheme("united"),
                 
                 # Info
                 tabPanel("Info",icon = icon("home"),
                          
                          mainPanel(width=15,
                                    setBackgroundImage(
                                      src = "../background.jpg"
                                    ),
                                    
                                    style = "opacity: 0.80",
                                    h1("An Overview of FDNY"),
                                    p("The Fire Department of the City of New York (FDNY) is the largest Fire Department in the United States and universally is recognized as the world's busiest and most highly skilled emergency response agency.
                                        The Department's main goal is to provide fire protection, emergency medical care, and other critical public safety services to residents and visitors in the five boroughs.
                                        The Department also works to continually educate the public in fire, life safety and disaster preparedness, along with enforcing public safety codes."),
                                    br(),
                                    h4("Emergency Services of FDNY (Dial 911)"),
                                    p("fire, smoke or fumes, odor of gas, medical emergency"),
                                    br(),
                                    h4("Non-Emergency Services of FDNY (Dial 311)"),
                                    br(),
                                    h3("Additional Information"),
                                    p(em(a("Learn more about how to call for help in an Emergency for the Deaf & Hard of Hearing, known as the Tapping Protocal. (CC)",
                                           href="https://www1.nyc.gov/site/fdny/about/resources/reports-and-publications/hearing-impaired-deaf-cc-page.page"))),
                                    # h3(""),
                                    # p(""),
                                    # p(em(a("",href=""))),
                                    
                                    br(),
                                    br(),
                                    h1("Our Motivation"),
                                    p("Our Shiny App is about all the emergency reports related to FDNY, constructing a map to clearly visualize the emergency locations.
                                        Our main target audience is the FDNY. This app can help them easily understand the overall situations in NYC, making rational allocation
                                        of resources. It will be meaningful if they deploy more firehouses within the area of higher emergency frequencies in the city. What's more,
                                        New York citizens are also encouraged to check our app when considering the safety factors of their future houses."),
                                    p(em(a("Github link",href="https://github.com/TZstatsADS/Spring2020-Project2-group-11")))
                          ),
                          div(class="footer", "Group Project by Rui Wang, Daniel Schmidle, Huize Huang, Ivan Wolansky, Jiawei Liu")
                 ),
                 
                 
                 # Map
                 tabPanel("Map",icon = icon("map"),
                          dashboardPage(dashboardHeader(title = "Map",titleWidth = 300),
                                        dashboardSidebar(width = 300,
                                                         sidebarMenu(
                                                           sliderInput("click_radius", "Radius of area around the selected address", min=500, max=3000, value=250, step=10),
                                                           
                                                           checkboxGroupInput("click_inceidence_type", "Alarm Classification",
                                                                              choices = c("Structural Fires", "NonStructural Fires", "Medical Emergencies", "NonMedical Emergencies", "NonMedical MFAs", "Medical MFAs"), 
                                                                              selected = c("Structural Fires", "NonStructural Fires", "Medical Emergencies", "NonMedical Emergencies", "NonMedical MFAs", "Medical MFAs")),
                                                           actionButton("click_all_incident_type", "Select ALL"),
                                                           actionButton("click_none_incident_type", "Select NONE"),
                                                           
                                                           checkboxGroupInput("show_firehouses", "Show Firehouses: ", choices = "", selected = ""), 
                                                           checkboxGroupInput("show_heatmap", "Show HeatMap: ", choices = "", selected = ""), 
                                                           
                                                           selectInput('year', 'Selected year for the plot:', 
                                                                       2013:2018, selected = 2018), 
                                                           selectInput('month', 'Selected month for the plot:', 
                                                                       1:12, selected = 1)
                                                         )
                                                         ),
                                        dashboardBody(
                                          #leafletOutput("map",width="100%",height=500)
                                          fluidRow(column(4,
                                                          h3("Summary of the Covered Area"),
                                                          h4("The Geographical Information"),
                                                          p(textOutput("click_coord")),
                                                          h4("The Alarm Index"),
                                                          p(strong(textOutput("click_alarm_index_red", inline = T))),
                                                          tags$head(tags$style("#click_alarm_index_red{color: red;
                                                          font-size: 20px;
                                                          font-style: italic;
                                                          }"
                                                          )
                                                          ),
                                                          p(strong(textOutput("click_alarm_index_orange", inline = T))),
                                                          tags$head(tags$style("#click_alarm_index_orange{color: orange;
                                                          font-size: 20px;
                                                          font-style: italic;
                                                          }"
                                                          )
                                                          ),
                                                          p(strong(textOutput("click_alarm_index_green", inline = T))),
                                                          tags$head(tags$style("#click_alarm_index_green{color: green;
                                                          font-size: 20px;
                                                          font-style: italic;
                                                           }"
                                                          )
                                                          ),
                                                          h4("Number of Incidences in Selected Area"),
                                                          p(strong(textOutput("click_inc_total", inline = T)), " in total year."),
                                                          p(strong(textOutput("click_inc_per_day", inline = T)), " per day."),
                                                          
                                                          br(),
                                                          h4("Pie chart of the distribution of incident classification"),
                                                          style = "opacity: 0.80",
                                                          br(),
                                                          plotlyOutput("click_inc_pie",height="300")
                                                          ),
                                                  column(8, 
                                                         leafletOutput("map", height = "700px"))
                                                  )
                                        )
                                        )
                                        ),
                 
                 
                 
                 # Source
                 tabPanel("Source",icon = icon("list-alt"),
                          div(width = 12,
                              h1(""), # title for data tab
                              br(),
                              dataTableOutput('table1'),
                              
                              h1(""), # title for data tab
                              br(),
                              dataTableOutput('table2')
                          ),
                          # footer
                          div(class="footer", em(a("Data origniated from NYC Open Data",href="")))
                          
                 )
      )
      
  )
)