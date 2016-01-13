function [ res ] = get_simres( opt_metadata )
%GET_SIMRES Returns a structure of logicals representing the resolution of this simulation.
%   Outputs 'res' with fields 'fast', 'daily', 'monthly', and 'yearly'

   res.fast    = any(strcmp(opt_metadata(:,1),'hourly'));
   res.daily   = any(strcmp(opt_metadata(:,1),'daily'));
   res.monthly = any(strcmp(opt_metadata(:,1),'monthly'));
   res.yearly  = any(strcmp(opt_metadata(:,1),'yearly'));

end

