library(shiny)
library(leaflet)
library(data.table)
library(plotly)
library(shinythemes)
library(dplyr)
library(forecast)

## dataset for stat repo


## dataset for personalized stat analysis
borough_list <- c("BRONX","BROOKLYN","MANHATTAN","QUEENS","RICHMOND / STATEN ISLAND")
incident_list <- c("Medical Emergencies","Medical MFAs","NonMedical Emergencies", 
                   "NonMedical MFAs", "Structural Fires", "NonStructural Fires")

# dataset for tab1
clean_fire2_stat1 <- group_by(clean_fire2,
                              INCIDENT_BOROUGH,YEAR,MONTH,INCIDENT_CLASSIFICATION_GROUP) %>%
  summarise(c1 = n()) %>%
  rbind(group_by(clean_fire2,YEAR,MONTH,INCIDENT_CLASSIFICATION_GROUP) %>%
          summarise(c1 = n()) %>%
          mutate(INCIDENT_BOROUGH = "NEW YORK CITY"))

# dataset for tab2
clean_fire2_stat2 <-  group_by(clean_fire2,
                               ZIPCODE,YEAR,MONTH,INCIDENT_CLASSIFICATION_GROUP) %>%
  summarise(c1 = n())

# dataset for tab3
clean_fire2_stat3 <- clean_fire2 %>%
  select(INCIDENT_BOROUGH,YEAR,MONTH,INCIDENT_CLASSIFICATION_GROUP,
         ENGINES_ASSIGNED_QUANTITY,LADDERS_ASSIGNED_QUANTITY) %>%
  mutate(ENGINES = factor(case_when(
    ENGINES_ASSIGNED_QUANTITY == 0 ~ "No Engines Assigned",
    ENGINES_ASSIGNED_QUANTITY == 1 ~ "1 Engines Assigned",
    ENGINES_ASSIGNED_QUANTITY >1 & ENGINES_ASSIGNED_QUANTITY<6 ~ "2~5 Engines Assigned",
    ENGINES_ASSIGNED_QUANTITY >5 & ENGINES_ASSIGNED_QUANTITY<11 ~ "6~10 Engines Assigned",
    ENGINES_ASSIGNED_QUANTITY>10 & ENGINES_ASSIGNED_QUANTITY<26 ~ "11~25 Engines Assigned",
    ENGINES_ASSIGNED_QUANTITY>25 ~ "More than 25 Engines Assigned"
  )))

# dataset for tab4
clean_fire2_stat4 <- clean_fire2_stat3 %>%
  group_by(INCIDENT_BOROUGH,YEAR,MONTH,INCIDENT_CLASSIFICATION_GROUP,ENGINES) %>%
  summarise(c = n())
