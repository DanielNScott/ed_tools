function [ result ] = boltzmann( temp, obj_cur, obj_prop )
%BOLTZMANN Returns a value from the boltzmann distribution w/ temperature "temp."
%   result = exp(-(obj_prop - obj_cur)/temp);

result = exp(-(obj_prop - obj_cur)./temp);

end