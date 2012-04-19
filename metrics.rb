#The avaivable distance metrics

def get_metrics()
    return {1 => 'metric_manhattan', 2 => 'metric_euclidean', 3 => 'metric_cosine', 
            4 => 'metric_pearson', 5 => 'metric_jaccard', 6 => 'metric_pearson_jaccard'}
end

def metric_manhattan(u1, u2)
    
    sim = 0.0   
    count = 0

    if u1 == nil or u2 == nil
        return 0.0
    end

    for ix in u1
        for iy in u2
            if ix[0] == iy[0]
                sim += (ix[1] - iy[1]).abs
                count += 1
            end
        end
    end 
    
    if count == 0
        return 0.0
    end

    return 1 - sim
end

def metric_euclidean(u1, u2)

    sim = 0.0
    count = 0

    for ix in u1
        for iy in u2
            if ix[0] == iy[0]
                sim += (ix[1] - iy[1])**2
                count += 1
            end
        end
    end 
    
    if count == 0
        return 0.0
    end

    sim **= 0.5

    return 1 - sim
end

def metric_cosine(u1, u2)

    sim = nu = de1 = de2 = 0.0    
    count = 0

    for ix in u1
        for iy in u2
            if ix[0] == iy[0]
                nu += ix[1]*iy[1]
                de1 += ix[1]**2
                de2 += iy[1]**2    
                count += 1
            end
        end
    end 
    
    if count == 0
        return 0.0
    end

    de1 **= 0.5
    de2 **= 0.5
    sim = nu / (de1 * de2)

    return sim
end

def metric_pearson(u1, u2) 
    
    sim = x_mean = y_mean = nu = de1 = de2 = 0.0    
    count = 0.0

    for ix in u1
        x_mean += ix[1]
        count += 1
    end

    x_mean /= count
    count = 0.0

    for iy in u2
        y_mean += iy[1]
        count += 1
    end

    y_mean /= count
    count = 0

    for ix in u1
        for iy in u2
            if ix[0] == iy[0]
                nu += (ix[1] - x_mean) * (iy[1] - y_mean)
                de1 += (ix[1] - x_mean)**2
                de2 += (iy[1] - y_mean)**2
                count += 1
            end
        end
    end 
    
    if count == 0
        return 0.0
    end

    de1 **= 0.5
    de2 **= 0.5
    sim = nu / (de1 * de2)

    if de1 == 0 or de2 == 0
        return -1.0
    end

    return sim
end

def metric_jaccard(u1, u2)

    sim = count = 0.0

    for ix in u1
        for iy in u2
            if ix[0] == iy[0]
                count += 1
            end
        end
    end 
    
    if count == 0
        return 0.0
    end

    n11 = count
    n10 = u1.length - count
    n01 = u2.length - count

    sim = n11 / (n11 + n10 + n01)

    return sim
end

def metric_pearson_jaccard(u1, u2)

    sim = metric_jaccard(u1, u2) * metric_pearson(u1, u2)    

    return sim
end
