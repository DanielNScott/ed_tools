function [ result ] = styblinski_tang_fn( coords )
%STYBLINSKI_TANG_FN Summary of this function goes here
%   This fn has a minimum between -39.16617n and -39.16616n at (-2.903534,...,-2.903534), where
%   n is the dimension of the input.

   result = sum(coords.^4 - 16*coords.^2 + 5*coords)/2;

end

