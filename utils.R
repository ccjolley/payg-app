cnames <- c('Afghanistan','Albania','Angola','Armenia','Azerbaijan',
            'Bangladesh','Benin','Bolivia','Botswana','Brazil','Burkina Faso',
            'Burundi','Cambodia','Cameroon','Cape Verde',
            'Central African Republic','Chad','Colombia',
            'Comoros','Congo','Congo Democratic Republic','Cote d\'Ivoire',
            'Dominican Republic','Ecuador','Egypt','El Salvador',
            'Equatorial Guinea','Eritrea','Ethiopia','Gabon','Gambia',
            'Ghana','Guatemala','Guinea','Guyana','Haiti','Honduras','India',
            'Indonesia','Jordan','Kazakhstan','Kenya','Kyrgyz Republic',
            'Laos','Lesotho','Liberia','Madagascar','Malawi','Maldives',
            'Mali','Mauritania','Mexico','Moldova',
            'Morocco','Mozambique','Namibia','Nepal','Nicaragua','Niger',
            'Nigeria','Nigeria (Ondo State)','Pakistan','Paraguay','Peru',
            'Philippines','Rwanda','Samoa','Sao Tome and Principe','Senegal',
            'Sierra Leone','South Africa','Sri Lanka','Sudan','Swaziland',
            'Tajikistan','Tanzania','Thailand','Timor-Leste','Togo',
            'Trinidad and Tobago','Tunisia','Turkey','Turkmenistan','Uganda',
            'Ukraine','Uzbekistan','Vietnam','Yemen','Zambia','Zimbabwe')

gsma_names <- c('Burkina Faso','Benin','Burundi','Congo Democratic Republic',
                'Congo','Cote d\'Ivoire','Cameroon','Ethiopia','Gabon','Ghana',
                'Gambia','Guinea','Kenya','Liberia','Lesotho','Madagascar','Mali',
                'Malawi','Mozambique','Nigeria','Niger','Namibia','Rwanda',
                'Sierra Leone','Senegal','Swaziland','Chad','Togo','Tanzania',
                'Uganda','Zambia','Zimbabwe')

###############################################################################
# Translate list of standard country names to string of 2-letter DHS codes
# see  http://dhsprogram.com/data/File-Types-and-Names.cfm#CP_JUMP_10136
# TODO: move cnames to a utility script called by both ui.R and server.R
###############################################################################
list2dhs <- function(a) {
  short <- c('AF','AL','AO','AM','AZ','BD','BJ','BO','BT','BR','BF','BU','KH',
             'CM','CV','CF','TD','CO','KM','CG','CD','CI','DR','EC','EG','ES',
             'EK','ER','ET','GA','GM','GH','GU','GN','GY','HT','HN','IA','ID',
             'JO','KK','KE','KY','LA','LS','LB','MD','MW','MV','ML','MR','MX',
             'MB','MA','MZ','NM','NP','NC','NI','NG','OS','PK','PY','PE','PH',
             'RW','WS','ST','SN','SL','ZA','LK','SD','SZ','TJ','TZ','TH','TL',
             'TG','TT','TN','TR','TM','UG','UA','UZ','VN','YE','ZM','ZW')
  res <- paste(a,collapse=',')
  for (i in 1:length(short)) {
    res <- sub(cnames[i],short[i],res)
  }
  res
}

###############################################################################
# Populate dataframe with DHS electrification values
###############################################################################
dhs_all <- loadDHS(indicators='HC_ELEC_H_ELC',countries=list2dhs(cnames))