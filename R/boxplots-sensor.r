#!/usr/bin/env Rscript
#
#
# Script: boxplots.r
#
# Stand: 2022-09-07
# (c) 2022 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "boxplots-sensor"

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

outdir <- '../png/boxplots/location/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

Devices <- GetDevices()

for ( D in 1:nrow(Devices)) {
 
  
  DevName = Devices$name[D] 
  DevId = Devices$id[D]
  
  SensorReports <- GetReports(DevId = DevId)
  if (nrow(SensorReports) > 0 ) {
    scl <- max(SensorReports$Temperature) / max(SensorReports$Humidity)
    
    SensorReports %>% ggplot() + 
        geom_boxplot( aes( x = Month , y = Temperature, fill = Sensor ) , size = 0.1 ) +
        scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE )) +
        expand_limits( y = 15) +
        expand_limits( y = 30) +
        theme_ipsum() +
        theme(  legend.position="right"
                , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1) ) +
        labs( title = paste( 'Messwerte der Sensoren an Station', DevName )
              , subtitle = 'Temperatur'
              , x = "Datum/Zeit"
              , y = "Temperatur [°C]"
              , colour = 'Sensor'
              , caption = paste( "Stand:", heute )
        ) -> P
    
      ggsave(   
        file = paste( outdir, 'Temperature-',  DevName, '.png', sep='')
        , plot = P
        , device = 'png'
        , bg = "white"
        , width = 1920
        , height = 1080
        , units = "px"
        , dpi = 144
      )
  
      SensorReports %>% ggplot() + 
        geom_boxplot( aes( x = Month , y = Humidity, fill = Sensor ) , size = 0.1 ) +
        scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE )) +
        expand_limits( y = 15) +
        expand_limits( y = 30) +
        theme_ipsum() +
        theme(  legend.position="right"
                , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1) ) +
        labs( title = paste( 'Messwerte der Sensoren an Station', DevName )
              , subtitle = 'Luftfeuchtigkeit'
              , x = "Datum/Zeit"
              , y = "Luftfeuchtigkeit [%]"
              , colour = 'Sensor'
              , caption = paste( "Stand:", heute )
        ) -> P
    
      ggsave(   
        file = paste( outdir, 'Humidity-', DevName, '.png', sep='')
        , plot = P
        , device = 'png'
        , bg = "white"
        , width = 1920
        , height = 1080
        , units = "px"
        , dpi = 144
      )
  }
  else {
    print(paste('Fehler:', DevId))
  }
  
} # end devices