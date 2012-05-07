#Calculates the geolocalization id's for given input points, then loads that information to the users array

def geo(users, n = 60, m = 60, radius = 0)
    
    boxes = []
    longitud = []
    latitud = []
    center_lat = []
    center_long = []
    results = []
    amount = 0
    flago = true  

    for ix in users
	for iy in 0..longitud.length
	   if longitud[iy] == ix.get_longitud.to_f and latitud[iy] == ix.get_latitud.to_f
	      flago = false
	   end
	end
	if flago == false then
         flago = true    
         next
        end
              longitud[amount] = ix.get_longitud.to_f
              latitud[amount] = ix.get_latitud.to_f
              amount += 1
    end

    long_max = longitud.max + 1
    long_min = longitud.min - 1
    lat_max = latitud.max + 1
    lat_min = latitud.min - 1
    
    long_size = (Math.sqrt((long_max - long_min)*(long_max - long_min)) / n)
    lat_size = (Math.sqrt((lat_max - lat_min)*(lat_max - lat_min)) / m)
    
    long_var = long_min + long_size
    lat_var = lat_min + lat_size
    
    box = 0
    pos = 0

    while lat_var <= lat_max+1 do
        while long_var <= long_max+1 do
            for ix in 0...amount 
                if longitud[ix] <= long_var && latitud[ix] <= lat_var && boxes[ix].nil?
                    boxes[ix] = box
		end
		#if box == 2
                  # p "#{longitud[ix]} <= #{long_var} && #{latitud[ix]} <= #{lat_var}, boxes[ix] = #{boxes[ix]}"
		#end
		#if longitud[ix] <= 90 && latitud[ix] <= -30 && box == 2 && boxes[ix].nil?
		#	p box
                #   p "#{longitud[ix]} <= #{long_var} && #{latitud[ix]} <= #{lat_var}, boxes[ix] = #{boxes[ix]}"
		#end

            end
#p "#{lat_var}, #{long_var}|#{lat_max},#{long_max}"
            long_var += long_size 
            box += 1
		    
        end
            long_var = long_min + long_size
            lat_var += lat_size
    end
    count = 0
    sum_long = 0 
    sum_lat = 0
#p "amount #{amount} boxeslength #{boxes.length}"       
    for ix in 0..amount
        for iy in 0..boxes.length
            if boxes[iy] == ix
                count += 1
                sum_long += longitud[iy] 
                sum_lat += latitud[iy]
            end
        end
        if count != 0
            center_lat[ix] = sum_lat / count
            center_long[ix] = sum_long / count
            count = 0
            sum_long = 0
            sum_lat = 0
        end
    end
#p "4"        
    for ix in 0...amount
        results[ix] = []
    end
    
    check = true
   
#if radius == 0
#  if lat_size > long_size
#	radius = lat_size
# else radius = long_size
#end
#end 
if radius == 0
	radius = Math.sqrt(((long_min + (long_size)/2) - long_min)**2 + (lat_min + (lat_size)/2 - lat_min)**2) +1

end
    if radius != 0
        for ix in 0..center_lat.length
            for iy in 0...amount
                if center_lat[ix] && center_long[ix]
                    if radius+1 >= Math.sqrt((longitud[iy] - center_long[ix])**2 + (latitud[iy] - center_lat[ix])**2)
                        results[iy].insert(0,ix)
                    end
                end
            end
        end
    else
        radius = 1
        while check do
            for ix in 0..center_lat.length
                for iy in 0..amount
                    if center_lat[ix] && center_long[ix]
                        if radius+1 >= Math.sqrt((longitud[iy] - center_long[ix])**2 + (latitud[iy] - center_lat[ix])**2)
                            results[iy].insert(0,ix)
                        end
                    end
                end
            end
            check = false
            for ix in 0..amount
                if results[ix].empty?
                    for iz in 0..amount
                        results[iz] = []
                    end
                    check = true
                    radius += 1
                    break
                end
            end
        end
    end
        #p center_lat
        #p center_long
        #p boxes
        #p results
#p "5"
    for ix in users
        for iy in 0...amount
            if ix.get_longitud.to_f == longitud[iy].to_f && ix.get_latitud.to_f == latitud[iy].to_f
	       ix.set_radius(results[iy])
               break
	    end
	end
    end
#p "6"
#for ix in 0..longitud.length
#p "#{longitud[ix]},#{latitud[ix]},#{results[ix]}"
#end
p results;
    return users    
end
        
