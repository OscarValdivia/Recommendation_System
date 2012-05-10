#Calculates the geolocalization id's for given input points, then loads that information to the users array

# class geo
def geo(users, n = 60, m = 60, radius = 0)
    
#array: the index is the number of the cuadrant that a coordinate is.
    boxes = []
#given a coordinate (x,y), latitude is x and longitude is y. All the coordinates are stored in the array.
    longitud = []
    latitud = []
#store the latitude and longitude of the gravity center for each cuadrant.
    center_lat = []
    center_long = []
#array of array, contains the id of all the radius where the coordinate is.
    results = []
#amount of coordinates.
    amount = 0
    flago = true  

#get the latitude and longitude (unique) of all the coordinates from users
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

#variables for the construction of the virtual map
    long_max = longitud.max + 1
    long_min = longitud.min - 1
    lat_max = latitud.max + 1
    lat_min = latitud.min - 1
#size of the cuadrants    
    long_size = (Math.sqrt((long_max - long_min)*(long_max - long_min)) / n)
    lat_size = (Math.sqrt((lat_max - lat_min)*(lat_max - lat_min)) / m)
    
    long_var = long_min + long_size
    lat_var = lat_min + lat_size
    
    box = 0
    pos = 0
#for each coordinate store the cuadrants where it is
    while lat_var <= lat_max+1 do
        while long_var <= long_max+1 do
            for ix in 0...amount 
                if longitud[ix] <= long_var && latitud[ix] <= lat_var && boxes[ix].nil?
                    boxes[ix] = box
		end
            end
            long_var += long_size 
            box += 1
        end
            long_var = long_min + long_size
            lat_var += lat_size
    end
    count = 0
    sum_long = 0 
    sum_lat = 0
#calculate the center of gravity for each cuadrant
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

    for ix in 0...amount
        results[ix] = []
    end
    
    check = true

#insert radius id in results
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
	radius = Math.sqrt(((long_min + (long_size)/2) - long_min)**2 + (lat_min + (lat_size)/2 - lat_min)**2) +1
    end

#insert radius id into users
    for ix in users
        for iy in 0...amount
            if ix.get_longitud.to_f == longitud[iy].to_f && ix.get_latitud.to_f == latitud[iy].to_f
	       ix.set_radius(results[iy])
               break
	    end
	end
    end

#return users with radius
    return users    
end
        
