#Script that creates the matrix used in statistics generation

require "./parser"
require "./nmatrix"

class DTMatrix

    def initialize(matrix, data = true, percentile = 80, type = 1)
    
        @data = data
        @percentile = percentile
        @type = type
        @matrix = matrix
    end

    def get_data
        return @data
    end

    def get_percentile
        return @percentile
    end

    def get_type
        return @type
    end

    def get_matrix
        return @matrix
    end
end

def percentile (matrix, percentile = 80)

    data_m = {}
    test_m = {}
              
    using = Marshal.load(Marshal.dump(matrix.get_matrix))

    for iy in using
        stop = (iy[1].length*percentile/100).round
        if stop == 0
           stop = 1
        end
       
        for iz in 1..stop
            rkey = iy[1].keys[rand(iy[1].length)]
            if data_m[iy[0]] == nil
                data_m[iy[0]] = {}
            end

            data_m[iy[0]][rkey] = iy[1].delete(rkey)
        end

        test_m[iy[0]] = iy[1]
    end
   
    return DTMatrix.new(data_m, true, percentile, matrix.get_type), DTMatrix.new(test_m, false, 100-percentile, matrix.get_type)
end
