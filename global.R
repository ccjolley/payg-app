library(llamar)
library(shiny)
library(shinydashboard)
library(dplyr)
library(reshape2)
library(RJSONIO) # don't know why, but I needed this to deploy on shinyapps.io
source('utils.R')
source('read-GSMA.R')
source('read-findex.R')
# TODO: Eventually, it will make more sense to pre-process the GSMA indicators
# I care about into a single CSV rather than working with the original GSMA
# files every time. 

gsma_names <- afr_mobile$CountryName %>% unique
gf_regions <- c('East Asia & Pacific (developing only)','Euro area',
                'Europe & Central Asia (developing only)',
                'High income','High income: nonOECD','High income: OECD',
                'Latin America & Caribbean (developing only)',
                'Low & middle income','Low income','Lower middle income',
                'Middle East (Developing only)','Middle income',
                'Sub-Saharan Africa (developing only)','Upper middle income',
                'World')
gf_countries <- setdiff(gf_wide$country_name,gf_regions)

tmp <- c('WP11673.1',
         'WP15172_4.1','WP14940_4.1','WP15161_1.1',
         'WP15163_4.10','WP11672.10','WP11674.10','WP11673.10',
         'WP15172_4.10','WP14940_4.10','WP15161_1.10')
         
    for (t in tmp) {
         paste(t,key[key$series_code==t,'series_name']) %>% print
         }

findex_var_list <- c(
  	'Mobile money account' = 'WP15163_4.1',
    'Mobile phone used to pay bills' = 'WP11672.1',
    'Mobile phone used to receive money' = 'WP11674.1',
  	'Mobile phone used to send money' = 'WP11673.1',
  	'Used a mobile phone to pay for school fees' = 'WP15172_4.1',
  	'Used a mobile phone to pay utility bills' = 'WP14940_4.1',
  	'Used an account to make a transaction through a mobile phone' = 'WP15161_1.1',
  	'Mobile account, rural' = 'WP15163_4.10',
  	'Mobile phone used to pay bills, rural' = 'WP11672.10',
  	'Mobile phone used to receive money, rural' = 'WP11674.10',
  	'Mobile phone used to send money, rural' = 'WP11673.10',
  	'Used a mobile phone to pay for school fees, rural' = 'WP15172_4.10',
  	'Used a mobile phone to pay utility bills, rural' = 'WP14940_4.10',
  	'Used an account to make a transaction through a mobile phone, rural' = 'WP15161_1.10'
)

###############################################################################
# Translate list of standard country names to string of 2-letter DHS codes
# see  http://dhsprogram.com/data/File-Types-and-Names.cfm#CP_JUMP_10136
###############################################################################
list2dhs <- function(a=NULL) {
  clist <- c('Afghanistan','Albania','Angola','Armenia','Azerbaijan',
             'Bangladesh','Benin','Bolivia','Botswana','Brazil','Burkina Faso',
             'Burundi','Cambodia','Cameroon','Cape Verde',
             'Central African Republic','Chad','Colombia','Comoros','Congo',
             'Congo Democratic Republic','Cote d\'Ivoire','Dominican Republic',
             'Ecuador','Egypt','El Salvador','Equatorial Guinea','Eritrea',
             'Ethiopia','Gabon','Gambia','Ghana','Guatemala','Guinea','Guyana',
             'Haiti','Honduras','India','Indonesia','Jordan','Kazakhstan',
             'Kenya','Kyrgyz Republic','Lao People\'s Democratic Republic',
             'Lesotho','Liberia','Madagascar','Malawi','Maldives','Mali',
             'Mauritania','Mexico','Moldova','Morocco','Mozambique','Namibia',
             'Nepal','Nicaragua','Niger','Nigeria','Nigeria (Ondo State)',
             'Pakistan','Paraguay','Peru','Philippines','Rwanda','Samoa',
             'Sao Tome and Principe','Senegal','Sierra Leone','South Africa',
             'Sri Lanka','Sudan','Swaziland','Tajikistan','Tanzania','Thailand',
             'Timor-Leste','Togo','Trinidad and Tobago','Tunisia','Turkey',
             'Turkmenistan','Uganda','Ukraine','Uzbekistan','Vietnam','Yemen',
             'Zambia','Zimbabwe')
  short <- c('AF','AL','AO','AM','AZ','BD','BJ','BO','BT','BR','BF','BU','KH',
             'CM','CV','CF','TD','CO','KM','CG','CD','CI','DR','EC','EG','ES',
             'EK','ER','ET','GA','GM','GH','GU','GN','GY','HT','HN','IA','ID',
             'JO','KK','KE','KY','LA','LS','LB','MD','MW','MV','ML','MR','MX',
             'MB','MA','MZ','NM','NP','NC','NI','NG','OS','PK','PY','PE','PH',
             'RW','WS','ST','SN','SL','ZA','LK','SD','SZ','TJ','TZ','TH','TL',
             'TG','TT','TN','TR','TM','UG','UA','UZ','VN','YE','ZM','ZW')
  if (is.null(a)) { return(paste(short,collapse=',')) }
  res <- paste(a,collapse=',')
  for (i in 1:length(short)) {
    res <- sub(cnames[i],short[i],res)
  }
  res
}

###############################################################################
# Populate dataframe with DHS electrification values
###############################################################################
dhs_all <- loadDHS(indicators='HC_ELEC_H_ELC',countries=list2dhs())
dhs_names <- dhs_all$CountryName %>% unique
