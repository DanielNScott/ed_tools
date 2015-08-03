function [ pdf ] = cauchy( pt_curr, pt_prev, temp, dim )
%CAUCHY Summary of this function goes here
%   Detailed explanation goes here

dx    = pt_prev - pt_curr;
denom = (dx^2 + temp^2)^((dim + 1)/2);

pdf = temp / denom;

end

