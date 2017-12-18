function [ symmetric ] = vec2sym( vector )
%VEC2COV Summary of this function goes here
%   Detailed explanation goes here
    n = ceil(sqrt(length(vector)*2)) - 1;
    symmetric = NaN(n);
    
    k = 1;
    for i = 1:n
       for j = i:n
           symmetric(i,j) = vector(k);
           symmetric(j,i) = vector(k);
           k = k+1;
       end
    end

end

