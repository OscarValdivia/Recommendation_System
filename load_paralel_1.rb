#Loads the database with the necesary information to make statistics
#This loads 1/3 of the data (see load_pararel_2 and load_paralel_3 for more info)

require './db_connection.rb'
require './nmatrix.rb'
require './parser.rb'
require './rs.rb'
require './percentile.rb'

db = connect()
db.query("db_name")

source_users = File.new(ARGV[0], "r")
source_ads   = File.new(ARGV[1], "r")
iterations   = ARGV[2]
percent      = ARGV[3]

if iterations == nil
    iterations = 12
end

if percent == nil
    percent = 80
end

users, ads = parser(source_users, source_ads) #parse the input files, user and ads are arrays with user and ad objects

array = []
fy = []
iter = 0
for ix in 1..18 #3,4,9,10,15,16 label matrices    
    if ix == 1 or ix == 2 or ix == 5 or ix == 6 #only compute the given matrices types
        puts "Creating Matrix type #{ix}..."
        if ix % 2 != 0
            fy[iter] = Nmatrix.new(users, ads, ix)
            fy[iter].normalize
        else
            fy[iter-1].un_normalize
            fy[iter] = Marshal.load(Marshal.dump(Nmatrix.new(users, ads, ix, fy[iter-1].invert)))
        end

        iter += 1
    end
end

metrics = get_metrics #returns a hash with all the available metrics
flag = true
for count in 1..iterations

    iter = 0
    for ix in 0...fy.length
        array[iter], array[iter+1] = percentile(fy[ix], percent)
        iter += 2
    end

    flag = false
    for iy in array

        db.query("drop table if exists #{count}_rs_#{iy.get_type}_#{iy.get_percentile};")

        if flag
            flag = false
            
            puts "create table #{count}_rs_#{iy.get_type}_#{iy.get_percentile}"
            db.query("create table #{count}_rs_#{iy.get_type}_#{iy.get_percentile}
                    (id INT NOT NULL AUTO_INCREMENT,
                     user_id VARCHAR(200) NOT NULL,
                     item_id VARCHAR(200),
                     frequency INT,
                     Primary Key(id));")

            counter = 1

            for ix in iy.get_matrix

               for ch in ix[1]
                   db.query("INSERT INTO #{count}_rs_#{iy.get_type}_#{iy.get_percentile} (user_id) 
                                    VALUES ('#{ix[0]}');")
                   
                   if ch[0] != nil
                       db.query("UPDATE #{count}_rs_#{iy.get_type}_#{iy.get_percentile} 
                                        SET item_id = '#{ch[0]}'
                                        WHERE id = '#{counter}';")
                   end

                   if ch[1] != nil
                       db.query("UPDATE #{count}_rs_#{iy.get_type}_#{iy.get_percentile} 
                                        SET frequency = #{ch[1]}
                                        WHERE id = '#{counter}';")
                   end

                  counter += 1
               end
            end

            next
        end

        puts "create table #{count}_rs_#{iy.get_type}_#{iy.get_percentile}"
        db.query("create table #{count}_rs_#{iy.get_type}_#{iy.get_percentile}
                (id INT NOT NULL AUTO_INCREMENT,
                 matrix_type INT NOT NULL,
                 metric_function INT NOT NULL,
                 user_id VARCHAR(200) NOT NULL,
                 item_id VARCHAR(200) NOT NULL,
                 weight FLOAT NOT NULL,
                 Primary Key(id));")


        for ia in metrics
            rs = Rs.new(Nmatrix.new(users, ads, iy.get_type, iy.get_matrix), method(ia[1]))

            for iz in rs.get_dist_all
                for it in rs.top_kn(iz[0], -1)
                    db.query("INSERT INTO #{count}_rs_#{iy.get_type}_#{iy.get_percentile} (matrix_type, metric_function, user_id, item_id, weight)
                                     VALUES (#{iy.get_type}, #{ia[0]}, '#{iz[0]}', '#{it[0]}', #{it[1]});")
                end
            end
        end

        flag = true
    end
end


db.commit
db.close
