#Manage the connections with the database

require "rubygems"
require "mysql"

def connect()
    location          = "localhost"
    user              = "root"
    password          = "password"
    recommendation_db = "db_name"
    
    db = Mysql.new(location, user, password)
    db.autocommit(false);
    #db.select_db(recommendation_db)

    return db
end
