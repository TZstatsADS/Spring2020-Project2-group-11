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
                 
                 # Map
                 tabPanel("Map",
                          div(class="outer",
                              leafletOutput("map",width="100%",height=780),
                              
                              
                              absolutePanel(id = "control", class = "panel panel-default", fixed= TRUE, draggable = FALSE,
                                            top = 110, left = 60, right = "auto", bottom = "auto", width = 250, height = "auto",
                                            
                                            sliderInput("click_radius", "Radius of area around the selected address", min=500, max=3000, value=250, step=10),
                                            
                                            checkboxGroupInput("click_incident_type", "Alarm Classification",
                                                               choices =c("NonMedical Emergencies", "Medical Emergencies", "NonMedical MFAs", "Medical MFAs", "NonStructural Fires", "Structural Fires"),
                                                               selected =c("NonMedical Emergencies", "Medical Emergencies", "NonMedical MFAs", "Medical MFAs", "NonStructural Fires", "Structural Fires")),
                                            actionButton("click_all_incident_type", "Select ALL"),
                                            actionButton("click_none_incident_type", "Select NONE"),
                                            
                                            checkboxGroupInput("show_firehouses", "Show Firehouses: ",
                                                               choices = "", selected = ""),
                                            
                                            selectInput('year', 'Selected year for the  plot:',
                                                        2013:2018, selected = 2018),
                                            sliderInput("from_hour", "Starting Time", min=0, max=23, value=0, step=1),
                                            sliderInput("to_hour", "End Time", min=0, max=23, value=23, step=1),
                                            style = "opacity: 0.80"
                                            
                              ),
                              
                              absolutePanel(id = "controls", class = "panel panel-default", fixed= TRUE, draggable = FALSE,
                                            top = 110, left = "auto", right = 20, bottom = "auto", width = 320, height = "auto",
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
                              )
                              
                          )
                 ),
                 
                 
                 
                 
                 
                 
                 
                 
                 # Report
                 tabPanel("Report",icon = icon("bar-chart-o"),
                          h2("Summary Statistics"),
                          
                          wellPanel(style = "overflow-y:scroll; height: 850px; max-height: 750px; background-color: #ffffff;",
                                    tabsetPanel(type="tabs",
                                                
                                                tabPanel(title="a",
                                                         br(),
                                                         div(plotlyOutput(""), align="center")
                                                         # sidebarLayout(position="left",
                                                         #               sidebarPanel("sidebar panel"),
                                                         #               mainPanel("main panel"))
                                                         
                                                ),
                                                tabPanel(title="b",
                                                         br(),
                                                         div(plotlyOutput(""), align="center")
                                                         
                                                ),
                                                tabPanel(title="c",
                                                         br(),
                                                         div(align="center" )
                                                         
                                                ),
                                                tabPanel(title="d",
                                                         br(),
                                                         div(align="center" )
                                                         
                                                )
                                                
                                    )
                          )
                 ),
                 
                 
                 # Interactive Stat
                 tabPanel("Interactive Stat",icon = icon("industry"),
                          h2("Summary Statistics"),
                          
                          wellPanel(style = "overflow-y:scroll; height: 850px; max-height: 750px; background-color: #ffffff;",
                                    tabsetPanel(type="tabs",
                                                
                                                tabPanel(title="a",
                                                         br(),
                                                         div(plotlyOutput(""), align="center"),
                                                         # sidebarLayout(position="left",
                                                         #               sidebarPanel("sidebar panel"),
                                                         #               mainPanel("main panel"))
                                                         # 
                                                ),
                                                tabPanel(title="b",
                                                         br(),
                                                         div(plotlyOutput(""), align="center")
                                                         
                                                ),
                                                tabPanel(title="c",
                                                         br(),
                                                         div(img(src="", width="90%"), align="center" )
                                                         
                                                ),
                                                tabPanel(title="d",
                                                         br(),
                                                         div(img(src="", width="90%"), align="center" )
                                                         
                                                )
                                                
                                                
                                    )
                          )
                 ),
                 
                 
                 
                 # Info
                 tabPanel("Info",icon = icon("info"),
                          
                          mainPanel(width=15,
                                    setBackgroundImage(
                                      src = "/Users/liujiawei/Desktop/fdny.jpg"
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




              
                 
                
                 
