#Loads the database with the necesary information to make statistics
#This loads databae itself and the main tables of the data (see load_paralel_1, load_pararel_2 and load_paralel_3 for more info)


require './db_connection.rb'
require './nmatrix.rb'
require './parser.rb'
require './rs.rb'
require './percentile.rb'

db = connect()

recommendation_db = "rs_skillup2"
db.query("drop database if exists #{recommendation_db};")
db.query("create database #{recommendation_db};")
db.select_db(recommendation_db)



db.query("create table radius
            (id INT NOT NULL AUTO_INCREMENT,
             user_id VARCHAR(200) NOT NULL,
             perimeter INT NOT NULL,
             Primary Key (id));")

db.query("create table ads
            (id INT NOT NULL AUTO_INCREMENT,
             ad_id INT NOT NULL,
             label VARCHAR(100) NOT NULL,
             format VARCHAR(50) NOT NULL,
             size FLOAT NOT NULL,
             device VARCHAR(200) NOT NULL,
             advertiser VARCHAR(200) NOT NULL,
             Primary Key(id));")

db.query("create table users 
            (id INT NOT NULL AUTO_INCREMENT,
             user_id VARCHAR(200) NOT NULL, 
             ad_id INT NOT NULL, 
             timestamp TIMESTAMP NOT NULL, 
             latitud FLOAT NOT NULL, 
             longitud FLOAT NOT NULL,
	     radius INT NOT NULL, 
             agent VARCHAR(200) NOT NULL,
             Primary Key(id),
             Foreign Key(ad_id) references ads(ad_id));")

source_users = File.new(ARGV[0], "r")
source_ads   = File.new(ARGV[1], "r")
iterations   = ARGV[2]

if iterations == nil
    iterations = 12
end

users, ads = parser(source_users, source_ads)

for ix in users
    db.query("INSERT INTO users (user_id, ad_id, timestamp, latitud, longitud, agent)
                     VALUES ('#{ix.get_id}', #{ix.get_ad}, '#{ix.get_timestamp}', 
                             #{ix.get_latitud.to_f}, #{ix.get_longitud.to_f}, '#{ix.get_agent}');")
end

for ix in ads
    db.query("INSERT INTO ads (ad_id, label, format, size, device, advertiser)
                     VALUES (#{ix.get_id}, '#{ix.get_label}', '#{ix.get_format}', 
                             #{ix.get_size.to_f}, '#{ix.get_device}', '#{ix.get_advertiser}');")
end



db.commit
db.close

