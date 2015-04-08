function [ temp ] = get_temp( cool_sched, temp_start, iter, niter, mantissa, exp_mult )
%GET_TEMP Summary of this function goes here
%   Detailed explanation goes here

%------------------------------------------------------------------------------------------%
% Simulated Annealing temperature functions. 
%------------------------------------------------------------------------------------------%
if strcmp(cool_sched,'Geometric')
   % Geometric decrease in temp.
   temp = temp_start* mantissa ^ (-iter/niter * exp_mult);
   
elseif strcmp(cool_sched,'Linear')
   % Linear decrease in temp from start to 0.
   temp = (niter - iter + 1)/niter * temp_start;
   
elseif strcmp(cool_sched,'Logarithmic')
   % Log, not sure this is implemented properly at the moment.
   temp = temp_start/log(iter + 2);
   
end

end

