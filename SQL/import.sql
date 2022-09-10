use WeatherScreen;

LOAD DATA LOCAL 
INFILE '/tmp//WeatherScreenStationReports.csv'      
INTO TABLE `devicereports`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

LOAD DATA LOCAL 
INFILE '/tmp/WeatherScreenSensorReports.csv'      
INTO TABLE `sensorreports`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;
