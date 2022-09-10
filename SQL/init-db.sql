DROP DATABASE IF EXISTS `WeatherScreen`;
CREATE DATABASE IF NOT EXISTS WeatherScreen;

GRANT ALL ON WeatherScreen.* to 'statistik'@'localhost';

FLUSH PRIVILEGES;

USE `WeatherScreen`;

--
-- Table structure for table `devices`
--

DROP TABLE IF EXISTS `devices`;

CREATE TABLE `devices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `devtype` char(64) DEFAULT NULL,
  `name` char(64) DEFAULT NULL,
  `location` char(64) DEFAULT NULL,
  `location_lat` double DEFAULT NULL,
  `location_long` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  INDEX `location` (`location`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DROP TABLE IF EXISTS `sensors`;

CREATE TABLE `sensors` (
  `device_id` int(11) NOT NULL,
  `channel` int(11) NOT NULL,
  `sensorlocation` char(64) DEFAULT NULL,
  `sensortype` char(64) DEFAULT NULL,
  PRIMARY KEY (`device_id`, `channel`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `sensorreports`
--

DROP TABLE IF EXISTS `devicereports`;

CREATE TABLE `devicereports` (
  `device_id` int(11) NOT NULL,
  `dateutc` datetime DEFAULT NULL,
  `TemperaturInnen`  double DEFAULT NULL,
  `LuftfeuchtigkeitInnen`  double DEFAULT NULL,
  `TemperaturAussen`  double DEFAULT NULL,
  `LuftfeuchtigkeitAussen`  double DEFAULT NULL,
  `Taupunkt`  double DEFAULT NULL,
  `GefuehlteTemperatur`  double DEFAULT NULL,
  `Wind`  double DEFAULT NULL,
  `Boee`  double DEFAULT NULL,
  `Windrichtung`  double DEFAULT NULL,
  `AbsLuftdruck`  double DEFAULT NULL,
  `RelLuftdruck`  double DEFAULT NULL,
  `Sonneneinstrahlung`  double DEFAULT NULL,
  `UVI`  int(11) DEFAULT NULL,
  `RegenStunde`  double DEFAULT NULL,
  `RegenEvent`  double DEFAULT NULL,
  `RegenTag`  double DEFAULT NULL,
  `RegenWochen`  double DEFAULT NULL,
  `RegenMonat`  double DEFAULT NULL,
  `RegenJahre`  double DEFAULT NULL,
  `Pm25`  double DEFAULT NULL,
  PRIMARY KEY ( `device_id`, `dateutc` )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Table structure for table `sensorreports`
--

DROP TABLE IF EXISTS `sensorreports`;

CREATE TABLE `sensorreports` (
  `device_id` int(11) NOT NULL,
  `channel` int(11) NOT NULL,
  `dateutc` datetime NOT NULL,
  `Temperature` double DEFAULT NULL,
  `Humidity` double DEFAULT NULL,
  `Dewpoint` double DEFAULT NULL,
  `HeatIndex` double DEFAULT NULL,
  PRIMARY KEY ( `device_id`, `channel`, `dateutc` )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `devices` VALUES (1, 'WeatherScreen PRO', 'Mittelerde', 'Zingsheimstraße 31, 53359 Rheinbach', 50.6209, 6.9616);

INSERT INTO `sensors` VALUES (1 , 2, 'Schlafzimmer', 'DNT000005') ;
INSERT INTO `sensors` VALUES (1 , 4, 'Daniel', 'DNT000005') ;
INSERT INTO `sensors` VALUES (1 , 5, 'Stephan', 'DNT000005') ;
INSERT INTO `sensors` VALUES (1 , 8, 'Wintergarten', 'DNT000005') ;
