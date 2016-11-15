library(shiny)
library(dplyr)
library(ggplot2)
library(llamar)
library(scales)
library(forcats)
source('utils.R')
source('read-GSMA.R')
source('read-findex.R')
# TODO: Eventually, it will make more sense to pre-process the GSMA indicators
# I care about into a single CSV rather than working with the original GSMA
# files every time. 

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
  gsma_data <- plyr::ldply(clist, function(x) 
    get_gsma(paste0(dirroot,x,'.csv'),2000:2020)) %>% na.omit
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
# TODO: make $barcolor depend on whether it's a country or a grouping
###############################################################################
findex_plot <- function(clist,code='WP14887_7.1') {
  gf_focus <- gf_wide[gf_wide$country_name %in% clist,] 
  tmp <- data.frame()
  for (c in clist) {
    tmp <- rbind(tmp,data.frame(country=c,value=gf_focus[gf_focus$country_name==c,code]))
  }
  tmp <- tmp %>% 
    mutate(country = as.character(country),
           country = ifelse(country=='High income: OECD','OECD high income',country),
           country = ifelse(country=='Sub-Saharan Africa (developing only)','SS Africa',country))
  title <- key[key$series_code==code,'series_name'] %>% 
    gsub(' \\[w2\\]','',.)
  tmp$text <- round(tmp$value) %>% paste0('%')
  tmp$barcolor <- as.factor(1)
  thresh <- max(tmp$value,na.rm=TRUE)/5
  ggplot(tmp,aes(x=fct_rev(fct_inorder(country)),y=value)) +
    geom_bar(stat='identity',aes(fill=barcolor)) +
    geom_text(aes(label=text,y=ifelse(value>thresh,value,thresh)),hjust=-0.1) +
    geom_text(aes(label=country,y=0.5),hjust=0) +
    coord_flip() +
    ggtitle(title) +
    theme_classic() +
    theme(axis.title = element_blank(),
          axis.text = element_blank(), 
          axis.ticks = element_blank(),
          legend.position = "none")
}

findex_plot(c('Kenya','Mali','Niger'))

###############################################################################
# Here's where all the real action is
###############################################################################

shinyServer(function(input, output) {
  output$gsmaPlot <- renderPlot({
    gsma_plot(input$clist,input$gsma_var)
  })
  output$elecPlot <- renderPlot({
    elec_plot(input$clist)
  })

})
