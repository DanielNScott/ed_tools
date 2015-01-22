function [ vars_conform ] = get_conformance( prop_state, model )
%GET_CONFORMANCE Summary of this function goes here
%   Detailed explanation goes here

if sum(strcmp(model,{'ED2.1','out.mat','read_dir'}))
   if ~isempty(prop_state(prop_state < 0))
      vars_conform = 0;
   else
      vars_conform = 1;
   end
elseif strcmp(model,'Rosenbrock_2D')
   if abs(prop_state(1)) >= 3 || abs(prop_state(2)) >=3
      vars_conform = 0;
   else
      vars_conform = 1;
   end
end


end

