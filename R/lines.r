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

outdir <- '../png/lines/'

dir.create( outdir , showWarnings = FALSE, recursive = FALSE, mode = "0777")

today <- Sys.Date()
heute <- format(today, "%Y%m%d")

SQL <- paste( 
    'select * from reports;'
)

RoomLogg <- RunSQL(SQL)

for ( id in unique(RoomLogg$sensor_id) ) {
  
  SQLsensor <- paste('select * from sensor as S join logger as L on S.logger_id = L.id where S.id = ', id, ';')
  SensorInfo <- RunSQL(SQLsensor)

  L <- RoomLogg %>% filter ( sensor_id == id )
  scl <- max(L$Temperature) / max(L$Humidity)
  
  L %>% ggplot() + 
    geom_line( aes( x = dateutc, y = Temperature, colour = 'Temperatur' ) , size = 1 ) +
    geom_line( aes( x = dateutc, y = Humidity * scl, colour = 'Luftfeuchte' ) , size = 1 ) +
    scale_x_datetime() + # ( breaks = '1 hour' ) + 
    scale_y_continuous( labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ),
                        sec.axis = sec_axis( ~. / scl, name = "Luftfeuchte"
                                             , labels = function (x) format(x, big.mark = ".", decimal.mark= ',', scientific = FALSE ))) +
    # expand_limits( y = 0) +
    theme_ipsum() +
    theme(  legend.position="right"
            , axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1) ) +
    labs( title = paste( 'RoomLogg Sensor:', SensorInfo$name[1],'-', SensorInfo$sensorlocation )
          , subtitle = 'Temperatur und Luftfeuchte'
          , x = "Datum/Zeit"
          , y = "Temperatur [°C]"
          , colour = 'Parameter'
          , caption = paste( "Stand:", heute )
    ) -> P

  ggsave(   
    file = paste( outdir, id, '.png', sep='')
    , plot = P
    , device = 'png'
    , bg = "white"
    , width = 1920
    , height = 1080
    , units = "px"
    , dpi = 144
  )

}