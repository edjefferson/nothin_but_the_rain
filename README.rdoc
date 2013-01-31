nothin_but_the_rain
===================

This talks to the http://www.wunderground.com/ weather API and deposits daily and hourly/half-hourly weather observations into a MySQL databse.

You'll need to register for an API key at http://www.wunderground.com/weather/api/.

You can get full access for free but are limited to 500 calls a day and 10 calls a minute- I've limited it so it will take at least 6 seconds per day of data you want to download.

Command line format: ruby nrtb.rb [country] [city] [start year] [start month] [start day]
[end year] [end month] [end day]

You'll need to create a file called nbtrsettings.yaml containing an API key and info about the database you want to write to - I've included a sample with format

Disclaimer: I am an idiot and this is probably terrible garbage.
