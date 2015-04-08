function [ result ] = rosenbrock_fn( coord )
%ROSENBROCK(coord) Returns an evaluation of the general coupled rosenbrock function.
%   Just read the function for more detail.

a = 1;
b = 100;

dim = size(coord,2);

result = 0;
for idim = 1:dim-1
   result = result + (a - coord(:,idim)).^2 + b*(coord(:,idim+1) - coord(:,idim).^2).^2;
end

end

