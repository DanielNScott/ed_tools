function [ result ] = rosenbrock( coord )
%ROSENBROCK(coord) Returns an evaluation of the general coupled rosenbrock function.
%   Inputs of size N-by-M are treated as M column vectors of dimension N. Output will be of size
%   1-by-M, being the value on each size N vector.

a = 1;
b = 100;

dim = size(coord,2);

result = 0;
for idim = 1:dim-1
   result = result + (a - coord(:,idim)).^2 + b*(coord(:,idim+1) - coord(:,idim).^2).^2;
end

end

