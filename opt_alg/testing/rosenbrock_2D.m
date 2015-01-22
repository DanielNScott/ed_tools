function [ output ] = rosenbrock_2D( x1, x2, varargin )
%ROSENBROCK_2D(x1,x2,[p1],[p2]) Returns an evaluation of the 2D rosenbrock function.
%   Returns output = (p1 - x1)^2 + p2*(x2 - x1^2)^2;

a = 1;
b = 100;

% Override a and b if they are input.
if nargin == 3;
   a = varargin{1};
end
if nargin == 4;
   b = varargin{2};
end
if nargin >= 5
   error('Too many inputs!')
end

output = (a - x1)^2 + b*(x2 - x1^2)^2;

end

