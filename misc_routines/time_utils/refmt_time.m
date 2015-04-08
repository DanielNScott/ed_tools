function [ time ] = refmt_time( time, ifmt, ofmt )
%REFMT_TIME Summary of this function goes here
%   Detailed explanation goes here

[y,mo,d,hr,mi,s] = tokenize_time(time,ifmt,'num');
time = pack_time(y,mo,d,hr,mi,s,ofmt);

end

