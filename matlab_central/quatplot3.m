%QUATPLOT3 plot 3dimensional phase diagram
%  QUATPLOT3(A,B,C) plots the 3D quaternary phase diagram for four
%  components.  D is calculated as 1 - A - B - C
%
%  QUATPLOT(A,B,C,D) plots the 3D quaternary diagram for the four
%  components.  If the values are not fractions, they will be normalized by
%  dividing by the total.
%
%  QUATPLOT(A,B,C,D,GS) same as above, but uses GS as the grid spacing.  A
%  default value of 0.2 will be assumed if not specified.
%
%  QUATPLOT(A,B,C,D,GS,TRANSPARANCY) same as above, but the TRANSPARANCY of
%  the faces of the plot can be varied.  1 being totally opaque and 0 being
%  totally transparent.  A default value of 0.5 will be assumed if not
%  specified.
%
%  QUATPLOT(A,B,C,D,GS,TRANSPARANCY,LINETYPE) same as above, but with a
%  user specified LINETYPE.
%
%  QUATPLOT(...,'PropertyName','PropertyValue',...) same as above, but sets
%  properties to specified values.
%
%  NOTES
%  - The regular TITLE and LEGEND commands work with the plot from this
%    function, as well as incremental plotting using HOLD.
%  - Labels can be placed on the axes using QUATLABEL.
%
%  See also QUAT3LABEL QUATPLOT QUATLABEL
%
%  Author:  Jacques van der Merwe

function hquat3 = quatplot3(varargin)

%%  Declare inputs
if nargin > 5
    A = varargin{1};
    B = varargin{2};
    C = varargin{3};
    D = varargin{4};
    GridSpace = varargin{5};
    TP = varargin{6};
end

%%  Test inputs
if nargin < 3
    error('Not enough input arguments')
elseif nargin < 4
    D = 1 - A - B - C;
    GridSpace = 0.2;
    TP = 0.5;
elseif nargin < 5
    GridSpace = 0.2;
    TP = 0.5;
elseif nargin < 6
    TP = 0.5;
elseif nargin > 7
    if rem(nargin,2) == 0
        error('Property inputs must be specified in pairs')
    end
end

%%  Normalize fractions
[fA,fB,fC,fD] = NormFrac(A,B,C,D);

%%  Calculate quaternary Coordinates
[x, y, z] = TernCoOrds3D(fA, fB, fD);

%%  Sort data
[x, ind] = sort(x);
y = y(ind);
z = z(ind);

%%  Create the quaternary axes
majors = 1 / GridSpace + 1;
[hold_state, next, cax] = CreateTern3(majors, TP);  %  This will create the quaternary axes

%%  Plot data
if length(varargin)<7
    q = plot3(x,y,z);
elseif length(varargin) == 7
    q = plot3(x,y,z, varargin{7});
elseif length(varargin)>7
    q = plot3(x, y, z, varargin{7:nargin});
end

if nargout > 0
    hquat3 = q;
end

if ~hold_state
    set(gca, 'dataaspectratio', [1 1 1]), axis off
    set(cax, 'NextPlot', next)
end

%%  The Normalization function
function [fA,fB,fC,fD] = NormFrac(A,B,C,D)
%  This function will be used inside the quatplot3 function and will be
%  used to normalize the fractions given by the user

%  Calculations
total = A+B+C+D;
fA = A ./ total;
fB = B ./ total;
fC = C ./ total;
fD = D ./ total;

%%  The Quaternary Coordinate function
function [x, y, z] = TernCoOrds3D(fA, fB, fD)
%  This function will be used inside the quatplot3 function and will be
%  used to calculate the 3D coordinates of the fractions of the various
%  components.

%  Declare
theta = deg2rad(30);

