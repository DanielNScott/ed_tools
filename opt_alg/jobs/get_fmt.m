function [ fmt ] = get_fmt( njobs )
%GET_FMT Summary of this function goes here
%   Detailed explanation goes here

ndigits = floor(log10(njobs)) + 1;
fmt = ['%0' num2str(ndigits) 'i'];



end

