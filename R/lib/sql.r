library(bit64)
library(RMariaDB)
library(data.table)

RunSQL <- function (
  SQL = 'select * from Faelle;'
  , prepare= c("set @i := 1;")) {
  
  rmariadb.settingsfile <- path.expand('~/R/sql.conf.d/WeatherScreen.conf')
  
  rmariadb.db <- "WeatherScreen"
  
  DB <- dbConnect(
    RMariaDB::MariaDB()
    , default.file=rmariadb.settingsfile
    , group=rmariadb.db
    , bigint="numeric"
  )
  for ( P in prepare ){
    dbExecute(DB, P)
  }
  rsQuery <- dbSendQuery(DB, SQL)
  dbRows<-dbFetch(rsQuery)

  # Clear the result.
  
  dbClearResult(rsQuery)
  
  dbDisconnect(DB)
  
  return(dbRows)
}

ExecSQL <- function (
  SQL 
) {
  
  rmariadb.settingsfile <- path.expand('~/R/sql.conf.d/WeatherScreen.conf')
  
  rmariadb.db <- "WeatherScreen"
  
  DB <- dbConnect(
    RMariaDB::MariaDB()
    , default.file=rmariadb.settingsfile
    , group=rmariadb.db
    , bigint="numeric"
  )
  
  count <- dbExecute(DB, SQL)

  dbDisconnect(DB)
  
  return (count)
  
}


# 
# Function to get a list of devices
#  

GetDevices  <- function () {
  
  SQL <- paste( 'select * from devices;')
  return(RunSQL(SQL))
  
}

# 
# Function to get a list of sensors of a device
#  

GetSensors  <- function ( DevId = 1) {
  
  SQL <- paste( 'select * from devices as D join sensors as S on D.id = S.device_id where D.id =', DevId, ';')
  return(RunSQL(SQL))
  
}

# 
# Function to get the measured data of all sensors at a device
#  

GetReports  <- function ( DevId = 1, Channel = 0) {
  
  if (Channel == 0) {
    SQL <- paste( 
      'select R.*,S.sensorlocation as Sensor  from sensorreports as R join sensors as S on S.device_id = R.device_id and S.channel = R.channel where R.device_id =', DevId, ';'
    )
  } else {
    SQL <- paste( 
      'select R.*,S.sensorlocation as Sensor  from sensorreports as R join sensors as S on S.device_id = R.device_id and S.channel = R.channel where R.device_id =', DevId, 'and S.channel =',Channel,';'
    )
    
  }
  
  R <- RunSQL(SQL)
  
  # Add factor for year, month, isoyear, isoweek
  
  Y <- year(R$dateutc)
  YY <- unique(Y)
  
  isoY<- isoyear(R$dateutc)
  isoYY <- unique(isoY)
  
  R$Year <- factor( Y, levels = YY, labels = YY)
  R$Month <- factor( month(R$dateutc), levels = 1:12, labels = Monatsnamen)
  
  R$ISOYear <- factor( isoY, levels = isoYY, labels = isoYY)
  R$ISOWeek <- factor( isoweek(R$dateutc), levels = 1:53, labels = paste('Week', 1:53))
  
  R$Day <- factor( yday(R$dateutc), levels = 1:366, labels = 1:366 )
  
  return(R)
  
}

GetDeviceReports  <- function ( DevId = 1) {
  
  SQL <- paste( 
    'select R.* from devicereports as R join devices as D on D.id = R.device_id where R.device_id =', DevId, ';'
  )

  R <- RunSQL(SQL)
  
  # Add factor for year, month, isoyear, isoweek
  
  Y <- year(R$dateutc)
  YY <- unique(Y)
  
  isoY<- isoyear(R$dateutc)
  isoYY <- unique(isoY)
  
  R$Year <- factor( Y, levels = YY, labels = YY)
  R$Month <- factor( month(R$dateutc), levels = 1:12, labels = Monatsnamen)
  
  R$ISOYear <- factor( isoY, levels = isoYY, labels = isoYY)
  R$ISOWeek <- factor( isoweek(R$dateutc), levels = 1:53, labels = paste('Week', 1:53))
  
  R$Day <- factor( yday(R$dateutc), levels = 1:366, labels = 1:366 )
  
  return(R)
  
}

