%QUAT3LABEL label 3 dimensional quaternary phase diagram
%  QUAT3LABEL('ALABEL','BLABEL','CLABEL','DLABEL') labels a 3D quaternary
%  phase diagram created using QUATPLOT3.
%
%  See also QUATPLOT3
%
%  Author: Jacques van der merwe

function quat3label(A,B,C,D)

%%  Declare
xoffset = 0.04;
yoffset = 0.05;

%%  Place the text
text(0.5, sin(deg2rad(60))+yoffset, 0, A, 'HorizontalAlignment', 'center')
text(1+xoffset, 0, 0, B, 'rotation', 60, 'HorizontalAlignment', 'center')
text(0-xoffset, 0, 0, C, 'rotation', -60, 'HorizontalAlignment', 'center')
text(0.5, 0.5*tan(deg2rad(30)), (sin(deg2rad(60)))^2+yoffset, D, 'HorizontalAlignment', 'center')

%%  The degrees to radian function
function rad = deg2rad(deg)
%  This function is used inside the ternplot function and will be used to
%  convert from degrees to radians

%  Calculations
rad = deg / 180 * pi;s