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
                 tabPanel("Analysis",icon = icon("bar-chart-o"),
                          wellPanel(style = "overflow-y:scroll; height: 850px; max-height: 750px; background-color: #ffffff;",
                                    tabsetPanel(type="tabs",
                                                
                                                tabPanel("Response Time", 
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             radioButtons("b1","Time",c("By Borough"="c1","By Classification"="c2")
                                                             )
                                                           ),         
                                                           mainPanel(
                                                             plotlyOutput("dplot2",width="700px",height="auto"),
                                                             HTML(paste(h4("Clearly Brooklyn leads the pack for response time year over year. Steady growth in response times for all boroughs (excluding Staten Island) is present except for the year 2018 where there is a greater increase in response time for all of New York City. The average response time by incident classification seems appropriate as more urgency is given to higher priority incidents."),
                                                                        "Recommendation: Further analysis into why Brooklyn produces the best response time is warranted for possible component reproduction in other boroughs. Further investigation into why the greater increase for the year 2018 is also suggested.",
                                                                        sep="<br/>"))
                                                           )
                                                         )  
                                                ),
                                                
                                                tabPanel("Classification",
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             radioButtons("a1","Class",c("All Classification"="c1","Without Medical and Non-Medical Emergencies"="c2")
                                                             )
                                                           ),         
                                                           mainPanel(
                                                             plotlyOutput("dplot1",width="700px",height="auto"),
                                                             HTML(paste(h4("By separating the number of incidents by incident class, there is a clear discrepancy between the amount of medical and non-medical incident calls and the rest of the classes. Medical and non-medical incidents comprise the vast majority of the FDNY's responsibilities. When Medical and non-medical emergencies are removed from the equation, the highest number of incidences come from structural fires. "),
                                                                        "Recommendation: Further inquiry is suggested into the utilization of resources by FDNY for Medical and non-Medical Emergencies (possible alternative asset strategies are possible for increased efficiency within departmental calls).",
                                                                        "*MFA: Malicious False Alarm",
                                                                        sep="<br/>"))
                                                           )
                                                         )  
                                                ),
                                                tabPanel("Assigned Units",
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             radioButtons("c1","Units",c("Engines Response"="c1","Other"="c2")
                                                             )
                                                           ),         
                                                           mainPanel(
                                                             plotlyOutput("dplot3",width="700px",height="auto"),
                                                             HTML(paste(h4("There is a clear increase, year over year, of assigned Engines per incidences of Medical and non-medical Emergencies for all New York City. Since 2015 there has been a decrease in Other (non Engine/Ladder) Vehicles assigned to Medical and Non-Medical Emergencies. "),
                                                                        "Recommendation: Further investigation is warranted as to why there is an increase of fire engines (which are built for the main purpose of fighting fire) assigned to the vast number of FDNY calls to non-fire related, medical and non-medical emergencies. Whereas, Other Units that include FDNY Medical and FDNY EMS vehicles, are on the decline to Medical and non-Medical incidences. Alternative asset strategies should be considered for increased efficiency of departmental calls. ",
                                                                        sep="<br/>"))
                                                           )
                                                         )  
                                                ),
                                                
                                                tabPanel("Seasonal",
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             radioButtons("d1","Class",c("Fires"="c1","Emergencies"="c2","MFAs"="c3")
                                                             )
                                                           ),         
                                                           mainPanel(
                                                             plotlyOutput("dplot4",width="700px",height="auto"),
                                                             HTML(paste(h4("A clear seasonal pattern exists for Structural and Non-Structural Fires with a rise in the winter months, November through April (peaking in January), and fall in the summer months, May through October. Medical and Non-Medical Emergencies show similar patterns by month, year over year, with a gradual rise in the spring, peaking in August, and tapering in the fall (except for a sharp uncharacteristic up spike in January). MFAs (Malicious False Alarms) also follow a clear seasonal pattern, peaking in July and bottoming out in February."),
                                                                        "Recommendation: Consideration to seasonal adjustments and preparations could be made to FDNY resources. Flexible full-time staff, volunteer workers, and adaptable vehicles could possibly be allocated to seasonal demand by classification of incidences. For example, such flexible assets could be utilized for the larger amount of fire calls in the winter and then changed to focus on the higher number of MFAs in the summer. Additional investigation could be possible to explain the sharp rise in Medical and Non-Medical Emergencies in the month of January. Further research into seasonal adaptations for the FDNY is justified. ",
                                                                        sep="<br/>"))
                                                           )
                                                         )  
                                                )
                                                
                                    )
                          )
                 ),
                 
                 
                 # Interactive Stat
                 tabPanel("Personalized Stat",icon = icon("industry"),
                          
                          wellPanel(style = "overflow-y:scroll; height: 850px; max-height: 750px; background-color: #ffffff;",
                                    tabsetPanel(type="tabs",
                                                
                                                # first tab:by borough
                                                tabPanel("Monthly Calls by Borough and Identification Group",
                                                         br(),
                                                         # 1st plot, monthly selected types of fire calls grouped by year of selected borough
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             selectInput("stat_borough1","Borough:",
                                                                         borough_list,selected = "MANHATTAN"),
                                                             checkboxGroupInput("stat_incident1","Types of Fire Department Calls:",
                                                                                choices = incident_list, selected = incident_list),
                                                             width = 3),
                                                           mainPanel(plotlyOutput("stat_output1", height = "300px"))),
                                                         hr(),
                                                         # 2nd plot, compare selected types of fire calls of different selected borough
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             checkboxGroupInput("stat_borough2","Borough:",
                                                                                choices = c(borough_list,"NEW YORK CITY"), selected = borough_list),
                                                             checkboxGroupInput("stat_incident2","Types of Fire Department Calls:",
                                                                                choices = incident_list, selected = incident_list),
                                                             width = 3),
                                                           mainPanel(plotlyOutput("stat_output2", height = "350px")))
                                                ),
                                                
                                                # second tab: by zipcode
                                                tabPanel("Monthly Calls by Zipcode and Identification Group",
                                                         br(),
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             textInput("stat_zipcode1", "Zipcode", value = "10001"),
                                                             checkboxGroupInput("stat_incident3","Types of Fire Department Calls:",
                                                                                choices = incident_list, selected = incident_list),
                                                             width = 3),
                                                           mainPanel(plotlyOutput("stat_output3",height = "300px"))),
                                                         hr(),
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             textInput("stat_zipcode2", "Zipcode1", value = "10001"),
                                                             textInput("stat_zipcode3", "Zipcode2", value = "10002"),
                                                             textInput("stat_zipcode4", "Zipcode3", value = "10003"),
                                                             checkboxGroupInput("stat_incident4","Types of Fire Department Calls:",
                                                                                choices = incident_list, selected = incident_list),
                                                             width = 3),
                                                           mainPanel(plotlyOutput("stat_output4",height = "300px")))
                                                ),
                                                
                                                # third tab: borough * incident
                                                tabPanel("Units Assigned in the Incident",
                                                         br(),
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             selectInput("stat_borough3","Borough:",
                                                                         borough_list,selected = "MANHATTAN"),
                                                             checkboxGroupInput("stat_incident5","Types of Fire Department Calls:",
                                                                                choices = incident_list, selected = "Structural Fires"),
                                                             width = 3),
                                                           mainPanel(plotlyOutput("stat_output5", height = "300px",width = "100%"),width = 9)),
                                                         hr(),
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             selectInput("stat_year1","Year:",
                                                                         2013:2018,selected = 2018),
                                                             selectInput("stat_month1","Month:",
                                                                         1:12,selected = 1),
                                                             checkboxGroupInput("stat_incident6","Types of Fire Department Calls:",
                                                                                choices = incident_list, selected = "Structural Fires"),
                                                             width = 3),
                                                           mainPanel(plotlyOutput("stat_output6",height = "300px",width = "100%"),width = 9)
                                                         )
                                                ),
                                                
                                                # forth tab: prediction
                                                tabPanel("Prediction",
                                                         br(),
                                                         sidebarLayout(
                                                           sidebarPanel(
                                                             selectInput("stat_borough4","Borough:",
                                                                         c(borough_list,"NEW YORK CITY"),selected = "MANHATTAN"),
                                                             checkboxGroupInput("stat_incident7","Types of Fire Department Calls:",
                                                                                choices = incident_list,selected = incident_list),
                                                             width = 3
                                                           ),
                                                           mainPanel(plotOutput("stat_output7"),
                                                                     br(),
                                                                     textOutput("stat_output8"))
                                                         ))
                                                
                                                
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




              
                 
                
                 
