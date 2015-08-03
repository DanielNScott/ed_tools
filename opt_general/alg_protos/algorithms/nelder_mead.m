function [solution] = nelder_mead(params,smplx,cnstr,f,varargin)
%Nelder_Mead is a recursive implementation of the Nelder-Mead optimization algorithm
%   sol   : Best solution found.
%   params: Used for passing in centroid, reflected, etc points.
%   constr: Constraints on the domains of the coordinate functions of smplx. as ND-by-2 matrix.
%   smplx : Initial simplex. Each point is a row vector.
%   f     :     Function to be minimized.
%
%   If initializing, start with step = 0, count = 0, x = [].
%   Common params are p = [1,2,-1/2,1/2].
%   p(1) = reflection, p(2) = expansion, p(3) = contraction, p(4) = shrink

if nargin == 5
   iter_lim = varargin{1};
else
   iter_lim = 1000;
end

param_r = params(1);
param_e = params(2);
param_c = params(3);
param_s = params(4);

if isempty(cnstr);
    cnstr(1:size(smplx,1),1) = -inf;
    cnstr(1:size(smplx,1),2) = inf;
end

% Order the smplx according to their fn values:
[~, order] = sort(f(smplx));
smplx      = smplx(order,:);
% print_step(0,smplx,f,NaN);                                  % Tell the user what's up

iter = 0;
while iter < iter_lim
   iter = iter + 1;
   
   cent = get_centroid(smplx);
   pt_r = get_reflection(smplx,cent,cnstr,param_r);
    
   selector = get_comparison(smplx,f,pt_r);
   switch selector
      case(1)
         smplx = vertcat(smplx(1:end-1,:),pt_r);
      case(4)
         pt_e  = get_expansion(smplx,cent,cnstr,param_e);
         smplx = sub_better(smplx,f,pt_e,pt_r);
      case(5)
         pt_c  = get_contraction(smplx,cent,cnstr,param_c);
         smplx = shrink_or_not(smplx,f,pt_c,cnstr,param_s);
   end 
   
   [~, order] = sort(f(smplx));                             % Order vertices by fn vals.:
   smplx      = smplx(order,:);                             % ...
   
   %print_step(selector,smplx,f,pt_r);                       % Tell the user what's up
   
end

solution = smplx(1,:);

end






function [smplx] = sub_better(smplx,f,pt1,pt2)
% Substitutes the better of pt1 and pt2 for current worst.
   if f(pt1) < f(pt2)
      smplx = vertcat(smplx(1:end-1,:),pt1);
   else
      smplx = vertcat(smplx(1:end-1,:),pt2);
   end
end

function [cent] = get_centroid(smplx)
% Calculate center of gravity of the points excluding the worst.
% Worst point is last in s_smplx, and centroid is analogue of mean:   
   less_pts  = smplx(1:end-1,:);
   smplx_dim = size(less_pts,1);
   cent      = sum(less_pts,1) / smplx_dim ;
end

function [selector] = get_comparison(smplx,f,pt_r)
% Compare with best and second worst points.

   beats_best      = f(pt_r) < f(smplx(1,:));
   beats_2nd_worst = f(pt_r) < f(smplx(end-1,:));

   if ~beats_best && beats_2nd_worst
      selector = 1;                                % We'll replace the wrost. 
   elseif beats_best
      selector = 4;                                % We'll try expansion
   else
      selector = 5;                                % We'll try contraction
   end
end

function [pt_r] = get_reflection(smplx,cent,cnstr,param_r)
% Compute domain constrained reflected point
   pt_r = cent + param_r*(cent - smplx(end,:));
   pt_r = constrain(pt_r,cnstr);
end

function [pt_e] = get_expansion(smplx,cent,cnstr,param_e)
% Compute domain constrained expanded point
   pt_e = cent + param_e*(cent - smplx(end,:));
   pt_e = constrain(pt_e,cnstr);
end

function [pt_c] = get_contraction(smplx,cent,cnstr,param_c)
% Compute the domain constrained contracted point
   pt_c = cent + param_c*(cent - smplx(end,:));
   pt_c = constrain(pt_c,cnstr);
end

function [smplx] = shrink_or_not(smplx,f,pt_c,cnstr,param_s)
% Either substitute the contracted point or shrink the simplex.
   if f(pt_c) < f(smplx(end,:))
      smplx = vertcat(smplx(1:end-1,:),pt_c);
   else
      % Shrink the simplex, keeping the best point fixed.
      for i = 2:size(smplx,1);
         new_pt     = smplx(1,:) + param_s*(smplx(i,:) - smplx(1,:));
         new_pt     = constrain(new_pt,cnstr);
         smplx(i,:) = new_pt;
      end
   end
end

function [pt] = constrain(pt,c)
% Constrain the current point
   for idim = 1:length(pt)
      if pt(idim) < c(idim,1)
         pt(idim) = c(idim,1);
      elseif pt(idim) > c(idim,2)
         pt(idim) = c(idim,2);
      end
   end
end

function [] = print_step(selector,smplx,f,pt_r)

   msg = 0;
   switch selector
      case(1)
         msg = 'Replace worst w/ pt_r';
      case(4)
         msg = 'Try expansion';
      case(5)
         msg = 'Try contraction';
   end

   disp('----------------------------------------------')
   disp(['selector: ' num2str(selector)])
   disp(['pt_r    : ' num2str(pt_r)])
   disp(['fn(pt_r): ' num2str(f(pt_r))])
   disp('simplex:')
   disp(smplx)
   disp('fn(simplex)')
   disp(f(smplx))
   disp(msg)

end
