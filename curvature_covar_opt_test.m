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
theta  = 2*pi/360;                                       % Angle of each small rotation
rotate = @(x) x * [cos(theta) -sin(theta); ...           % Rotation matrix for transforming
                   sin(theta),cos(theta)];               % ... data in plane.

% Get eigenvecs and eigenvals of covar matrix
[eigenVecs,eigenValMat] = eig(covar);                    % For plotting

% Plot a bunch of things
gen_new_fig('')
for i = 1:360
   vecPDF = mvnpdf(meshMat,mean,covar);                  % Generate the pdf
   matPDF = reshape(vecPDF,length(x2),length(x1));       % Reshape the pdf as matrix

   % Plot 3D PDF
   subaxis(2,2,1)
   surf(axis1Vals,axis2Vals,matPDF,'EdgeColor','k');     % Plot PDF against grid
   xlabel('Axis 1')
   ylabel('Axis 2')
   alpha(0.5)

   % Plot level curves of PDF
   subaxis(2,2,2)
   contour(axis1Vals,axis2Vals,matPDF)
   xlabel('Axis 1')
   ylabel('Axis 2')
   
   % Add scaled eigenvectors to level curve plot
   hold on
   scaledEigenVec1x = [0,eigenVecs(1,1)*eigenValMat(1)];
   scaledEigenVec1y = [0,eigenVecs(2,1)*eigenValMat(1)];
   scaledEigenVec2x = [0,eigenVecs(1,2)*eigenValMat(4)];
   scaledEigenVec2x = [0,eigenVecs(2,2)*eigenValMat(4)];
   
   plot(scaledEigenVec1x,scaledEigenVec1y,'-or')
   plot(scaledEigenVec2x,scaledEigenVec2y,'-or')
   hold off
   
   % Print the eigenvectors of the current PDF
   if i > 1; delete(ah); end
   sx1 = sprintf('% 0.2f',eigenVecs(1,1));
   sx2 = sprintf('% 0.2f',eigenVecs(2,1));
   sy1 = sprintf('% 0.2f',eigenVecs(1,2));
   sy2 = sprintf('% 0.2f',eigenVecs(2,2));
   
   str = {['Eigenvector 1: ' '(' sx1 ',' sy1 ')'], ['Eigenvector 2: ' '(' sx2 ',' sy2 ')']};
   ah = annotation('textbox','String',str, 'FitBoxToText','on','Position',[0.54 0.77 0.1 0.1]);
   drawnow()
   
   % Rotate the eigenvectors and reconstruct rotated covariance matrix.
   eigenVecs = rotate(eigenVecs);
   covar = eigenVecs * eigenValMat * eigenVecs';
end

end

