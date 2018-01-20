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

# setwd("./Github_personal/Mentalhealth_project")
mh <- read.csv("Cleansed.csv")

mh$Org_size[mh$Org_size == ""] <-  ""

mh[,"Org_size"] <- mh[,"Org_size"] %>% 
  forcats::fct_relevel("1-5","6-25","26-100","100-500","500-1000","More than 1000")

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
    menuItem("Data", tabName = "data", icon = icon("table")),
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
  width = 2
)


#Exploration page layout
expl_tab <- fluidPage(
  titlePanel("Exploration"),
  sidebarLayout(
    sidebar_expl,
    mainPanel(
      plotlyOutput("plotmap")
    )
  )
)

model_tab <- fluidPage(
  titlePanel("Models"),
  sidebarLayout(
    sidebar_expl,
    mainPanel(
      plotOutput("Model_map")
    )
  )
)

# tab1_inputs <- fluidPage(
#   # tags$head(tags$style(HTML('
#   #     .form-group, .selectize-control {
#   #          margin-bottom: 0px;
#   #     }
#   #     .col-sm-3 {
#   #         padding-right: 2px;
#   #         padding-left: 2px;
#   #     }
#   # 
#   #                           '))),
#     box(
#       title = h2("Input parameters"),
#       status = "primary", solidHeader = TRUE,
#       collapsible = TRUE,
#       width = 2,
#       br(),
#       sliderInput(inputId = "age",
#                   label = "Age:",
#                   min = 15,
#                   max = 75,
#                   value = c(20, 40)),
#       selectInput(inputId = "gender", 
#                   label = "Gender",
#                   choices =  c("Select all",levels(mh[,"Gender"])),
#                   selected = "Select all"),
#       # Input: dropdown for self-employed----
#       selectInput(inputId = "Self_employed", 
#                   label = "Self-employed?",
#                   choices = c("Select all", 
#                               "Yes",
#                               "No"),
#                   selected = "Select all"),
#       radioButtons(inputId = "tech", 
#                    label = "Tech company?", 
#                    c("Select all",
#                      "Yes",
#                      "No"), 
#                    selected = c("Select all")),
#       checkboxGroupInput("compsize", 
#                          label = "Size of company", 
#                          choices = c("Select all",levels(mh[,"Org_size"])),
#                          selected = "More than 1000")
#     ),
#     box(
#       title = h2("Map"),
#       status = "primary", solidHeader = TRUE,
#       width = 10,
#       collapsible = TRUE,
#       br(),
#       plotlyOutput("plotmap") #C14
#     )
# )


# Dashboard body
dash_body <- dashboardBody(
  tabItems(
    tabItem(tabName = "exploration",
            expl_tab
    ),
    tabItem(tabName = "models",
            h2("Models"),
            model_tab
    ),
    tabItem(tabName = "data",
            h2("Data")),
    tabItem(tabName = "resources",
            h2("Links"))
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

