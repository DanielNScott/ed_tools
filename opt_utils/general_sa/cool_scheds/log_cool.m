function [ temp ] = log_cool( temp_start, time_cur, time_ref )
%LOG_COOL Implements the logarithmic cooling shown to be consistent with the boltzmann variant
%of simulated annealing (as opposed to a faster schedule which would imply simulated quelching).

% This is what I had written...
%temp = temp_start * log(time_ref + 1)./log(time_cur + 1);

% But this looks more correct... still need to check...
temp = temp_start - temp_start * log(time_cur + 1)./log(time_ref + 1);


end

