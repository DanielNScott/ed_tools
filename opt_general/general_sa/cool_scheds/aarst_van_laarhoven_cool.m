function [ temp_new ] = aarst_van_laarhoven_cool( temp_cur, delta, sigma )
%AARST_VAN_LAARHOVEN Adjusts temperature after Aarst and Van Laarhoven '85
%   Inputs:
%     temp_cur: Current temperature
%        delta: Rate parameter ( delta < 1 => slow) (delta > 1 => fast)
%        sigma: Standard deviation of all cost configurations at the current temp.

denom    = 1 + (temp_cur*log(1+delta)/(3*sigma));
temp_new = temp_cur/denom;

end

