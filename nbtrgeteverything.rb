require 'open-uri'
require 'json'
require 'mysql'
require 'date'
require './settings.rb'

class Hash
  def remove!(*keys)
    keys.each{|key| self.delete(key) }
    self
  end
end

load_settings('nbtrsettings.yaml')

def date_handler(param1,param2)
 Time.new(*param2[param1]['date'].values[1..5])
end

def nbtrmain(a1,a2,startdate,enddate)
  
    con = Mysql.new @db_address, @db_user, @db_pass, @db_name
    datestocheck=*(startdate..enddate)


    if datestocheck.size>365
  
      print "You only get 500 free API requests a day so probably don't do this?\n"
  
    else  
            

      datestocheck.each do |d|
        @resumedate=d
  
        open("http://api.wunderground.com/api/" + @wuapikey + "/history_" + d.strftime("%Y%m%d") + "/geolookup/conditions/q/" + a1  + "/" + a2 + ".json") do |f|

          json_string = f.read
          parsed_json = JSON.parse(json_string)

          dailysummary = parsed_json['history']['dailysummary'][0]
          location = parsed_json['location']
          nicedate = parsed_json['history']['date']['pretty']
          ho = parsed_json['history']['observations']
  
          city = location['city']
          country = location['country']
          wmo = location['wmo']
          
          dailysummary.remove!("date")
          
          #hod=ho[1].remove("date","utcdate")
          #ckeys=dailysummary.keys.join(",").gsub(',', ' varchar(255),') << " varchar(255)"
          #ckeys2=hod.keys.join(",").gsub(',', ' varchar(255),') << " varchar(255)"
          #con.query("CREATE TABLE daily_observations_new (city varchar(255),country varchar(255),date datetime,#{ckeys})") #uncommenttheseifrunningforfirsttime
          #con.query("CREATE TABLE observations_new (city varchar(255),country varchar(255),observed_at datetime,#{ckeys2})") #uncommenttheseifrunningforfirsttime
          
          odate=date_handler(0,ho)
  
          con.query("INSERT INTO daily_observations_new(city,country,date,#{dailysummary.keys.join(',')}) VALUES('#{city}','#{country}','#{odate}','#{dailysummary.values.join('\',\'')}')")

          ho.each_with_index do |v, i|

            iodate=date_handler(i,ho)
            
            ho[i].remove!("date","utcdate")
            
    
            con.query("INSERT INTO observations_new(city,country,observed_at,#{ho[i].keys.join(',')}) VALUES('#{city}','#{country}','#{iodate}','#{ho[i].values.join('\',\'')}')")
    
          end
  
          puts "Stored weather data for #{nicedate} in #{city}, #{country}, going to sleep for 6 seconds so the API doesn't cry"
          
        end  

        sleep 6

      end
    end
  end

begin
  startat=Date.new(ARGV[2].to_i,ARGV[3].to_i,ARGV[4].to_i)
  finishat=Date.new(ARGV[5].to_i,ARGV[6].to_i,ARGV[7].to_i)
  nbtrmain(ARGV[0],ARGV[1],startat,finishat)

rescue EOFError
  puts "something done fucked up (EOFerror), trying to resume"
  nbtrmain(ARGV[0],ARGV[1],@resumedate,finishat)
end

