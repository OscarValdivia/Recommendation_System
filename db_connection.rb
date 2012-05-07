#Manage the connections with the database

require "rubygems"
require "mysql"

def connect()
    location          = "localhost"
    user              = "root"
    password          = "quake321"
    recommendation_db = "rs_skillup2"
    
    db = Mysql.new(location, user, password)
    db.autocommit(false);
    #db.select_db(recommendation_db)

    return db
end
