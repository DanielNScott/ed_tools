function [ vector ] = sym2vec( symmetric )
%COV2VEC Summary of this function goes here
%   Detailed explanation goes here

    n = size(symmetric,1);
    vector = NaN((n*(n+1))/2,1);

    k = 1;
    for i = 1:n
       for j = i:n
           vector(k) = symmetric(i,j);
           k = k+1;
       end
    end

end

