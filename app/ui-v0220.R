#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# install.packages("shinydashboard")
# install.packages("leaflet")

library(shiny)
library(shinydashboard)

# # install.packages("devtools")
# library(devtools)
# # install_github("nik01010/dashboardthemes")
# 


library(shiny)
library(leaflet)
library(data.table)
library(plotly)
library(shinythemes)
library(shinyWidgets)



shinyUI(
    div(id="canvas",

        navbarPage(strong("Emergency Response of FDNY",style="color: white;"),
                   theme = shinytheme("united"),
                   


                   # Map
                   tabPanel("Map",icon = icon("map"),
                            dashboardPage(dashboardHeader(title = "Map",titleWidth = 300),
                                          dashboardSidebar(width = 300,
                                                           sidebarMenu(
                                                               menuItem("dashboard",tabName = "dashboard",icon = icon("dashboard")),
                                                               menuItem("widgets",icon = icon("th"),tabName = "widgets",badgeLabel = "new",badgeColor = "green")
                                                           )),
                                          dashboardBody())),
                   
                   
                   
                   
                   
                   # tabPanel("Map",icon = icon("map"),
                   #          div(class="tab",
                   #              leafletOutput("map",width="100%",height=700),
                   # 
                   # 
                   #              absolutePanel(id = "control", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                   #                            top = 170, left = 20, right = "auto", bottom = "auto", width = 250, height = "auto",
                   # 
                   #                            checkboxGroupInput("enable_markers", "Children Grades for Activities Search:",
                   #                                               choices = c("Elementary School","Middle School","High School"),
                   #                                               selected = c("Elementary School","Middle School","High School")),
                   # 
                   #                            sliderInput("click_radius", "Radius of area around  the selected address", min=500, max=3000, value=250, step=10),
                   # 
                   #                            checkboxGroupInput("click_violence_type", "Violence Types",
                   #                                               choices =c("VIOLATION","MISDEMEANOR", "FELONY"), selected =c("VIOLATION","MISDEMEANOR", "FELONY")),
                   #                            actionButton("click_all_crime_types", "Select ALL"),
                   #                            actionButton("click_none_crime_types", "Select NONE"),
                   # 
                   #                            sliderInput("from_hour", "Starting Time", min=0, max=23, value=0, step=1),
                   #                            sliderInput("to_hour", "End Time", min=0, max=23, value=23, step=1),
                   #                            style = "opacity: 0.80"
                   # 
                   #              ),
                   # 
                   #              absolutePanel(id = "controls", class = "panel panel-default", fixed= TRUE, draggable = TRUE,
                   #                            top = 70, left = "auto", right = 20, bottom = "auto", width = 320, height = "auto",
                   #                            h3("Summary of the Covered Area"),
                   #                            h4("The Geographical Information"),
                   #                            p(textOutput("click_coord")),
                   #                            h4("The Danger Index"),
                   #                            p(strong(textOutput("click_danger_index_red", inline = T))),
                   #                            tags$head(tags$style("#click_danger_index_red{color: red;
                   #                          font-size: 20px;
                   #                          font-style: italic;
                   #                          }"
                   #                            )
                   #                            ),
                   #                            p(strong(textOutput("click_danger_index_orange", inline = T))),
                   #                            tags$head(tags$style("#click_danger_index_orange{color: orange;
                   #                          font-size: 20px;
                   #                          font-style: italic;
                   #                          }"
                   #                            )
                   #                            ),
                   #                            p(strong(textOutput("click_danger_index_green", inline = T))),
                   #                            tags$head(tags$style("#click_danger_index_green{color: green;
                   #                          font-size: 20px;
                   #                                               font-style: italic;
                   #                                               }"
                   #                            )
                   #                            ),
                   #                            h4("Number of Crimes in Selected Area"),
                   #                            p(strong(textOutput("click_crimes_total", inline = T)), " in total (year 2018)."),
                   #                            p(strong(textOutput("click_crimes_per_day", inline = T)), " per day."),
                   # 
                   #                            br(),
                   #                            h4("Bar chart of the distribution of crimes"),
                   #                            style = "opacity: 0.80",
                   #                            br(),
                   #                            plotlyOutput("click_crime_pie",height="300")
                   #              )
                   # 
                   #          )
                   # ),

                   # Heatmap
                   # tabPanel("Heatmap",icon = icon("anchor"),
                   #          titlePanel("Heat Map: After-School Facilities (NYC)"),
                   # 
                   #          sidebarLayout(
                   # 
                   #              # Sidebar panel for inputs ----
                   # 
                   # 
                   #              # Main panel for displaying outputs ----
                   #              mainPanel(
                   #                  # Output: Heat Map ----
                   #                  leafletOutput("heatMap",width="100%",height=700)),
                   #              sidebarPanel(
                   # 
                   #                  # Input: Slider for time of the day ----
                   # 
                   # 
                   #                  sliderInput(inputId = "time",
                   #                              label = "Select time (in hours):",
                   #                              min = 0,
                   #                              max = 23,
                   #                              value = 12)
                   #              )
                   # 
                   #          )
                   # ),
                   # 
                   # 
                   # 

                   # Report
                   tabPanel("Report",icon = icon("bar-chart-o"),
                            h2("Summary Statistics"),

                            wellPanel(style = "overflow-y:scroll; height: 850px; max-height: 750px; background-color: #ffffff;",
                                      tabsetPanel(type="tabs",

                                                  tabPanel(title="a",
                                                           br(),
                                                           div(plotlyOutput(""), align="center"),
                                                           sidebarLayout(position="left",
                                                                         sidebarPanel("sidebar panel"),
                                                                         mainPanel("main panel"))

                                                  ),
                                                  tabPanel(title="b",
                                                           br(),
                                                           div(plotlyOutput(""), align="center")

                                                  ),
                                                  tabPanel(title="",
                                                           br(),
                                                           div(img(src="Bar_plot_activities.png", width="90%"), align="center" )

                                                  )


                                      )
                            )
                   ),
                   
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



