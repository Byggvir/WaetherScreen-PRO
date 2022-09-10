#!/usr/bin/env Rscript
#
#
# Script: boxplots.r
#
# Stand: 2022-09-07
# (c) 2022 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "datalogger"

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

# Set output directory for diagrams

outdir <- '../png/boxplots/Jahre/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

SQL <- paste( 'select * from devices;')
Devices <- RunSQL(SQL)

SQL <- paste( 
  'select * from sensorreports;'
)

SensorReports <- RunSQL(SQL)

# Jahr

J <- year(SensorReports$dateutc)
JJ <- unique(J)

# Year of calendarweek

isoJ <- isoyear(SensorReports$dateutc)
isoJJ <- unique(isoJ)

# Factor dateutc

SensorReports$Jahre <- factor( J, levels = JJ, labels = JJ)
SensorReports$Monate <- factor( month(SensorReports$dateutc), levels = 1:12, labels = Monatsnamen)

SensorReports$KwJahre <- factor( isoJ, levels = isoJJ, labels = isoJJ)
SensorReports$Kw <- factor( isoweek(SensorReports$dateutc), levels = 1:53, labels = paste('Kw', 1:53))

SensorReports$Tag <- factor( yday(SensorReports$dateutc), levels = 1:366, labels = 1:366 )


for ( D in 1:nrow(Devices)) {
  
  DevName = Devices$name[D] 
  DevId = Devices$id[D]

  SQLsensor <- paste('select * from sensors as S join devices as D on S.device_id = D.id where D.id = ', D, ';')
  Sensors <- RunSQL(SQLsensor)
  
  for ( C in 1:nrow(Sensors) ) {
    
    Chan <- Sensors$channel[C]
    SenLocation <- Sensors$sensorlocation[C]
    
    L <- SensorReports %>% filter ( channel == Chan & device_id == DevId )
    scl <- max(L$Temperature) / max(L$Humidity)
  
    L %>% ggplot() + 
      geom_boxplot( aes( x = Kw , y = Temperature, fill = Jahre ) , size = 0.1 ) +
      scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE )) +
      expand_limits( y = 15) +
      expand_limits( y = 30) +
      theme_ipsum() +
      theme(  legend.position="right"
              , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1) ) +
      labs( title = paste( 'Messwerte des Sensors', SenLocation ,'an Station', DevName )
            , subtitle = 'Temperatur'
            , x = "Datum/Zeit"
            , y = "Temperatur [°C]"
            , colour = 'Jahr'
            , caption = paste( "Stand:", heute )
      ) -> P
  
    ggsave(   
      file = paste( outdir, 'Temperature-',  DevName, '-', SenLocation, '.png', sep='')
      , plot = P
      , device = 'png'
      , bg = "white"
      , width = 1920
      , height = 1080
      , units = "px"
      , dpi = 144
    )

    L %>% ggplot() + 
      geom_boxplot( aes( x = Kw , y = Humidity, fill = Jahre ) , size = 0.1 ) +
      scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE )) +
      expand_limits( y = 15) +
      expand_limits( y = 30) +
      theme_ipsum() +
      theme(  legend.position="right"
              , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1) ) +
      labs( title = paste( 'Messwerte des Sensors', SenLocation ,'an Station', DevName )
            , subtitle = 'Luftfeuchtigkeit'
            , x = "Datum/Zeit"
            , y = "Luftfeuchtigkeit [%]"
            , colour = 'Jahr'
            , caption = paste( "Stand:", heute )
      ) -> P
  
    ggsave(   
      file = paste( outdir, 'Humidity-', DevName,'-', SenLocation, '.png', sep='')
      , plot = P
      , device = 'png'
      , bg = "white"
      , width = 1920
      , height = 1080
      , units = "px"
      , dpi = 144
    )
    
  } # end SensorReports
  
} # end devices