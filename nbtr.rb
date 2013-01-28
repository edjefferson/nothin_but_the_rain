require 'open-uri'
require 'json'
require 'mysql'
require './settings.rb'


load_settings('nbtrsettings.yaml')


con = Mysql.new @db_address, @db_user, @db_pass, @db_name

starttime=Time.local(ARGV[2],ARGV[3],ARGV[4])
endtimeplusone=Time.local(ARGV[5],ARGV[6],ARGV[7])
endtime=endtimeplusone+86400

if endtime-starttime>3200000
  
  print "You only get 500 free API requests a day so probably don't do this?\n"
  
else  

while starttime<endtime
  
open("http://api.wunderground.com/api/" + @wuapikey + "/history_" + starttime.strftime("%Y%m%d") + "/geolookup/conditions/q/" + ARGV[0]  + "/" + ARGV[1] + ".json") do |f|

  json_string = f.read
  parsed_json = JSON.parse(json_string)
  nicedate = parsed_json['history']['date']['pretty']
  ocity = parsed_json['location']['city']
  ocountry = parsed_json['location']['country']
  wmo = parsed_json['location']['wmo']
  meantempm = parsed_json['history']['dailysummary'].first['meantempm']
  maxtempm = parsed_json['history']['dailysummary'].first['maxtempm']
  mintempm = parsed_json['history']['dailysummary'].first['mintempm']
  precipm = parsed_json['history']['dailysummary'].first['precipm']
  snowdepthm = parsed_json['history']['dailysummary'].first['snowdepthm']
  meanwindspdm = parsed_json['history']['dailysummary'].first['meanwindspdm']
  

  

  finalobservationtime = parsed_json['history']['observations'].last['date']['pretty']

  observationnumber = 0
  oyear = parsed_json['history']['observations'][observationnumber]['date']['year'].to_s
  omon = parsed_json['history']['observations'][observationnumber]['date']['mon'].to_s
  omday = parsed_json['history']['observations'][observationnumber]['date']['mday'].to_s
  ohour = parsed_json['history']['observations'][observationnumber]['date']['hour'].to_s
  omin = parsed_json['history']['observations'][observationnumber]['date']['min'].to_s
  odate = Time.local(oyear,omon,omday,ohour,omin)
  fyear = parsed_json['history']['observations'].last['date']['year'].to_s
  fmon = parsed_json['history']['observations'].last['date']['mon'].to_s
  fmday = parsed_json['history']['observations'].last['date']['mday'].to_s
  fhour = parsed_json['history']['observations'].last['date']['hour'].to_s
  fmin = parsed_json['history']['observations'].last['date']['min'].to_s
  finaldate = Time.local(fyear,fmon,fmday,fhour,fmin)
  con.query("INSERT INTO daily_observations(city,country,meantempm,date,maxtempm,mintempm,precipm,snowdepthm,wmo,meanwindspdm) VALUES('#{ocity}','#{ocountry}','#{meantempm}','#{odate}','#{maxtempm}','#{mintempm}','#{precipm}','#{snowdepthm}','#{wmo}','#{meanwindspdm}')")

  
  countobs=parsed_json['history']['observations'].count

  
  while observationnumber < countobs

    ioyear = parsed_json['history']['observations'][observationnumber]['date']['year'].to_s
    iomon = parsed_json['history']['observations'][observationnumber]['date']['mon'].to_s
    iomday = parsed_json['history']['observations'][observationnumber]['date']['mday'].to_s
    iohour = parsed_json['history']['observations'][observationnumber]['date']['hour'].to_s
    iomin = parsed_json['history']['observations'][observationnumber]['date']['min'].to_s
    iodate = Time.local(ioyear,iomon,iomday,iohour,iomin)  

    observationtemp = parsed_json['history']['observations'][observationnumber]['tempm']
    observationconds = parsed_json['history']['observations'][observationnumber]['conds']
    wspdm = parsed_json['history']['observations'][observationnumber]['wspdm']
    con.query("INSERT INTO observations(city,country,tempm,observed_at,conditions,wmo,wspdm) VALUES('#{ocity}','#{ocountry}','#{observationtemp}','#{iodate}','#{observationconds}','#{wmo}','#{wspdm}')")
    observationnumber = observationnumber+1
    
  end
  starttime=starttime+86400

end
sleep 6
end
end