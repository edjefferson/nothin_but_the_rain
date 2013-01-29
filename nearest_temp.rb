require 'mysql'
require './settings.rb'
con = Mysql.new @db_address, @db_user, @db_pass, @db_name
id = 1
while id<30000


  egg = con.query("select submitted_at from london2012reviews where id=#{id}").fetch_row[0].to_s



  nearesttemp = con.query("select * from observations order by abs(unix_timestamp('#{egg}')-unix_timestamp(observed_at)) limit 1").fetch_row[4]

  puts id
  
  con.query("INSERT INTO london2012review_temps(id,nearesttemp) VALUES('#{id}','#{nearesttemp}')")

  id +=1

end