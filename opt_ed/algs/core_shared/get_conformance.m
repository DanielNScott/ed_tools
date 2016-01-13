function [ vars_conform ] = get_conformance( prop_state, model )
%GET_CONFORMANCE Summary of this function goes here
%   Detailed explanation goes here

if sum(strcmp(model,{'ED2.1','out.mat','read_dir'}))
   if any(prop_state < 0)
      vars_conform = 0;
   else
      vars_conform = 1;
   end
elseif strcmp(model,'Rosenbrock')
   if any(prop_state >= 3) 
      vars_conform = 0;
   else
      vars_conform = 1;
   end
end


end

