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
             plotOutput("findexPlot"),
             htmlOutput('findex_footer1')),
    tabPanel('Findex histogram',
             plotOutput("findexHist"),
             htmlOutput('findex_footer2')),
    tabPanel('Household electrification',
             plotOutput("elecPlot"),
             htmlOutput('dhs_footer')),
    tabPanel('Mobile adoption',
             plotOutput('gsmaPlot'),
             htmlOutput('gsma_footer')),
    tabPanel('Urban-rural gap',
             plotOutput('gapPlot'),
             htmlOutput('findex_footer3'))
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
