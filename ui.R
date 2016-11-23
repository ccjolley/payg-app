###############################################################################
# Plots I could include:
###############################################################################

# Mobile account histogram -- could do this with other Findex variables

# Electrification & mobile -- would need DHS data for more countries
# DHS geographic mobile coverage -- would require getting geotagged DHS data for 
#   more countries and pre-computing

###############################################################################
# General quirks
###############################################################################

# Add more Findex indicators

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
             plotOutput('gsmaPlot')),
    tabPanel('Urban-rural gap',
             plotOutput('gapPlot'))
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
