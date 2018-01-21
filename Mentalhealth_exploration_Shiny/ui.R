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

mh <- read.csv("Cleansed.csv",stringsAsFactors = FALSE)

mh$Org_size[mh$Org_size == ""] <-  "Missing"

mh[,"Org_size"] <- as.factor(mh[,"Org_size"]) %>% 
  forcats::fct_relevel("1-5","6-25","26-100","100-500","500-1000","More than 1000","Missing")

#Dashboard Header
dash_header <- dashboardHeader(
  title = "OSMI mental health survey in Tech Exploration - 2016"
)

#Dashbord sidebar
dash_sidebar <- dashboardSidebar(
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
              label = "Self-employed?",
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
                     choices = c("Select all",levels(mh[,"Org_size"])),
                     selected = "Select all"),
  width = 3
)


#Exploration page layout
expl_tab <- fluidPage(
  titlePanel("Survey response in the US"),
  sidebarLayout(
    sidebar_expl,
    mainPanel(
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

