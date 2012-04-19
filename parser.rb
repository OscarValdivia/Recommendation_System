#Script in charge of parsing the data files and creating the user and ads arrays for later use

require "./ad.rb"
require "./user.rb"

def parser(user_file, ad_file)
   
    ix = 0 
    users = []     
    while(line = user_file.gets)
        line = line.strip.split(",")
        users.insert(ix, User.new(line[0], line[1], line[2], line[3], line[4], line[5]))
        ix += 1
    end

    ix = 0
    ads = []
    while(line = ad_file.gets)
        line = line.strip.split(",")
     
        flag = false
        for iy in ads
            if iy.get_id == line[0]
                flag = true
            end
        end
            
        if flag
            next
        end

        ads.insert(ix, Ad.new(line[0], line[1], line[2], line[3], line[4], line[5]))
        ix += 1
    end

    return users, ads
end

