#Main file in charge of making the recommendations, it creates the user-item weight matrix, and has the topk recommendation method for a given user.

require './nmatrix.rb'
require './metrics.rb'

class Rs

    def initialize(nmatrix, metric = method(:metric_manhattan)) #nmatrix: a object of nmatrix type
                                                                #generates a matrix of all users vs all users
                                                                #with the distance between them, using metric as the distance function
        @nmatrix = nmatrix
        @nmatrix.normalize       
        @metric = metric
        @dist_all = {}
       
        using = nmatrix.get_matrix
        for ix in using
            for iy in using
                if @dist_all[ix[0]] == nil
                    @dist_all[ix[0]] = {}
                end
             
                if ix[0] != iy[0]
                    if ix[1].empty? == false and iy[1].empty? == false
                        @dist_all[ix[0]][iy[0]] = nmatrix.distance(ix[0], iy[0], metric) 
                    else
                        @dist_all[ix[0]][iy[0]] = 0.0
                    end
               end
            end
        end
 
        for ix, iy in @dist_all
            @dist_all[ix] = Hash[iy.sort_by {|key, value| -value}]
        end
    end

    def top_kn(u1, kn = 5, nmatrix = @nmatrix) #returns the topk item recommendations for the u1 user
                                               #kn: integer
                                               #u1: id of the user, string or integer
       if kn == 0
           return nil
       end
 
       data = {}
       mean = {}
       count = 0
       exist = false

       for ix in @dist_all
           if ix[0] == u1
               exist = true
           end
       end

       if exist == false
           puts "The id ('#{u1}') does not exists..."
           return nil
       end

       nmatrix.normalize
       matrix = nmatrix.get_matrix

       for ix in matrix
           for iy in ix[1]

               if data[iy[0]] == nil and matrix[u1][iy[0]] == nil
                   data[iy[0]] = 0
                   mean[iy[0]] = 0   
               end

               value = matrix[ix[0]][iy[0]]

               if value == nil
                   value = 0.0
               end

               

               if u1 != ix[0] and matrix[u1][iy[0]] == nil
                   data[iy[0]] += @dist_all[u1][ix[0]] * value 
                   mean[iy[0]] += 1
               end
           end
       end
      
       for ix in data
           data[ix[0]] /= mean[ix[0]]
       end

       data = Hash[data.sort_by {|key, value| -value}]

       if kn != -1
           for ix in data
               count += 1
           
               if count > kn
                   data.delete(ix[0])
               end
           end
       end

       return data           

    end

    def sim_item(item, nmatrix = @nmatrix) #returns the similarity of a given item, against all other items
                                           #in the form of a hash
        item = item.to_s
        exist = false
        nmatrix.invert(nmatrix.un_normalize, true)

        for ix in nmatrix.normalize
            if ix[0] == item
                exist = true
            end
        end

        if exist == false
            puts "The item id ('#{item}') does not exist..."
            return nil
        end

        return Rs.new(nmatrix).get_rs_data(item)
    end

    def get_dist_all
        return @dist_all
    end
   
    def get_metric
        return @metric
    end

    def get_nmatrix
        return @nmatrix
    end

    def get_rs_data(id, num = @dist_all[id].length) #return the similarity of a given user, against all other users
                                                    #in the form of an array
        if num <= 0
            return nil
        end

        data = {}
        count = 0
        exist = false

        for ix in @dist_all
            if ix[0] == id
                exist = true
            end
        end 

        if exist == false
            puts "The id ('#{id}') does not exist..."
            return nil
        end

        for ix in @dist_all[id]
            data[ix[0]] = ix[1]
            count += 1

            if count == num
                break
            end
        end   
         
        return data
    end    
end 
