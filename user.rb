#The user class, with all its properties

class User

    def initialize(id, ad, timestamp, latitud, longitud, agent)
        @id = id
        @ad = ad
        @timestamp = timestamp
        @latitud = latitud
        @longitud = longitud 
        @radius = []
        @agent = agent
    end

    def get_id
        return @id
    end

    def get_ad
        return @ad
    end

    def get_timestamp
        return @timestamp
    end

    def get_latitud
        return @latitud
    end

    def get_longitud
        return @longitud
    end

    def get_radius
        return @radius
    end

    def get_agent
        return @agent
    end  
    
    def set_radius(rad)
        @radius = rad
    end
end
