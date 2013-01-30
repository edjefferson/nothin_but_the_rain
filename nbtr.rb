require 'open-uri'
require 'json'
require 'mysql'
require './settings.rb'

def date_handler(param1,param2)
  year = param2[param1]['date']['year'].to_s
  mon = param2[param1]['date']['mon'].to_s
  mday = param2[param1]['date']['mday'].to_s
  hour = param2[param1]['date']['hour'].to_s
  min = param2[param1]['date']['min'].to_s
  date = Time.local(year,mon,mday,hour,min)
  return date
end

if ARGV.length!=8 or ARGV[2].length!=4 or ARGV[3].length!=2 or ARGV[4].length!=2 or ARGV[5].length!=4 or ARGV[6].length!=2 or ARGV[7].length!=2
  
  print "You didn't enter correct parameters you stupit idoit\n"
  
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

  dailysummary = parsed_json['history']['dailysummary']
  location = parsed_json['location']
  nicedate = parsed_json['history']['date']['pretty']
  ho = parsed_json['history']['observations']
  
  city = location['city']
  country = location['country']
  wmo = location['wmo']
  
  meantempm = dailysummary[0]['meantempm']
  maxtempm = dailysummary[0]['maxtempm']
  mintempm = dailysummary[0]['mintempm']
  precipm = dailysummary[0]['precipm']
  snowdepthm = dailysummary[0]['snowdepthm']
  meanwindspdm = dailysummary[0]['meanwindspdm']
  
  odate=date_handler(0,ho)
  
  con.query("INSERT INTO daily_observations_copy(city,country,meantempm,date,maxtempm,mintempm,precipm,snowdepthm,wmo,meanwindspdm) VALUES('#{city}','#{country}','#{meantempm}','#{odate}','#{maxtempm}','#{mintempm}','#{precipm}','#{snowdepthm}','#{wmo}','#{meanwindspdm}')")

  ho.each_with_index do |v, i|

  iodate=date_handler(i,ho)

    observationtemp = ho[i]['tempm']
    observationconds = ho[i]['conds']
    wspdm = ho[i]['wspdm']
    
    con.query("INSERT INTO observations_copy(city,country,tempm,observed_at,conditions,wmo,wspdm) VALUES('#{city}','#{country}','#{observationtemp}','#{iodate}','#{observationconds}','#{wmo}','#{wspdm}')")
    
  end
  
  starttime=starttime+86400

print "Stored weather data for #{nicedate} in #{city}, #{country}\n"

end

sleep 6

end
end
end