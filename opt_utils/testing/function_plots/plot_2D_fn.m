function [ ] = plot_2D_fn(int1,int2,dx,dy,gridtype,fn,edgecolor)
%PLOT_ROSENBROCK_2D Summary of this function goes here
%   p1: Parameter 1 of 2D Rosenbrock fn. denoted 'a', typically 1.
%   p2: Parameter 2 of 2D Rosenbrock fn. denoted 'b', typically 100.
%   int1: Interval of the first coordinate, e.g. [-1,1]
%   int2: Interval of the second coordinate, e.g. [-1,1]
%   dx: Grid res. in 1st coordinate
%   dy: Grid res. in 2nd coordinate
%   gridtype: Sets grid res as increments or numbers thereof.

% Set upper and lower bound aliases.
x0 = int1(1);
xf = int1(2);

y0 = int2(1);
yf = int2(2);

% Interpret dx and dy as actual increments...
if strcmp(gridtype,'incs')
   ndiv_x = (xf - x0)/dx;
   ndiv_y = (yf - y0)/dy;
   
% Or interpret them as the number of increments.
elseif strcmp(gridtype,'nincs')
   ndiv_x = dx;
   ndiv_y = dy;
   dx = (xf - x0)/ndiv_x;
   dy = (yf - y0)/ndiv_y;
end
   
% Compute the rosenbrock function on the grid.
h = zeros(ndiv_x,ndiv_y);
for i = 1:ndiv_x
   pt_x = x0 + i*dx;
   for j = 1:ndiv_y
      pt_y = y0 + j*dy;
      h(i,j) = fn([pt_x;pt_y]);
      
   %  Paraboloid, for testing purposes.
   %  p(i,j) = pt_x^2 + pt_y^2;
   end
end

% Set the axis markers for the surface plot.
x_axis = x0 + (1:ndiv_x)*dx;
y_axis = y0 + (1:ndiv_y)*dy;

% Plot the function.
surf(x_axis,y_axis,h','EdgeColor',edgecolor);
set(gca,'XLim',[x0+dx,xf])
set(gca,'YLim',[y0+dy,yf])
xlabel('X Axis')
ylabel('Y Axis')

% Paraboloid, for testing purposes.
%figure('Name','Paraboloid');
%surface(x_axis,y_axis,p');
%xlabel('X Axis')
%ylabel('Y Axis')

end