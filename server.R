library(shiny)
library(dplyr)
library(ggplot2)
library(scales)
library(forcats)

###############################################################################
# Plot of electricification rates for selected countries based on DHS API.
# TODO: Add forecasting
###############################################################################
elec_plot <- function(clist) {
  # dhs_elect <- loadDHS(indicators='HC_ELEC_H_ELC',
  #                      countries=list2dhs(clist)) %>%
    dhs_elect <- dhs_all %>% filter(CountryName %in% clist) %>%
    mutate(elect=Value/100) %>%
    dplyr::select(Country=CountryName,Year=SurveyYear,elect) 
  ggplot(dhs_elect,aes(x=Year,y=elect,group=Country,color=Country)) +
    geom_point(size=4) +
    geom_line(size=2) +
    ylab('Electrification rate') +
    theme_classic() +
    scale_y_continuous(labels = scales::percent) +
    scale_x_continuous(breaks= pretty_breaks()) +
    theme(axis.ticks = element_blank(),
          legend.title=element_blank())
}

###############################################################################
# Plot of GSMA variables
# TODO: add dashed line for forecast to legend
###############################################################################
gsma_plot <- function(clist,var=0) {
  if (length(clist)==0 | is.null(var)) { return(NULL) }
  gsma_data <- plyr::ldply(clist, function(x) 
    get_gsma(paste0(dirroot,x,'.csv'),2000:2020)) %>% 
    na.omit %>% 
    mutate(CountryName=gsub('C\\?te','Cote',CountryName))
  if (var==1) {
    gsma_data$plotme <- gsma_data[,'penetration_uniq']
    text='Penetration, unique subscribers'
  } else if (var==2) {
    gsma_data$plotme <- gsma_data[,'ann_growth']
    text='Annual growth rate'
  } else if (var==3) {
    gsma_data$plotme <- gsma_data[,'ann_growth_uniq']
    text='Annual growth rate, unique subscribers'
  } else {
    if (var != 0) message('Invalid `var` in gsma_plot()')
    gsma_data$plotme <- gsma_data[,'penetration']
    text='Penetration'
  }
  gsma_data %>% 
    ggplot(aes(x=SurveyYear,y=plotme,group=CountryName,
               color=CountryName)) +
    geom_line(data=gsma_data %>% filter(SurveyYear <= 2016),linetype=1,size=2) +
    geom_line(data=gsma_data %>% filter(SurveyYear >= 2016),linetype=2,size=2) +
    theme_classic() +
    xlab('Year') +
    ylab(text) +
    scale_y_continuous(labels = scales::percent) +
    theme(axis.ticks=element_blank(),
          legend.title=element_blank())
}

###############################################################################
# Plot of Global Findex variables
###############################################################################
findex_plot <- function(clist,rlist,code='WP14887_7.1') {
  if (length(c(clist,rlist))==0) { return(NULL) }
  tmp <- plyr::ldply(c(clist,rlist),function(c) {
    v <- gf_wide[gf_wide$country_name==c,code]
    r <- ifelse(c %in% rlist,1,0)
    data.frame(country=c,value=v,region=r)
  }) %>% 
    mutate(plotorder = rank(value) + (1-region)*1000,
           region = as.factor(region)) %>%
    na.omit
  title <- key[key$series_code==code,'series_name'] %>% 
    gsub(' \\[.*\\]','',.) %>%
    gsub(' \\(.*\\)','',.)
  tmp$text <- round(tmp$value) %>% paste0('%')
  text_df <- tmp %>% 
    mutate(x=fct_reorder(country,plotorder)) %>%
    select(country,text,value,x) %>% 
    mutate(text=as.character(text),country=as.character(country)) %>%
    melt(id.vars=c('value','x'),value.name='plotme') %>%
    mutate(hjust=ifelse(variable=='country',0,-0.1),
           y=ifelse(variable=='country',max(value)/40,value),
           plotme=as.character(plotme)) %>%
    select(plotme,hjust,x,y)
  ggplot(tmp,aes(x=fct_reorder(country,plotorder),y=value)) +
    geom_bar(stat='identity',aes(fill=region)) +
    geom_text(data=text_df,aes(x=x,y=y,hjust=hjust,label=plotme),check_overlap=TRUE) +
    coord_flip() +
    ggtitle(title) +
    theme_classic() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(), 
          axis.ticks = element_blank(),
          legend.position = "none")
}

#findex_plot(c('Finland','Burkina Faso'),c('Low & middle income','Sub-Saharan Africa (developing only)'))


###############################################################################
# Here's where all the real action is
###############################################################################
initial_countries <- c('Nigeria','Uganda','Tanzania','Zambia','Rwanda')

shinyServer(function(input, output) {
  country_choices <- reactive({
    if (input$panelID == 'Findex indicators') {
      all_choices <- gf_wide[!is.na(gf_wide[,input$findex_var]),'country_name']
      setdiff(all_choices,gf_regions)
    } else if (input$panelID == 'Household electrification') {
      dhs_names
    } else if (input$panelID == 'Mobile adoption') {
      gsma_names
    }
  })
  last_countries <- reactive({
    if (length(input$clist)==0) {
      initial_countries
    } else {
      input$clist
    }
  })
  region_choices <- reactive({
    if (input$panelID == 'Findex indicators') {
      all_choices <- gf_wide[!is.na(gf_wide[,input$findex_var]),'country_name']
      intersect(all_choices,gf_regions)
    } else { NULL }
  })
  output$countryUI <- renderUI({
    selectInput('clist','Countries:',country_choices(),multiple=TRUE,
                                   selected=last_countries())
  })
  output$regionUI <- renderUI({
    if (input$panelID == 'Findex indicators') {
      selectInput('rlist','Regions:',region_choices(),multiple=TRUE,
                         selected=c('Low & middle income',
                                    'Sub-Saharan Africa (developing only)'))
    } else { NULL }
  })
  output$varUI <- renderUI({
    if (input$panelID == 'Findex indicators') {
      radioButtons('findex_var','Indicator:',findex_var_list)
    } else if (input$panelID == 'Mobile adoption') {
      radioButtons('gsma_var','Indicator:',
                   c('Penetration' = 0,
                     'Penetration, unique subscribers' = 1,
                     'Annual growth rate' = 2,
                     'Annual growth rate, unique subscribers' = 3))
    } else { NULL }
  })
  
  output$gsmaPlot <- renderPlot({
    gsma_plot(input$clist,input$gsma_var)
  })
  output$elecPlot <- renderPlot({
    elec_plot(input$clist)
  })
  output$findexPlot <- renderPlot({
    findex_plot(input$clist,input$rlist,input$findex_var)
  })

})
