function [ heavy ] = get_C13( total, delta )
%HT2DELTA Returns a delta C13 value wrt PBD, given total C and C13.
%   Detailed explanation goes here

mult = ((delta/1000 + 1.0)*0.011237);
heavy = total .* mult./(1 + mult);

end

