library(ggplot2)
library(dplyr)
# source('read-findex.R') # Assumes this has already been called

###############################################################################
# Histogram of country values for a Findex indicator
###############################################################################
code <- 'WP15163_4.1'

findex_hist <- function(code,nbins=30) {
  tmp <- gf_wide %>% dplyr::select(country_name,val=which(names(gf_wide)==code)) %>%
    na.omit %>%
    filter(!grepl(')',country_name)) %>%
    filter(!grepl('income',country_name)) %>%
    filter(!country_name %in% c('World','South Asia')) %>%
    mutate(val = val/100)
  top <- tmp %>% 
    mutate(bin = cut(val,nbins/4) %>% as.numeric) %>%
    filter(val > median(val)) %>%
    arrange(desc(val)) %>%
    group_by(bin) %>%
    mutate(y=row_number()+1) %>%
    ungroup()
  title <- key[key$series_code==code,'series_name'] %>%
    gsub(' \\(.*\\)','',.) %>%
    gsub(' \\[.*\\]','',.)    
  ggplot(tmp,aes(x=val)) +
    geom_histogram(fill='lightskyblue1',color='gray80',bins=nbins) +
    theme_classic() +
    geom_text(data=top,aes(x=val,y=y,label=country_name),hjust=0,check_overlap=TRUE) +
    xlab(title) +
    scale_x_continuous(labels = scales::percent) +
    theme(axis.ticks = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank())
}