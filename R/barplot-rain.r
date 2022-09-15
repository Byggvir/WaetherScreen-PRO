#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "barplot-rain"

options(OutDec=',')

require(data.table)
library(tidyverse)
library(grid)
library(gridExtra)
library(gtable)
library(lubridate)
library(ggplot2)
library(viridis)
library(hrbrthemes)
library(scales)
library(ragg)

# Set Working directory to git root

if (rstudioapi::isAvailable()){
  
  # When called in RStudio
  SD <- unlist(str_split(dirname(rstudioapi::getSourceEditorContext()$path),'/'))
  
} else {
  
  #  When called from command line 
  SD = ( function() return( if(length(sys.parents())==1) getwd() else dirname(sys.frame(1)$ofile) ) )()
  SD <- unlist(str_split(SD,'/'))
  
}

WD <- paste(SD[1:(length(SD))],collapse='/')
if ( SD[length(SD)] != "R" ) {
  
  WD <- paste( WD,"/R", sep = '')

}

setwd(WD)

source("lib/myfunctions.r")
source("lib/sql.r")

outdir <- '../png/Rain/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

Devices <- GetDevices()

for ( D in 1:nrow(Devices)) {
  
  DevName = Devices$name[D] 
  DevId = Devices$id[D]
  
  
  SQL <- paste( 'select'
              , '  year(dateutc) as Jahr'
              , ', month(dateutc) as Monat '
              , ', max(RegenMonat) as Regen'
              , 'from devicereports'
              , 'where device_id =',  DevId
              , 'group by Jahr, Monat'
              , ';'
  )

  rain <- RunSQL(SQL)
  
  rain$Monate <- factor(rain$Monat, levels = 1:12, labels = Monatsnamen)
  rain$Jahre <- factor(rain$Jahr, levels = unique(rain$Jahr), labels = paste('Jahr',unique(rain$Jahr)))
  
  today <- Sys.Date()
  heute <- format(today, "%Y%m%d")

  rain %>% ggplot() + 
    geom_bar( aes( x = Monate, y = Regen, fill = Jahre ), position = "dodge", stat = 'identity' ) +
    # scale_x_date() +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    theme_ipsum() +
    theme(  legend.position="right"
            , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
    ) +
    labs(  title = paste( 'Niederschlag' )
           , subtitle = 'Wetterstation Mittelerde, Rheinbach'
           , x = "Datum"
           , y = "Niederschlag [mm]"
           , caption = paste( "Stand:", heute )
    ) -> P

  ggsave(  
    file = paste( outdir, MyScriptName, '_' , DevId, '.png', sep='')
    , plot = P
    , device = 'png'
    , bg = "white"
    , width = 1920
    , height = 1080
    , units = "px"
    , dpi = 144
  )

} # end devices
