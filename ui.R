###############################################################################
# Plots I could include:
###############################################################################

# Electrification & mobile -- would need DHS data for more countries
# DHS geographic mobile coverage -- would require getting geotagged DHS data for 
#   more countries and pre-computing

###############################################################################
# General quirks
###############################################################################


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
    tabPanel('Findex histogram',
             plotOutput("findexHist")),
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
