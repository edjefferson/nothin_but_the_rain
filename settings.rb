require 'yaml'
settings = YAML.load_file('nbtrsettings.yaml')
wuapikey = settings["wuapi-key"]
db_address = settings["db-address"]
db_user = settings["db-user"]
db_pass = settings["db-pass"]
db_name = settings["db-name"]