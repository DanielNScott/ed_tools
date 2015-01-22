function [ delta ] = get_d13C( heavy, total )
%HT2DELTA Returns a delta C13 value wrt PBD, given total C and C13.
%   Detailed explanation goes here

delta = ((heavy./(total - heavy))./0.011237 - 1.0).*1000.0;
end

