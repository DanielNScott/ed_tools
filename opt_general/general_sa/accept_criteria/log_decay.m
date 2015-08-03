function [ result ] = log_decay( temp, temp_max )
%LOG_DECAY Returns a value from a log decaying function.
%   result = (2- log10(100*(temp_max - temp)/temp_max))/2;

result = (2- log10(100*(temp_max - temp)/temp_max))/2;

end

