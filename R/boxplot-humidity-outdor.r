#!/usr/bin/env Rscript
#
#
# Script: Weather.r
#
# Stand: 2022-01-21
# (c) 2021 by Thomas Arend, Rheinbach
# E-Mail: thomas@arend-rhb.de
#

MyScriptName <- "boxplots-humidity-outdoor"

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

outdir <- '../png/Humidity/'
dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

MyPos <- list( lat = 50.620941424520026, long = 6.961696767218697)

T_Date <- function( Datum , intercept, slope) {
  
  return (intercept + slope * cospi( as.numeric(Datum - as.Date("2021-07-20"))/182.5))
  
}

TTRF <- GetDeviceReports(DevId = 1)

TTRF$AbsHumidity <- SaettigungWasser(TTRF$TemperaturAussen+273.15) * TTRF$LuftfeuchtigkeitAussen / 100

TTRF %>% ggplot(aes( x = Month, y = LuftfeuchtigkeitAussen /100 )) + 
  geom_boxplot( aes( fill = Year ) ) +
  scale_y_continuous( labels = scales::percent ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=0.5)
  ) +
  labs(  title = paste( 'Relative Luftfeuchte Rheinbach - Mittelerde' )
         , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
         , x = 'Monat'
         , y = 'Relative Luftfeuchte [%]'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P1

ggsave(  
  file = paste( outdir, MyScriptName, '_Rel.png', sep='')
  , plot = P1
  , device = 'png'
  , bg = "white"
  , width = 1920 
  , height = 1080
  , units = "px"
  , dpi = 144
)

TTRF %>% ggplot(aes( x = Month, y = AbsHumidity )) + 
  geom_boxplot( aes( fill = Year ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=0.5)
  ) +
  labs(  title = paste( 'Absolute Luftfeuchte Rheinbach - Mittelerde' )
         , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
         , x = 'Monat'
         , y = 'Absolute Luftfeuchte [kg/m³]'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P2

ggsave(  
  file = paste( outdir, MyScriptName, '_Abs.png', sep='')
  , plot = P2
  , device = 'png'
  , bg = "white"
  , width = 1920 
  , height = 1080
  , units = "px"
  , dpi = 144
)

TTRF %>% ggplot(aes( x = ISOWeek, y = LuftfeuchtigkeitAussen /100 )) + 
  geom_boxplot( aes( fill = ISOYear ) ) +
  scale_y_continuous( labels = scales::percent ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5)
  ) +
  labs(  title = paste( 'Relative Luftfeuchte Rheinbach - Mittelerde' )
         , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
         , x = 'Monat'
         , y = 'Relative Luftfeuchte [%]'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P1

ggsave(  
  file = paste( outdir, MyScriptName, '_Week_Rel.png', sep='')
  , plot = P1
  , device = 'png'
  , bg = "white"
  , width = 1920 
  , height = 1080
  , units = "px"
  , dpi = 144
)

TTRF %>% ggplot(aes( x = ISOWeek, y = AbsHumidity )) + 
  geom_boxplot( aes( fill = ISOYear ) ) +
  scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ) ) +
  theme_ipsum() +
  theme(  legend.position="right"
          , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0.5)
  ) +
  labs(  title = paste( 'Absolute Luftfeuchte Rheinbach - Mittelerde' )
         , subtitle = 'Minutenwerte der dnt WeatherScreen Pro'
         , x = 'Monat'
         , y = 'Absolute Luftfeuchte [kg/m³]'
         , colour = 'Jahre'
         , caption = paste( "Stand:", heute )
  ) -> P2

ggsave(  
  file = paste( outdir, MyScriptName, '_Week_Abs.png', sep='')
  , plot = P2
  , device = 'png'
  , bg = "white"
  , width = 1920 
  , height = 1080
  , units = "px"
  , dpi = 144
)
