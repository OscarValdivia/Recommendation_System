#The ad class, with all its properties

class Ad

    def initialize(id, label, format, size, device, advertiser)
        @id = id
        @label = label
        @format = format
        @size = size
        @device = device
        @advertiser = advertiser
    end

    def get_id
        return @id
    end

    def get_label
        return @label
    end

    def get_format
        return @format
    end

    def get_size
        return @size
    end

    def get_device
        return @device
    end

    def get_advertiser
        return @advertiser
    end
end

