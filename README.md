# WeatherScreen-PRO
R scripts to display recorded data from **dnt WeatherScreen PRO**

***dnt WeatherScreen PRO*** records the readings from up to eight sensors on an SD card.

The data is saved in CSV files in the ***/data*** folder. This application imports the data into a SQL database using a BASH script. The R scripts retrieve measured values from the database, evaluate the data and draw corresponding diagrams.

This git is based on [RoomLogg PRO](https://github.com/Byggvir/RoomLogg-PRO). The device ***RoomLogg PRO*** uses the same sensor type ***DNT00005*** but stores the data in a different file format.

## Installation

For installation, load this repository into a directory on your computer.

To create the SQL database with a ***dnt WeatherScreen PRO*** and 5 sensors as an example, run the SQL script ***init-db*** in the SQL directory as root.

Modify the SQL script ***init-db.sql*** to your needs.


```
    # move to directory of the downloaded / cloned git
    mysql --user=root --password < SQL/init-db.sql```
```

This script will create a database ***WeatherScreen*** with three tables ***devises***, ***sensors***, ***devicereports*** and ***sensorreports***.

Your can manage multiple ***dnt WeatherScreen PRO*** with multiple sensors.

In order to be able to access the SQL database with the R script, copy the sample configuration file ***SQL/WeatherScreen.conf*** to the directory ***~/R/sql.conf.d/*** in your home directory and adjust the user and password according to your needs.

I recommend creating your own user who has access to the database. Don't use root.

## Import own data

To import your own data into the database, copy the data from the root folder of tge SD-crad to the ***data/<n>*** folder in this repository. ***<n>*** must be the ***id*** of your device in then database.

Then go to the bash directory and convert the data with the BASH script  ***convert4import [device_id]***. All data is written to a file ***/tmp/WeatherStationsReports.csv*** and  ***/tmp/WeatherSensorReports.csv***. Olda files will be deleted at the begining.

These files can be imported into the database using the SQL script ***/SQL/import.sql***.

If you have more than one device add the device id to the call of ***convert4import***.

### Example

```
    cd bash
    ./convert4import 1
    cd ../SQL
    mysql --user=youruser --password  < import.sql
```

### Attention

You can only import the data of a specific device with these scripts. To import the data of multiple devices use a script or run multiple commands on command line.

## R-Scripts

The R-Scripts are located in the folder ***R/***. They draw different charts. The diagrams are stored in sub-folders of ***png***.

### lines.r

***lines.r*** Draws a simple line chart, which is only useful when the period is not to long.

Output is stored in ***png/lines/***.

### boxplots.r

***boxplots.r*** draws boxplots of temperature or humidity for days, weeks or months.

Output is stored in ***png/boxplots/***.

tbc