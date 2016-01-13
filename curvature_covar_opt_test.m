function [ ] = curvature_covar_opt_test( )
%CURVATURE_COVAR_OPT_TEST Summary of this function goes here
%   Detailed explanation goes here

close all

mu    = [0 0];                         % Mean
Sigma = [1 0.5;  0.5 1];               % Covariance Matrix

theta = 2*pi/360;
Rmat  = [cos(theta) -sin(theta); sin(theta),cos(theta)];

[V,D] = eig(Sigma);

%A     = [1, 0.5];
%Sigma = A*A';

x1 = -4:.2:4;                          % Mesh axis 1 values
x2 = -4:.2:4;                          % Mesh axis 2 values

[X1,X2] = meshgrid(x1,x2);             % Create grid from axis values
F = mvnpdf([X1(:) X2(:)],mu,Sigma);    % Generate the pdf
F = reshape(F,length(x2),length(x1));  % Reshape the pdf as matrix

gen_new_fig('')

%for i = 1:360
   F = mvnpdf([X1(:) X2(:)],mu,Sigma);    % Generate the pdf
   F = reshape(F,length(x2),length(x1));  % Reshape the pdf as matrix

   subaxis(2,2,1)
   surf(x1,x2,F,'EdgeColor','k');         % Plot PDF against grid
   xlabel('x1')
   ylabel('x2')
   alpha(0.5)

   subaxis(2,2,2)
   contour(x1,x2,F)
   xlabel('x1')
   ylabel('x2')
   
   hold on
   plot([0,V(1,1)*D(1)],[0,V(2,1)*D(1)],'-or')
   plot([0,V(1,2)*D(4)],[0,V(2,2)*D(4)],'-or')
   hold off
   
%   if i > 1
%      delete(ah)
%   end
   sx1 = sprintf('% 0.2f',V(1,1));
   sx2 = sprintf('% 0.2f',V(2,1));
   sy1 = sprintf('% 0.2f',V(1,2));
   sy2 = sprintf('% 0.2f',V(2,2));
   
   str = {['v_1: ' '(' sx1 ',' sy1 ')'], ['v_2: ' '(' sx2 ',' sy2 ')']};
   ah = annotation('textbox','String',str, 'FitBoxToText','on','Position',[0.54 0.77 0.1 0.1]);
   drawnow()
   
   %V = V*Rmat;
   %Sigma = V*D*V';
%end

subaxis(2,2,3)
   pfh = fit([X1(:),X2(:)],F(:),'poly23' );
   surf([X1(:),X2(:)],pfh([X1(:),X2(:)]))
   
%particle_swarm([-2,2; -2,2],40,20,-f)

%caxis([min(F(:))-.5*range(F(:)),max(F(:))]);
%axis([-3 3 -3 3 0 .4])
%xlabel('x1'); ylabel('x2'); zlabel('Probability Density');


end

