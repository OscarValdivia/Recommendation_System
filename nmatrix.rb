#The main matrix class, this is in charge of generating the user-item frequency matrix, and deciding on wich type of matrix to generate

require "./metrics.rb"
require "./geo.rb"

class Nmatrix

    def initialize(users, ads, type = 1, matrix = create_matrix(users, ads, type))
        
        @norm = false #Is the matrix normalized?
        @type = type 
        @matrix = matrix
        @un_norm = {} #hash of the sum number used to normalize the matrix, this is used for un-normalize the matrix
    end

    def create_matrix(users, ads, type = 1)
 
        matrix = {}
        
        case type
            when 1, 2 #1:Matrix User-Ad | 2:Matrix Ad-User
                for ix in users
                    if matrix[ix.get_id] == nil
                        matrix[ix.get_id] = {}
                    end
 
                    if matrix[ix.get_id][ix.get_ad] == nil
                        matrix[ix.get_id][ix.get_ad] = 1
                    else
                        matrix[ix.get_id][ix.get_ad] += 1 
                    end
                end
        
            when 3, 4 #3:Matrix User-Label | 4:Matrix Label-User
                for ix in users
                    if matrix[ix.get_id] == nil
                        matrix[ix.get_id] = {}
                    end
                
                    for iy in ads
                        if iy.get_id == ix.get_ad
                            if matrix[ix.get_id][iy.get_label] == nil
                                matrix[ix.get_id][iy.get_label] = 1
                            else
                                matrix[ix.get_id][iy.get_label] += 1
                            end
                        end
                    end 
                end

            when 5, 6 #5:Matrix User-Advertiser | 6:Matrix Advertiser-User 
                for ix in users
                    if matrix[ix.get_id] == nil
                        matrix[ix.get_id] = {}
                    end
                    
                    for iy in ads
                        if iy.get_id == ix.get_ad
                            if matrix[ix.get_id][iy.get_advertiser] == nil
                                matrix[ix.get_id][iy.get_advertiser] = 1
                            else
                                matrix[ix.get_id][iy.get_advertiser] += 1
                            end
                        end
                    end 
                end
 
            when 7, 8 #7:Matrix Geolocalization-Ad | 8:Matrix Ad-Geolocalization

                count = 0
                isthere = {}
                for ix in users
                    if isthere[ix.get_id] == nil
                        isthere[ix.get_id] = 1
                        count += 1
                    end
                end

                count = count*0.25
                n = (count**0.5).to_i

                if n < 2
                    n = 2
                end

                geo(users, n, n)  
                
                for ix in users
                    radius = ix.get_radius
                
                    for iy in radius
                        if matrix[iy] == nil
                            matrix[iy] = {}
                        end


                        if matrix[iy][ix.get_ad] == nil
                            matrix[iy][ix.get_ad] = 1
                        else
                            matrix[iy][ix.get_ad] += 1
                        end
                    end
                end
  
            when 9, 10 #9:Matrix Geolocalization-Label | 10:Matrix Label-Geolocalization
                
                count = 0
                isthere = {}
                for ix in users
                    if isthere[ix.get_id] == nil
                        isthere[ix.get_id] = 1
                        count += 1
                    end
                end

                count = count*0.25
                n = (count**0.5).to_i

                if n < 2
                    n = 2
                end

                geo(users, n, n)      
                
                for ix in users
                    radius = ix.get_radius
                    
                    for iy in ads
                        for iz in radius
                            if matrix[iz] == nil
                                matrix[iz] = {}
                            end

                            if matrix[iz][iy.get_label] == nil
                                matrix[iz][iy.get_label] = 1
                            else
                                matrix[iz][iy.get_label] += 1
                            end
                        end
                    end
                end               

            when 11, 12 #11:Matrix Geolocalization-Advertiser | 12:Matrix Advertiser-Geolocalization
                
                count = 0
                isthere = {}
                for ix in users
                    if isthere[ix.get_id] == nil
                        isthere[ix.get_id] = 1
                        count += 1
                    end
                end

                count = count*0.25
                n = (count**0.5).to_i

                if n < 2
                    n = 2
                end

                geo(users, n, n)      
                
                for ix in users
                    radius = ix.get_radius
               
                    for iy in ads 
                        for iz in radius
                            if matrix[iz] == nil
                                matrix[iz] = {}
                            end

                            if matrix[iz][iy.get_advertiser] == nil
                                matrix[iz][iy.get_advertiser] = 1
                            else
                                matrix[iz][iy.get_advertiser] += 1
                            end
                        end
                    end
                end                

            when 13, 14 #13:Matrix Agent-Ad | 14:Matrix Ad-Agent
                for ix in users
                    if matrix[ix.get_agent] == nil
                        matrix[ix.get_agent] = {}
                    end
 
                    if matrix[ix.get_agent][ix.get_ad] == nil
                        matrix[ix.get_agent][ix.get_ad] = 1
                    else
                        matrix[ix.get_agent][ix.get_ad] += 1
                    end
                end
 
            when 15, 16 #15:Matrix Agent-Label | 16:Matrix Label-Agent
                for ix in users
                    if matrix[ix.get_agent] == nil
                        matrix[ix.get_agent] = {}
                    end
                
                    for iy in ads
                        if iy.get_id == ix.get_ad
                            if matrix[ix.get_agent][iy.get_label] == nil
                                matrix[ix.get_agent][iy.get_label] = 1
                            else
                                matrix[ix.get_agent][iy.get_label] += 1
                            end
                        end
                    end 
                end

            when 17, 18 #17:Matrix Agent-Advertiser | 18:Matrix Advertiser-Agent
                for ix in users
                    if matrix[ix.get_agent] == nil
                        matrix[ix.get_agent] = {}
                    end
                
                    for iy in ads
                        if iy.get_id == ix.get_ad
                            if matrix[ix.get_agent][iy.get_advertiser] == nil
                                matrix[ix.get_agent][iy.get_advertiser] = 1
                            else
                                matrix[ix.get_agent][iy.get_advertiser] += 1
                            end
                        end
                    end 
                end

            else
                p "Unknown parameter, matrix type must be between 1 and 18..."
                return nil
        end

        if (type % 2) == 0
             matrix = invert(matrix)
        end 	

        for ix,iy in matrix
           matrix[ix] = Hash[iy.sort_by {|key, value| -value }]
        end

        @matrix = matrix
    end

    def get_type
        return @type
    end

    def get_matrix
        return @matrix
    end

    def set_matrix(matrix)
        @matrix = matrix
    end

    def get_data_user(id, num = @matrix[id].length) #WARNING: call this method with existing ids...

        if num <= 0
            return nil
        end

        data = {}
        count = 0

        for ix in @matrix[id]
            data[ix[0]] = ix[1]            
            count += 1

            if count == num
                break
            end
        end

        return data
    end

    def invert(matrix = @matrix, override = false) #override tells the class to override the original matrix with the inverted one

        if matrix == @matrix and @norm == true
            puts "Can't invert the matrix if it's normalized..."
            return nil
        end        

        inv = {}

        for ix in matrix
            for iy in ix[1]
                if inv[iy[0]] == nil
                    inv[iy[0]] = {}
                end
                 
                inv[iy[0]][ix[0]] = iy[1] 
            end
        end

        if override == true
            @matrix = inv
        end

        return inv
    end

    def normalize
        
        if @norm == true
            return @matrix
        end

        @norm = true

        for ix in @matrix
            sum = 0
           
            for iy in ix[1]
                sum += iy[1]
            end
            
            for iy in ix[1]
                @matrix[ix[0]][iy[0]] /= sum.to_f
                @un_norm[ix[0]] = sum.to_f
            end
        end

        return @matrix
    end

    def un_normalize
    
        if @norm == false
            return @matrix
        end

        @norm = false

        for ix in @matrix
            for iy in ix[1]
                @matrix[ix[0]][iy[0]] *= @un_norm[ix[0]]
            end
            
            @un_norm[ix[0]] = -1.0
        end

        return @matrix
    end

    def distance(u1, u2, function = method(:metric_manhattan)) #WARNING: call this method with existing user ids
        
        check1 = false
        check2 = false       

        #for ix in @matrix
        #    if ix[0] == u1
        #        check1 = true
        #    end
            
        #    if ix[0] == u2
        #        check2 = true
        #    end
        #end

        #if check1 == false
        #    puts "The paramenter u1 given ('#{u1}') doesn't exist..."
        #    return
        #end

        #if check2 == false
        #    puts "The parameter u2 given ('#{u2}') doesn't exist..."
        #    return
        #end
        
        self.normalize
        u1 = self.get_data_user(u1)
        u2 = self.get_data_user(u2)
        return function.call(u1,u2) 
    end
end
