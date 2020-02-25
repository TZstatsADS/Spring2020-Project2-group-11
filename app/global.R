library(shiny)
library(leaflet)
library(data.table)
library(plotly)
library(shinythemes)
library(dplyr)
library(forecast)

load(file="clean_fire2.RData")

## dataset for stat repo
# tab1/plot1
class1 <- clean_fire2 %>% 
  group_by(INCIDENT_CLASSIFICATION_GROUP,YEAR) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = YEAR,y = n,color = factor(INCIDENT_CLASSIFICATION_GROUP)))+
  geom_point()+
  geom_line()+
  scale_x_continuous(breaks=seq(2013, 2018, 1))+
  scale_y_continuous(labels = scales::comma)+
  ggtitle("Number of Incidences by Classification") +
  xlab("Year") + ylab("Incidents") + labs(color="Classification")

# tab1/plot2
class2 <- clean_fire2 %>% 
  filter(!INCIDENT_CLASSIFICATION_GROUP %in% c("Medical Emergencies","NonMedical Emergencies")) %>%
  group_by(INCIDENT_CLASSIFICATION_GROUP,YEAR) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = YEAR,y = n,color = factor(INCIDENT_CLASSIFICATION_GROUP)))+
  geom_point()+
  geom_line()+
  scale_x_continuous(breaks=seq(2013, 2018, 1))+
  scale_y_continuous(labels = scales::comma)+
  ggtitle("Number of Incidences by Classification") +
  xlab("Year") + ylab("Incidents") + labs(color="Classification")

# tab2/plot1
rt <- clean_fire2 %>% 
  filter(VALID_INCIDENT_RSPNS_TIME_INDC == "Y") %>%
  group_by(INCIDENT_BOROUGH,YEAR) %>%
  summarise(n = mean(INCIDENT_RESPONSE_SECONDS_QY)) %>%
  ggplot(aes(x = YEAR,y = n,color = factor(INCIDENT_BOROUGH)))+
  geom_point()+
  geom_line()+
  scale_x_continuous(breaks=seq(2013, 2018, 1))+
  ggtitle("Average Response Time per Borough ") +
  xlab("Year") + ylab("Time in Seconds") + labs(color="Borough")

# tab2/plot2
rt2 <- clean_fire2 %>% 
  filter(VALID_INCIDENT_RSPNS_TIME_INDC == "Y") %>%
  group_by(INCIDENT_CLASSIFICATION_GROUP,YEAR) %>%
  summarise(n = mean(INCIDENT_RESPONSE_SECONDS_QY)) %>%
  ggplot(aes(x = YEAR,y = n,color = factor(INCIDENT_CLASSIFICATION_GROUP)))+
  geom_point()+
  geom_line()+
  scale_x_continuous(breaks=seq(2013, 2018, 1))+
  ggtitle("Average Response Time by Classification") +
  xlab("Year") + ylab("Time in Seconds") + labs(color="Classification")

# tab3/plot1
au <- clean_fire2 %>% 
  filter(INCIDENT_CLASSIFICATION_GROUP %in% c("Medical Emergencies","NonMedical Emergencies")) %>%
  filter(ENGINES_ASSIGNED_QUANTITY>=1) %>%
  group_by(INCIDENT_BOROUGH,YEAR) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = YEAR,y = n,color = factor(INCIDENT_BOROUGH)))+
  geom_point()+
  geom_line()+
  scale_x_continuous(breaks=seq(2013, 2018, 1))+
  scale_y_continuous(labels = scales::comma)+
  ggtitle("Fire Engines Assigned to Medical and NonMedical Emergencies") +
  xlab("Year") + ylab("Number of Assigned Engines") + labs(color="Borough")

# tab3/plot2
au2 <- clean_fire2 %>% 
  filter(INCIDENT_CLASSIFICATION_GROUP %in% c("Medical Emergencies","NonMedical Emergencies")) %>%
  filter(OTHER_UNITS_ASSIGNED_QUANTITY >=1) %>%
  group_by(INCIDENT_BOROUGH,YEAR) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = YEAR,y = n,color = factor(INCIDENT_BOROUGH)))+
  geom_point()+
  geom_line()+
  scale_x_continuous(breaks=seq(2013, 2018, 1))+
  ggtitle("Other Units Assigned to Medical and NonMedical Emergencies") +
  xlab("Year") + ylab("Assigned Engines") + labs(color="Classification")

# tab4/plot1
seasonal_fires <- clean_fire2 %>% 
  filter(INCIDENT_CLASSIFICATION_GROUP %in% c("Structural Fires","NonStructural Fires")) %>%
  group_by(YEAR,MONTH) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = MONTH,y = n ,color = factor(YEAR)))+
  geom_point()+
  geom_line()+
  scale_x_continuous(breaks=seq(1, 12, 1))+
  ggtitle("Structural and Non-Structural Fires by Month") +
  xlab("Month") + ylab("Incidents") + labs(color="Year")

# tab4/plot2
seasonal_mfa <- clean_fire2 %>% 
  filter(INCIDENT_CLASSIFICATION_GROUP %in% c("NonMedical MFAs","Medical MFAs")) %>%
  group_by(YEAR,MONTH) %>%
  summarise(n = n()) %>%
  ggplot(aes(x = MONTH,y = n,color = factor(YEAR)))+
  geom_point()+
  geom_line()+
  scale_x_continuous(breaks=seq(1, 12, 1))+
  ggtitle("Medical and Non-Medical MFAs by Month") +
  xlab("Month") + ylab("Incidents") + labs(color="Year")

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
