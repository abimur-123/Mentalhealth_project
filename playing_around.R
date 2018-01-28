setwd("./Github_personal/Mentalhealth_exploration")
mh <- read.csv("./data/cleansed_data.csv")
raw <- read.csv("./data/raw_data_2.csv")
cb <- read.csv("./docs/Codebook.csv")
View(mh)
View(cb)
library(tidyverse)
library(stringr)
library(FactoMineR)
library(factoextra)
library(ggplot2)

rem_prev <- raw[,!grepl("previous", colnames(raw))]
length(colnames(rem_prev))

paste0("C",1:51)

write.table(data.frame(new_names = paste0("C",1:length(colnames(rem_prev))),old_names = colnames(rem_prev)),
            file = "Codebook.csv",sep = ",",col.names = NA)

colnames(rem_prev) <- paste0("C",1:length(colnames(rem_prev)))
rem_prev %>% View()

factors_cols <- apply(mh, 2, function(x) nlevels(as.factor(x)))

#rename
paste0("C",1:63)

mh_fact <- mh[,sapply(mh, is.factor)]

mh_MCA <- MCA(mh_fact)

cats <- apply(mh_fact, 2, function(x) nlevels(as.factor(x)))
mca1_vars_df <-  data.frame(mh_MCA$var$coord, Variable = rep(names(cats), cats))
mca1_obs_df = data.frame(mh_MCA$ind$coord)

ggplot(mh, aes(x = C57, y = C3)) + 
  geom_point() + 
  geom_smooth() +
  facet_grid(~C49) + 
  labs(x = "Age", y = "Size of company", color = "Do you have a mental disorder?") 


fviz_screeplot(mh_MCA, addlabels = TRUE)


fviz_mca_var(mh_MCA, choice = "mca.cor", 
             repel = TRUE, # Avoid text overlapping (slow)
             ggtheme = theme_minimal())


df <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2014_world_gdp_with_codes.csv')

View(df)
# light grey boundaries
l <- list(color = toRGB("grey"), width = 0.5)

# specify map projection/options
g <- list(
  showframe = FALSE,
  showcoastlines = FALSE,
  projection = list(type = 'Mercator')
)

plot_geo(df) %>%
  add_trace(
    z = ~GDP..BILLIONS., color = ~GDP..BILLIONS., colors = 'Blues',
    text = ~COUNTRY, locations = ~CODE, marker = list(line = l)
  ) %>%
  colorbar(title = 'GDP Billions US$', tickprefix = '$') %>%
  layout(
    title = '2014 Global GDP<br>Source:<a href="https://www.cia.gov/library/publications/the-world-factbook/fields/2195.html">CIA World Factbook</a>',
    geo = g
  )
p
View(rem_prev)

#Does.your.employer.provide.mental.health.benefits.as.part.of.healthcare.coverage. C5
cov <- rem_prev %>% filter(C5 != '',C48 == 'United States of America') %>% select(C49,C5,C44) %>% 
  group_by(C49,C5) %>% summarise(n = n(),age = sum(C44)) %>% mutate(coverage_ratio = n/sum(n) * 100,responses = sum(n),avg_age = sum(age)/sum(n)) %>% arrange(C49) #%>% View()

#Have.you.been.diagnosed.with.a.mental.health.condition.by.a.medical.professional. C39
m_ill <- rem_prev %>% filter(C48 == 'United States of America') %>%  
  group_by(C49,C39) %>% 
  summarise(n = n()) %>% 
  mutate(ill_ratio = n/sum(n) * 100) %>% filter(C39 == "Yes")

map_tracks <- left_join(cov,m_ill,by = "C49") %>% select(-c(n.x,n.y,age,C39)) %>% 
  spread(C5,coverage_ratio)

View(map_tracks)
#employees
responses <- as.data.frame(rem_prev %>% filter(C5 != '',C48 == 'United States of America') %>% group_by(C49) %>% summarise(employee_count = n()) %>% arrange(C49))
as.data.frame(cbind(cov %>% filter(),responses)) %>% View()


df <- read.csv("https://raw.githubusercontent.com/plotly/datasets/master/2011_us_ag_exports.csv")
View(df)

#C62

mh %>% filter(C61 == "United States of America") %>% 
  group_by(C62,C18) %>% summarise(n()) %>% View()
  