%  Adjustments
t = 0.5*tan(theta);  %  Die teenoorstaande sy
S = sqrt(t.^2 + 0.5^2);  %  Die skuins sy
vS = fD .* S;  %  Verskuifde skuins sy - Is 'n fraksie van die samestelling van komoponent D
vt = vS * sin(theta);  %  Verskuifde teenoorstaande sy
va = vS * cos(theta);  %  Verskuifde aangrensende sy
IncY = vt;  %  Die aanpassing wat gemaak word in die Y rigting
IncX = va;  %  Die aanpassing wat gemaak word in die X rigting

%  Coordinates
y = fA .* sin(deg2rad(60));
x = fB + y .* cot(deg2rad(60));
y = y + IncY;
x = x + IncX;
z = fD .* (sin(deg2rad(60)))^2;

%%  The Quaternary diagram create function
function [cax, hold_state, next] = CreateTern3(majors, TP)
%  This function will be used inside the quatplot3 function and will be
%  used to create the 3D coordinate set for the plot.

%  Offset for labels
xoffset = 0.04;
yoffset = 0.05;

%  Get hold state
cax = newplot;
next = lower(get(cax, 'NextPlot'));
hold_state = ishold;
grid off

%  Get X-Axis color so gridlines is same color
tc = get(cax, 'xcolor');  %  Gets the color of the x axis
ls = get(cax, 'gridlinestyle');  %  Gets the gridlinestyle

%  Get current default text properties
fAngle  = get(cax, 'DefaultTextFontAngle');
fName   = get(cax, 'DefaultTextFontName');
fSize   = get(cax, 'DefaultTextFontSize');
fWeight = get(cax, 'DefaultTextFontWeight');
fUnits  = get(cax, 'DefaultTextUnits');

%  Reset defaults to Axes' font attributes
%  So that the tick marks can use them
set(cax, 'DefaultTextFontAngle',  get(cax, 'FontAngle'), ...
    'DefaultTextFontName',   get(cax, 'FontName'), ...
    'DefaultTextFontSize',   get(cax, 'FontSize'), ...
    'DefaultTextFontWeight', get(cax, 'FontWeight'), ...
    'DefaultTextUnits','data');

