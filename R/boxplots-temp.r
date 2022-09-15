#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "boxplots-temp"

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

outdir <- '../png/Temperatur/'
dir.create( outdir , showWarnings = FALSE, recursive = TRUE, mode = "0777" )

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

Devices <- GetDevices()

for ( D in 1:nrow(Devices)) {
  
  DevName = Devices$name[D] 
  DevId = Devices$id[D]
  
  SQL <- paste( 'select'
                , 'dateutc as dateutc '
                , ', "Außen" as Ort'
                , ', TemperaturAussen as Temperatur'
                , 'from devicereports'
                , 'where device_id =', DevId 
                , 'union'
                , 'select'
                , 'dateutc as dateutc '
                , ', "Innen" as Ort'
                , ', TemperaturInnen as Temperatur'
                , 'from devicereports'
                , 'where device_id =', DevId 
                , ';'
  )
  
  TT <- RunSQL(SQL)
  
  Y <- year(TT$dateutc)
  YY <- unique(Y)
  
  isoY<- isoyear(TT$dateutc)
  isoYY <- unique(isoY)
  
  TT$Year <- factor( Y, levels = YY, labels = YY)
  TT$Month <- factor( month(TT$dateutc), levels = 1:12, labels = Monatsnamen)
  
  TT$ISOYear <- factor( isoY, levels = isoYY, labels = isoYY)
  TT$ISOWeek <- factor( isoweek(TT$dateutc), levels = 1:53, labels = paste('Week', 1:53))
  
  TT$Day <- factor( yday(TT$dateutc), levels = 1:366, labels = 1:366 )
  
  
  TT %>% ggplot(aes( x = Month, y = Temperatur )) + 
    geom_boxplot( aes( fill = Ort ) ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    theme_ipsum() +
    theme(  legend.position="right"
            , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=0.5)
    ) +
    labs(  title = paste( 'Innen- und Außentemperaturen Rheinbach - Mittelerde' )
           , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
           , x = 'Monat'
           , y = 'Temperatur [°C]'
           , colour = 'Jahre'
           , caption = paste( "Stand:", heute )
    ) -> P3
  
  ggsave(  paste( 
    file = outdir, MyScriptName, '_Monate.png', sep='')
    , plot = P3
    , device = 'png'
    , bg = "white"
    , width = 1920
    , height = 1080
    , units = "px"
    , dpi = 144
  )
  

  TT %>% ggplot(aes( x = ISOWeek, y = Temperatur )) + 
    geom_boxplot( aes( fill = Ort ) ) +
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
    theme_ipsum() +
    theme(  legend.position="right"
            , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5)
    ) +
    labs(  title = paste( 'Innen- und Außentemperaturen  Rheinbach - Mittelerde' )
           , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
           , x = 'Kalenderwoche'
           , y = 'Temperatur [°C]'
           , colour = 'Jahre'
           , caption = paste( "Stand:", heute )
    ) -> P3
  
  ggsave(  paste( 
    file = outdir, MyScriptName, '_Wochen.png', sep='')
    , plot = P3
    , device = 'png'
    , bg = "white"
    , width = 1920
    , height = 1080
    , units = "px"
    , dpi = 144
  )

}