#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(devtools)
library(shinyjs)
library(dplyr)
library(plotly)
library(DT)

mh <- read.csv("./data/Cleansed.csv",stringsAsFactors = FALSE)

mh$Org_size[mh$Org_size == ""] <-  "Missing"

mh[,"Org_size"] <- as.factor(mh[,"Org_size"]) %>% 
  forcats::fct_relevel("1-5","6-25","26-100","100-500","500-1000","More than 1000","Missing")

mh[,"Gender"] <- as.factor(mh[,"Gender"])

Org_size <- levels(mh[,"Org_size"])
Org_size <- Org_size[-length(Org_size)]

#Dashboard Header
dash_header <- dashboardHeader(
  title = "Mental health survey"
)

#Dashbord sidebar
dash_sidebar <- dashboardSidebar(
  tags$head(tags$style(HTML('
      .skin-red .left-side, .skin-red .main-sidebar, .skin-red .wrapper{
                            background-color: #696969;
                            }
                            '))),
  width = 150,
  sidebarMenu(id = "sidebarmenu",
    menuItem("Exploration", tabName = "exploration", icon =  icon("bar-chart-o")),
    menuItem("Models", tabName = "models", icon = icon("line-chart")),
    # menuItem("Data", tabName = "data", icon = icon("table")),
    menuItem("Resources", tabName = "resources", icon = icon("comment"))
  )
)

#Exploration page sidebar
sidebar_expl <- sidebarPanel(
  
  h5("Note: Filters affect data on the map as well as table"),
  sliderInput(inputId = "age",
              label = "Age:",
              min = 15,
              max = 75,
              value = c(20, 40)),
  selectInput(inputId = "gender", 
              label = "Gender",
              choices = c("Select all",levels(mh[,"Gender"])),
              selected = "Select all"),
  # Input: dropdown for self-employed----
  selectInput(inputId = "Self_employed",
              label = "Diagnosed with mentall illness",
              choices = c("Select all",
                          "Yes",
                          "No"),
              selected = "Select all"),
  radioButtons(inputId = "tech", 
               label = "Tech company?", 
               c("Select all",
                 "Yes",
                 "No"), 
               selected = c("Select all")),
  checkboxGroupInput("compsize", 
                     label = "Size of company", 
                     choices = c(Org_size),
                     selected = c(Org_size)),
  width = 3
)


#Exploration page layout
expl_tab <- fluidPage(
  titlePanel("Survey response in the US from 2016"),
  sidebarLayout(
    sidebar_expl,
    mainPanel(
      h4("Click on state in the map to view detailed data in the table below. Hover over state to view more information"),
      plotlyOutput("plotmap"),
      HTML('<br/>'),
      h2("Data Table"),
      DT::dataTableOutput("mytable")
      )
  )
)

#Logistic model
model_tab <- fluidPage(
    mainPanel(
      h4("Does age of respondent in the US have any effect on their mental state?"),
      h5("Note: 1- people who have been diagnosed with mentall illness and 0 -people who haven't been diagnosed"),
      h5("Filters from previous page are not carried over. This is a static graph."),
      plotOutput("Model_map")
    )
)

# Dashboard body
dash_body <- dashboardBody(

  tabItems(
    tabItem(tabName = "exploration",
            expl_tab
    ),
    tabItem(tabName = "models",
            h2("Models"),
            model_tab,
            h4("Summary of the results"),
            verbatimTextOutput("model_output")
    ),
    # tabItem(tabName = "data",
    #         h2("Data")),
    tabItem(tabName = "resources",
            h2("Links"),
            uiOutput("OSMI"),
            uiOutput("Helpline"),
            uiOutput("rights")
            )
  )
)

# Define UI for application that draws a histogram
shinyUI(
  dashboardPage(
    skin = "red",
    dash_header,
    dash_sidebar,
    dash_body
  )
)

