function [ ] = pdf_covar_eigenval_toy( )
%CURVATURE_COVAR_OPT_TEST Summary of this function goes here
%   Detailed explanation goes here

% Generate a mesh grid for plotting pdf
axis1Vals = -4:.2:4;                                     % Mesh axis 1 values
axis2Vals = -4:.2:4;                                     % Mesh axis 2 values
[meshVec1,meshVec2] = meshgrid(axis1Vals,axis2Vals);     % Create grid from axis values
meshMat = [meshVec1(:), meshVec2(:)];

% Initialize params for a gaussian pdf
mean  = [0 0];                                           % Mean
covar = [1 0.5; 0.5 1];                                  % Covariance Matrix

% Create plane rotation function
rotate = @(x,theta) x * [cos(theta) -sin(theta); ...     % Rotation matrix for transforming
                         sin(theta),cos(theta)];         % ... data in plane.

% Get eigenvecs and eigenvals of covar matrix
[eigenVecs,eigenValMat] = eig(covar);                    % For plotting

% Set up figure for plotting
figure('Name','PDF and Contour Plot')
fig_pos = get(gcf,'Position');
fig_pos(3) = fig_pos(3)*2;                               % Double the width field
fig_pos(1) = fig_pos(1) - 200;                           % Move the leftmost boorder field left 
fig_pos(3) = fig_pos(3) - 200;                           % Move the rightmost boorder field left
set(gcf,'Position',fig_pos)                              % Actually move the figure

% Plot a bunch of things
for i = 1:360
   % Generate multivariate normal pdf
   vecPDF = mvnpdf(meshMat,mean,covar);                  % Generate the pdf
   ax1Len = length(axis1Vals);                           % 
   ax2Len = length(axis2Vals);                           % 
   matPDF = reshape(vecPDF,ax1Len,ax2Len);               % Reshape the pdf as matrix

   % Plot 3D PDF
   subaxis(1,2,1)
   surf(axis1Vals,axis2Vals,matPDF,'EdgeColor','k');     % Plot PDF against grid
   xlabel('Axis 1')
   ylabel('Axis 2')
   alpha(0.5)

   % Plot level curves of PDF
   subaxis(1,2,2)
   contour(axis1Vals,axis2Vals,matPDF)
   xlabel('Axis 1')
   ylabel('Axis 2')
   
   % Add scaled eigenvectors to level curve plot
   hold on
   scaledEigenVec1x = [0,eigenVecs(1,1)*eigenValMat(1)];
   scaledEigenVec1y = [0,eigenVecs(2,1)*eigenValMat(1)];
   scaledEigenVec2x = [0,eigenVecs(1,2)*eigenValMat(4)];
   scaledEigenVec2y = [0,eigenVecs(2,2)*eigenValMat(4)];
   
   plot(scaledEigenVec1x,scaledEigenVec1y,'-or')
   plot(scaledEigenVec2x,scaledEigenVec2y,'-or')
   hold off
   
   % Print the eigenvectors of the current PDF
   if i > 1; delete(ah); end
   sx1 = sprintf('% 0.2f',eigenVecs(1,1));
   sx2 = sprintf('% 0.2f',eigenVecs(2,1));
   sy1 = sprintf('% 0.2f',eigenVecs(1,2));
   sy2 = sprintf('% 0.2f',eigenVecs(2,2));
   
   str = {'Eigenvector 1: ',['(' sx1 ',' sy1 ')'],'Eigenvector 2: ',['(' sx2 ',' sy2 ')']};
   ah = annotation('textbox','String',str, 'FitBoxToText','on','Position',[0.54 0.69 0.108 0.19]);
   drawnow;
   
   % Rotate the eigenvectors and reconstruct rotated covariance matrix.
   theta     = 2*pi/360;                                       % Angle of each small rotation
   eigenVecs = rotate(eigenVecs,theta);
   covar = eigenVecs * eigenValMat * eigenVecs';
end

n = 5;
figure();
x = 1;
y = 0;
figure();
for i = 1:n
   hold on
   vec = [x,y] * covar;
   x = vec(1);
   y = vec(2);
   quiver(0,0,x,y)
   set(gca,'XLim',[-1,1])
   set(gca,'YLim',[-1,1])
   pause(1)
   vec = [x,y] * covar;
   x = vec(1);
   y = vec(2);
   pause(1)
end   

end