%  Draw the diagram
%  Only if hold is off
if ~hold_state
    hold on
    %  Set background color
    if ~ischar(get(cax, 'color'))
        patch('Xdata', [0 1 0.5 0], 'Ydata', [0 0 sin(deg2rad(60)) 0], 'Zdata', [0 0 0 0], 'edgecolor', tc, 'facecolor', get(gca,'color'), 'handlevisibility', 'off', 'FaceAlpha', TP)
        patch('Xdata', [1 0.5 0.5], 'Ydata', [0 0.5*tan(deg2rad(30)) sin(deg2rad(60))], 'Zdata', [0 (sin(deg2rad(60)))^2 0], 'edgecolor', tc, 'facecolor', get(gca,'color'), 'handlevisibility', 'off', 'FaceAlpha', TP)
        patch('Xdata', [0 0.5 0.5], 'Ydata', [0 0.5*tan(deg2rad(30)) sin(deg2rad(60))], 'Zdata', [0 (sin(deg2rad(60)))^2 0], 'edgecolor', tc, 'facecolor', get(gca,'color'), 'handlevisibility', 'off', 'FaceAlpha', TP)
    end
    %  Plot borders
    plot3([0 1 0.5 0], [0 0 sin(deg2rad(60)) 0], [0 0 0 0], 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')  %  Bottom triangle
    plot3([1 0.5 0.5], [0 0.5*tan(deg2rad(30)) sin(deg2rad(60))], [0 (sin(deg2rad(60)))^2 0], 'color', tc, 'linewidth', 1, 'handlevisibility', 'off'), grid on  %  Triangle 4
    plot3([0 0.5 0.5], [0 0.5*tan(deg2rad(30)) sin(deg2rad(60))], [0 (sin(deg2rad(60)))^2 0], 'color', tc, 'linewidth', 1, 'handlevisibility', 'off'), grid on  %  Triangle 3
    set(gca, 'Visible', 'off')
    %  Create labels
    majorticks = linspace(0, 1, majors);
    majorticks = majorticks(1:end-1);
    ticklabels = num2str(majorticks(2:end)'*100);
    %  Plot Triangle 1 labels
    zeroF = zeros(size(majorticks));
    [lx1, ly1, lz1] = TernCoOrds3D(majorticks, zeroF, zeroF);
    text(lx1(2:end), ly1(2:end), lz1(2:end), ticklabels)
    [rx1, ry1, rz1] = TernCoOrds3D(1-majorticks, majorticks, zeroF);
    text(rx1(2:end)-xoffset, ry1(2:end), rz1(2:end), ticklabels)
    [bx1, by1, bz1] = TernCoOrds3D(zeroF, 1-majorticks, zeroF);
    text(bx1(2:end), by1(2:end), bz1(2:end), ticklabels, 'VerticalAlignment', 'top')
    %  Plot Triangle 2 labels
    [lx2, ly2, lz2] = TernCoOrds3D(zeroF, zeroF, majorticks);
    text(lx2(2:end)-xoffset, ly2(2:end), lz2(2:end), ticklabels)
    [rx2, ry2, rz2] = TernCoOrds3D(zeroF, 1-majorticks, majorticks);
    text(rx2(2:end), ry2(2:end), rz2(2:end), ticklabels)
    %  Plot Triangle 3 labels
    [tx3, ty3, tz3] = TernCoOrds3D(1-majorticks, zeroF, majorticks);
    text(tx3(2:end), ty3(2:end)-yoffset, tz3(2:end), ticklabels)
    %  Plot gridlines
    nlabels = length(majorticks)-1;
    for i = 1:nlabels
        %  Triangle 1
        plot3([lx1(i+1) rx1(nlabels-i+2)], [ly1(i+1) ry1(nlabels-i+2)], [0 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        plot3([lx1(i+1) bx1(nlabels-i+2)], [ly1(i+1) by1(nlabels-i+2)], [0 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        plot3([rx1(i+1) bx1(nlabels-i+2)], [ry1(i+1) by1(nlabels-i+2)], [0 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        %  Triangle 2
        plot3([lx2(i+1) rx2(i+1)], [ly2(i+1) ry2(i+1)], [lz2(i+1) rz2(i+1)], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        plot3([lx2(i+1) bx1(nlabels-i+2)], [ly2(i+1) by1(nlabels-i+2)], [lz2(i+1) 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        plot3([rx2(i+1) bx1(i+1)], [ry2(i+1) by1(1+1)], [rz2(i+1) 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        %  Triangle 3
        plot3([lx2(i+1) tx3(i+1)], [ly2(i+1) ty3(i+1)], [lz2(i+1) tz3(i+1)], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        plot3([lx2(i+1) lx1(i+1)], [ly2(i+1) ly1(i+1)], [lz2(i+1) 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        plot3([tx3(i+1) lx1(nlabels-i+2)], [ty3(i+1) ly1(nlabels-i+2)], [tz3(i+1) 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        %  Triangle 4
        plot3([rx2(i+1) tx3(i+1)], [ry2(i+1) ty3(i+1)], [rz2(i+1) tz3(i+1)], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        plot3([rx2(i+1) rx1(nlabels-i+2)], [ry2(i+1) ry1(nlabels-i+2)], [rz2(i+1) 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
        plot3([tx3(i+1) rx1(i+1)], [ty3(i+1) ry1(i+1)], [tz3(i+1) 0], ls, 'color', tc, 'linewidth', 1, 'handlevisibility', 'off')
    end
end

%  Reset defaults
set(cax, 'DefaultTextFontAngle', fAngle , ...
    'DefaultTextFontName',   fName , ...
    'DefaultTextFontSize',   fSize, ...
    'DefaultTextFontWeight', fWeight, ...
    'DefaultTextUnits', fUnits );

%%  The degrees to radian function
function rad = deg2rad(deg)
%  This function is used inside the ternplot function and will be used to
%  convert from degrees to radians

%  Calculations
rad = deg / 180 * pi;