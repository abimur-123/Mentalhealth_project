#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)
library(shinyjs)
library(rlang)
library(tidyverse)
library(stringr)
library(FactoMineR)
library(factoextra)
library(ggplot2)
library(plotly)
library(DT)

df <- mtcars

mh_sub <- read.csv("Cleansed.csv")

# write.csv(mh_sub,"Cleansed.csv",row.names = FALSE)

# Server logic
shinyServer(function(input, output) {
  
  filterData <- reactive({
    age_inp = input$age
    gender_inp = input$gender
    self_inp = input$Self_employed
    tech_inp = input$tech
    size_inp = input$compsize
    
    # age <- C44
    # company_size <- C2
    # self_emp <- C1
    # is_tech <- C3
    # gender <- C45
    # 
    df <- mh_sub %>% filter(Age >= min(age_inp) & Age <= max(age_inp))
    
    if(gender_inp != "Select all") df <- df %>% filter(Gender %in% gender_inp)
    
    if(self_inp != "Select all") df <- df %>% filter(Self_employed %in% self_inp)
    
    if(tech_inp != "Select all") df <- df %>% filter(Is_tech %in% tech_inp)
    
    if(size_inp != "Select all") df <- df %>% filter(Org_size %in% size_inp)
    
    df
  })
  
  output$menuitem <- renderMenu({
    menuItem("Menu item", icon = icon("calendar"))
  })
  
  dataMap <- reactive({
    ##Prep data
    mh_sub <- filterData()
    #Does.your.employer.provide.mental.health.benefits.as.part.of.healthcare.coverage. C5
    cov <- mh_sub %>% filter(Benefits != '',Country == 'United States of America') %>% 
      select(US_state_work,Benefits,Age) %>% 
      group_by(US_state_work,Benefits) %>% 
      summarise(n = n(),age = sum(Age)) %>% 
      mutate(coverage_ratio = n/sum(n) * 100,responses = sum(n),avg_age = sum(age)/sum(n)) %>% 
      arrange(US_state_work) #%>% View()
    
    #Have.you.been.diagnosed.with.a.mental.health.condition.by.a.medical.professional. C39
    m_ill <- mh_sub %>% filter(Country == 'United States of America') %>%  
      group_by(US_state_work,Mental_ill) %>% 
      summarise(n = n()) %>% 
      mutate(ill_ratio = n/sum(n) * 100) %>% 
      filter(Mental_ill == "Yes") #%>% View()
    
    map_tracks <- data.frame(left_join(cov,m_ill,by = "US_state_work") %>%
                               select(-c(n.x,n.y,age,Mental_ill)) %>% 
                               spread(Benefits,coverage_ratio),stringsAsFactors = FALSE) #%>% View()
    
    if(length(names(map_tracks)) == 8){
      map_tracks$hover <- with(map_tracks,paste(US_state_work,
                                                "Average age of respondents:",round(avg_age,2),"<br>",
                                                "% of people diagnosed with mental illness:",round(ill_ratio,2),"<br>",
                                                "% of respondents who get mental-care benefits:",round(Yes,2),"<br>",
                                                "% of respondents who aren't aware of the benefits:",round(`I.don.t.know`,2),"<br>",
                                                "% of respondents who do not get benefits:",round(No,2))
      )
    }
    else if (!("No" %in% names(map_tracks))){
    map_tracks$hover <- with(map_tracks,paste(US_state_work,
                                              "Average age of respondents:",round(avg_age,2),"<br>",
                                              "% of people diagnosed with mental illness:",round(ill_ratio,2),"<br>",
                                              "% of respondents who get mental-care benefits:",round(Yes,2),"<br>",
                                              "% of respondents who aren't aware of the benefits:",round(`I.don.t.know`,2),"<br>",
                                              "% of respondents who do not get benefits:",NA)
    )
    }
    else if (!("Yes" %in% names(map_tracks))){
      map_tracks$hover <- with(map_tracks,paste(US_state_work,
                                                "Average age of respondents:",round(avg_age,2),"<br>",
                                                "% of people diagnosed with mental illness:",round(ill_ratio,2),"<br>",
                                                "% of respondents who get mental-care benefits:",NA,"<br>",
                                                "% of respondents who aren't aware of the benefits:",round(`I.don.t.know`,2),"<br>",
                                                "% of respondents who do not get benefits:",round(No,2))
      )
    }
    else{
      map_tracks$hover <- with(map_tracks,paste(US_state_work,
                                                "Average age of respondents:",round(avg_age,2),"<br>",
                                                "% of people diagnosed with mental illness:",round(ill_ratio,2),"<br>",
                                                "% of respondents who get mental-care benefits:",round(Yes,2),"<br>",
                                                "% of respondents who aren't aware of the benefits:",NA, "<br>",
                                                "% of respondents who do not get benefits:",round(No,2))
      )
    }
    
    df <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv",stringsAsFactors=FALSE)
    df <- rbind(df,c("DC","District of Columbia"))
    
    map_codes <- left_join(map_tracks,df %>% select(state,code),by = c("US_state_work" = "state"))
    
    map_codes$code[map_codes$US_state_work == "California"] <- "CA"
    map_codes %>% arrange(code)
  })
  
  output$plotmap <- renderPlotly({
    
    l <- list(color = toRGB("white"), width = 2)
    # specify some map projection/options
    g <- list(
      scope = 'usa',
      projection = list(type = 'albers usa'),
      showlakes = TRUE,
      lakecolor = toRGB('white')
    )
    df <- dataMap()
    p <- plot_geo(df, locationmode = 'USA-states') %>%
      add_trace(
        z = ~responses, text = ~hover, locations = ~code,
        color = ~responses, colors = 'Reds'
      ) %>%
      colorbar(title = "Responses") %>%
      layout(
        title = 'OSMI mental health survey',
        geo = g,
        dragmode = "select"
      )
    plotly_build(p)
  })
  
  
  output$selection <- renderPrint({
    d <- event_data("plotly_click")
    row_number <- d$pointNumber
    df <- dataMap()
    country_ret <- df[row_number + 1,]$US_state_work
    print(country_ret)
  })
  

  #Logistic model
  output$Model_map <- renderPlot({
    df <- mh_sub
    df$Mental_ill <- ifelse(df$Mental_ill == "Yes",1,0)
    # df$Org_size <- as.numeric(df$Org_size)
    
    df %>% filter(Country == "United States of America",Age <= 75) %>% 
      ggplot(.,aes(x = Age,y = Mental_ill)) +
      geom_jitter(alpha = 0.25) +
      geom_smooth(method = "glm",method.args = list(family = binomial(link = 'logit'))) +
      labs(title = "Impact of Age on Mental illness in tech companies")
  })
  
  url1 <- a("Open Sourcing Mental Illness Organization - Survey source", href = "https://osmihelp.org/")
  output$OSMI <- renderUI({
    tagList(url1)
  })
  
  url2 <- a("Mental health first Aid", href = "https://www.mentalhealthfirstaid.org/")
  output$Helpline <- renderUI({
    tagList(url2)
  })
  
  url3 <- a("Employee Guidelines book", href = "https://leanpub.com/osmi-guidelines-for-employees")
  output$rights <- renderUI({
    tagList(url3)
  })
  
  observe(event_data("plotly_click"))
  
  #map to table
  ret_Country <- reactive({
    d <- event_data("plotly_click")
    row_number <- d$pointNumber
    df <- dataMap()
    state_ret <- df[row_number + 1,]$US_state_work #increment by one as point starts at 0 index
    state_ret  
    })
  
  #data table
  output$mytable = DT::renderDataTable(
    mh_sub %>% filter(US_state_work %in% c(ret_Country())),
    extensions = 'Buttons', 
    options = list(
      scrollX = TRUE,
      dom = 'Bfrtip',
      buttons = c('copy', 'csv', 'excel', 'pdf')
    )
  )
})
