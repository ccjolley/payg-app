###############################################################################
# Plots I could include:
###############################################################################

# Mobile money gap bar plots -- can easily do this for other countries
# Mobile account histogram -- could do this with other Findex variables

# Electrification & mobile -- would need DHS data for more countries
# DHS geographic mobile coverage -- would require getting geotagged DHS data for 
#   more countries and pre-computing

###############################################################################
# General quirks
###############################################################################

# Add more Findex indicators
# Clean up weird annotation in Findex indicator names
# More compact checkbox layout?
# 'Cannot open the connection' error on read.csv in gsma_plot
# why does text wrap on Findex indicators?

###############################################################################
# Header
###############################################################################

header <- dashboardHeader(
  title = "PAYG data app (dev version)",
  titleWidth=400
)

###############################################################################
# Sidebar
###############################################################################

sidebar <- dashboardSidebar(
  width=400,
  htmlOutput('varUI'),
  htmlOutput('countryUI'),
  htmlOutput('regionUI')
)

###############################################################################
# Body
###############################################################################

body <- dashboardBody(
  tabsetPanel(id='panelID',
    tabPanel('Findex indicators',
             plotOutput("findexPlot")),
    tabPanel('Household electrification',
             plotOutput("elecPlot")),
    tabPanel('Mobile adoption',
             plotOutput('gsmaPlot'))
  )
)

###############################################################################
# Dashboard definition (main call)
###############################################################################

dashboardPage(
  title = "PAYG data app (dev version)",  
  header,
  sidebar,
  body
)
