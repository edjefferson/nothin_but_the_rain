require 'yaml'

def load_settings(param1)

  settings = YAML.load_file(param1)
  @wuapikey = settings["wuapi-key"]
  @db_address = settings["db-address"]
  @db_user = settings["db-user"]
  @db_pass = settings["db-pass"]
  @db_name = settings["db-name"]
  
end

