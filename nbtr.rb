require 'open-uri'
require 'json'
require 'mysql'
require './settings.rb'

def date_handler(param1,param2)
  year = param2['history']['observations'][param1]['date']['year'].to_s
  mon = param2['history']['observations'][param1]['date']['mon'].to_s
  mday = param2['history']['observations'][param1]['date']['mday'].to_s
  hour = param2['history']['observations'][param1]['date']['hour'].to_s
  min = param2['history']['observations'][param1]['date']['min'].to_s
  date = Time.local(year,mon,mday,hour,min)
  return date
end

if ARGV.length!=8
  
  print "You didn't enter enough parameters you stupit idoit\n"
  
else

load_settings('nbtrsettings.yaml')

con = Mysql.new @db_address, @db_user, @db_pass, @db_name

starttime=Time.local(ARGV[2],ARGV[3],ARGV[4])
endtimeplusone=Time.local(ARGV[5],ARGV[6],ARGV[7])
endtime=endtimeplusone+86400

if endtime-starttime>33000000
  
  print "You only get 500 free API requests a day so probably don't do this?\n"
  
else  

while starttime<endtime
  
open("http://api.wunderground.com/api/" + @wuapikey + "/history_" + starttime.strftime("%Y%m%d") + "/geolookup/conditions/q/" + ARGV[0]  + "/" + ARGV[1] + ".json") do |f|

  json_string = f.read
  parsed_json = JSON.parse(json_string)

  nicedate = parsed_json['history']['date']['pretty']
  city = parsed_json['location']['city']
  country = parsed_json['location']['country']
  wmo = parsed_json['location']['wmo']
  meantempm = parsed_json['history']['dailysummary'].first['meantempm']
  maxtempm = parsed_json['history']['dailysummary'].first['maxtempm']
  mintempm = parsed_json['history']['dailysummary'].first['mintempm']
  precipm = parsed_json['history']['dailysummary'].first['precipm']
  snowdepthm = parsed_json['history']['dailysummary'].first['snowdepthm']
  meanwindspdm = parsed_json['history']['dailysummary'].first['meanwindspdm']
  
  observationnumber = 0
  
  odate=date_handler(observationnumber,parsed_json)
  
  con.query("INSERT INTO daily_observations(city,country,meantempm,date,maxtempm,mintempm,precipm,snowdepthm,wmo,meanwindspdm) VALUES('#{city}','#{country}','#{meantempm}','#{odate}','#{maxtempm}','#{mintempm}','#{precipm}','#{snowdepthm}','#{wmo}','#{meanwindspdm}')")

  countobs=parsed_json['history']['observations'].count

  
  while observationnumber < countobs

  iodate=date_handler(observationnumber,parsed_json)

    observationtemp = parsed_json['history']['observations'][observationnumber]['tempm']
    observationconds = parsed_json['history']['observations'][observationnumber]['conds']
    wspdm = parsed_json['history']['observations'][observationnumber]['wspdm']
    
    con.query("INSERT INTO observations(city,country,tempm,observed_at,conditions,wmo,wspdm) VALUES('#{city}','#{country}','#{observationtemp}','#{iodate}','#{observationconds}','#{wmo}','#{wspdm}')")
    
    observationnumber = observationnumber+1
    
  end
  
  starttime=starttime+86400

print "Stored weather data for #{nicedate} in #{city}, #{country}\n"

end

sleep 6
end
end
end