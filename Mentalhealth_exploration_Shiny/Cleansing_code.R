setwd("./Mentalhealth_exploration")
mh <- read.csv("./data/cleansed_data.csv")
raw <- read.csv("./data/raw_data_2.csv")
cb <- read.csv("./docs/Codebook.csv")
# View(mh)
View(cb)
library(tidyverse)
library(stringr)
library(FactoMineR)
library(factoextra)
library(ggplot2)
library(plotly)

##Cleansing....
rem_prev <- raw[,!grepl("previous", colnames(raw))]
write.table(data.frame(new_names = paste0("C",1:length(colnames(rem_prev))),old_names = colnames(rem_prev)),
            file = "Codebook.csv",sep = ",",col.names = NA)

colnames(rem_prev) <- paste0("C",1:length(colnames(rem_prev)))

############################################################################
##Prep data

#Does.your.employer.provide.mental.health.benefits.as.part.of.healthcare.coverage. C5
cov <- rem_prev %>% filter(C5 != '',C48 == 'United States of America') %>% select(C49,C5,C44) %>% 
  group_by(C49,C5) %>% summarise(n = n(),age = sum(C44)) %>% mutate(coverage_ratio = n/sum(n) * 100,responses = sum(n),avg_age = sum(age)/sum(n)) %>% arrange(C49) #%>% View()

#Have.you.been.diagnosed.with.a.mental.health.condition.by.a.medical.professional. C39
m_ill <- rem_prev %>% filter(C48 == 'United States of America') %>%  
  group_by(C49,C39) %>% 
  summarise(n = n()) %>% 
  mutate(ill_ratio = n/sum(n) * 100) %>% filter(C39 == "Yes")

map_tracks <- data.frame(left_join(cov,m_ill,by = "C49") %>% select(-c(n.x,n.y,age,C39)) %>% 
  spread(C5,coverage_ratio),stringsAsFactors = FALSE) 

map_tracks$hover <- with(map_tracks,paste(C49,
                                          "Average age",avg_age,"<br>",
                                          "% of people mentally ill",ill_ratio,"<br>",
                                          "% of respondents who get mental-care benefits",Yes,"<br>",
                                          "% of respondents who aren't aware of the benefits",`I.don.t.know`,"<br>",
                                          "% of respondents who do not get benefits",No
                                          ))

df <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv",stringsAsFactors=FALSE)
df <- rbind(df,c("DC","District of Columbia"))

map_codes <- left_join(map_tracks,df %>% select(state,code),by = c("C49" = "state"))

map_codes$code[map_codes$C49 == "California"] <- "CA"

View(map_codes)

l <- list(color = toRGB("white"), width = 2)
# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)
#Alabama <br> Responses 4 <br> Average age 38.25 <br> % of people mentally ill 75 <br> % of respondents who get mental-care benefits 75 <br> % of respondents who aren't aware of the benefits 25 <br> % of respondents who do not get benefits NA


############################################################################
##Maps

View(map_codes)
l <- list(color = toRGB("white"), width = 2)
# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

p <- plot_geo(map_codes, locationmode = 'USA-states') %>%
  add_trace(
    z = ~responses, text = ~hover, locations = ~code,
    color = ~responses, colors = 'Reds'
  ) %>%
  colorbar(title = "Responses") %>%
  layout(
    title = 'OSMI mental health survey',
    geo = g
  )


