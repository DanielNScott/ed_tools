function [ result ] = metropolis( temp, obj_cur, obj_prop )
%METROPOLIS_ACCEPTANCE Summary of this function goes here
%   Detailed explanation goes here

if obj_prop < obj_cur
   result = 1;
else
   result = boltzmann(temp,obj_cur,obj_prop);
end

end

