# Project 2: Shiny App Development Version 2.0

### [Project Description](doc/project2_desc.md)

![screenshot](doc/screenshot1.png)

In this second project of GR5243 Applied Data Science, we develop a version 2.0 of an *Exploratory Data Analysis and Visualization* shiny app on emergency reports related to FDNY using [NYC Open Data](https://data.cityofnewyork.us/Public-Safety/Fire-Incident-Dispatch-Data/8m42-w767). See [Project 2 Description](doc/project2_desc.md) for more details.  

The **learning goals** for this project is:

- business intelligence for data science
- study legacy codes and further development
- data cleaning
- data visualization
- systems development/design life cycle
- shiny app/shiny server

*The above general statement about project 2 can be removed once you are finished with your project. It is optional.

## Emergency Response of FDNY
Term: Fall 2019

+ Team # 11
+ **Emergency Response of FDNY**:
	+ Rui Wang
	+ Daniel Schmidle
	+ Huize Huang
	+ Ivan Wolansky
	+ Jiawei Liu

+ **Click me**: [Emergency Response of FDNY](https://iaw2110.shinyapps.io/FireApp/)

+ **Project summary**: Our Shiny App is about all the emergency reports related to FDNY, constructing a map to clearly visualize the emergency locations. Our main target audience is the FDNY. This app can help them easily understand the overall situations in NYC, making rational allocation of resources. It will be meaningful if they deploy more firehouses within the area of higher emergency frequencies in the city. What's more, New York citizens are also encouraged to check our app when considering the safety factors of their future houses.

+ **Contribution statement**: ([contribution statement](doc/a_note_on_contributions.md)) All team members discussed and decided the theme for our app. Ivan did the initial transformation of longitude and latitude data, and then developed the heat map. Rui developed the ‘Alarm Classification’ model and realized interactive effects on the map, and also prepared for the presentation. Daniel explored all the data set and developed the ‘Analysis’ part. Huize explored all the data set and developed the ‘Personalized Stat’ part. Jiawei developed the layout of the whole app and wrote the ‘Info’ page. Rui, Huize and Jiawei integrated all the codes of our app. Rui made some improvements on the layout. Huize and Jiawei contributed to the Readme file. All team members contributed to the publish and deploy process of our app. (To successfully deploy the app, we upgraded the account)

Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── app/
├── lib/
├── data/
├── doc/
└── output/
```

Please see each subfolder for a README file.

