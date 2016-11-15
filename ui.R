# Plots I could include:

# Mobile money gap bar plots -- can easily do this for other countries
# Mobile account histogram -- could do this with other Findex variables
# Borrowed from financial inst -- could do other countries/Findex variables

# Electrification & mobile -- would need DHS data for more countries
# DHS geographic mobile coverage -- would require getting geotagged DHS data for 
#   more countries and pre-computing



# TODO: Find out -- is utils.R getting run twice?
# TODO: Enable linear forecasts
# TODO: Add a 'clear all' button


library(shiny)
library(llamar)
source('utils.R')

# We only need countries with at least one DHS timepoint
dhs_names <- dhs_all$CountryName %>% unique

shinyUI(fluidPage(
  #### DHS household electrification
  # titlePanel("Household electrification (from DHS)"),
  # sidebarLayout(
  #   sidebarPanel(
  #     checkboxGroupInput('clist','Country:',dhs_names,inline=TRUE,
  #                       selected=c('Nigeria','Uganda','Tanzania','Zambia',
  #                                  'Rwanda'))
  #   ),
  #   mainPanel(
  #     plotOutput("elecPlot")
  #   )
  # )
  
  #### GSMA mobile adoption
  titlePanel("Mobile adoption (from GSMA)"),
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput('clist','Country:',gsma_names,inline=TRUE,
                         selected=c('Nigeria','Uganda','Tanzania','Zambia',
                                    'Rwanda')),
      radioButtons('gsma_var','Indicator:',
                   c('Penetration' = 0,
                     'Penetration, unique subscribers' = 1,
                     'Annual growth rate' = 2,
                     'Annual growth rate, unique subscribers' = 3))
    ),
    mainPanel(
      plotOutput("gsmaPlot")
      
    )
  )
  
  ### TODO: add UI for findex plot
  
))
