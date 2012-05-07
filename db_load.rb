#Loads the databse with the information required to recommend

require './db_connection.rb'
require './nmatrix.rb'
require './parser.rb'
require './rs.rb'

db = connect() #Makes the connection with the database. (see db.connect.rb)

recommendation_db = "rs_skillup"

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
             agent VARCHAR(200) NOT NULL,
             Primary Key(id),
             Foreign Key(ad_id) references ads(ad_id));")

db.query("create table recommendations
            (id INT NOT NULL AUTO_INCREMENT,
             matrix_type INT NOT NULL,
             metric_function INT NOT NULL,
             user_id VARCHAR(200) NOT NULL,
             item_id VARCHAR(200) NOT NULL,
             weight FLOAT NOT NULL,
             Primary Key(id));")

source_users = File.new(ARGV[0], "r")
source_ads   = File.new(ARGV[1], "r")

users, ads = parser(source_users, source_ads) #call the parser function, wich returns a array of users and ads.

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

metrics = get_metrics #get_metric returns a hash with the available metric functions

for ix in 1..18
    for iy in metrics
        rs = Rs.new(Nmatrix.new(users, ads, ix), method(iy[1]))

        for iz in rs.get_dist_all #get_dist_all returns the alluser_VS_alluser matrix 
            for it in rs.topkn(iz[0], -1)
                db.query("INSERT INTO recommendations (matrix_type, metric_function, user_id, item_id, weight)
                                 VALUES (#{ix}, #{iy[0]}, '#{iz[0]}', '#{it[0]}', #{it[1]});")
            end
        end
    end
end

for ix in users 
    for iy in ix.get_radius
        db.query("INSERT INTO radius (user_id, perimeter)
                          VALUES ('#{ix.get_id}', #{iy});")
    end
end

db.commit
db.close
