function [ pdf ] = gauss_markov_pdf( pt_curr, pt_prev, temp, dim )
%GAUSS_MARKOV Summary of this function goes here
%   Detailed explanation goes here

dx  = pt_prev - pt_curr;
pdf = (2*pi*temp)^(-dim/2) * exp(-dx.^2 ./ (2*temp));

end

