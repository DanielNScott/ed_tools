function [ temp ] = geometric_cool( temp_cur, mantissa, exp_mult )
%GEOMETRIC_COOL Implements a geometric cooling schedule.

temp = temp_cur * mantissa ^ (-exp_mult);

end

