function [ temp ] = log_cool( temp_start, time_cur, time_ref )
%LOG_COOL Implements the logarithmic cooling shown to be consistent with the boltzmann variante
%of simulated annealing (as opposed to a faster schedule which would imply simulated quelching).

temp = temp_start * log(time_ref + 1)./log(time_cur + 1);

end

