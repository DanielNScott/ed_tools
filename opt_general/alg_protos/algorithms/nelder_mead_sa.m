function [solution,trace,iter] = nelder_mead_sa(params,smplx,cnstr,f,temp_fn,term_val,varargin)
%Nelder_Mead is just like nelder_mead but with upfront simplex function evaluation (the
%difference is in code design, and should result in a logically identical algorithm)
%   sol   : Best solution found.
%   params: Used for passing in centroid, reflected, etc points.
%   constr: Constraints on the domains of the coordinate functions of smplx. as ND-by-2 matrix.
%   smplx : Initial simplex. Each point is a row vector.
%   f     : Function to be minimized.
%
%   If initializing, start with step = 0, count = 0, x = [].
%   Common params are p = [1,2,-1/2,1/2].
%   p(1) = reflection, p(2) = expansion, p(3) = contraction, p(4) = shrink

dbug = 1;

if nargin == 7
   iter_lim = varargin{1};
else
   iter_lim = 1000;
end

trace = struct();
trace.states     = nan(iter_lim,size(smplx,2));
trace.objectives = nan(iter_lim,1);

param_r = params(1);
param_e = params(2);
param_c = params(3);
param_s = params(4);

if isempty(cnstr);
    cnstr(1:size(smplx,1),1) = -inf;
    cnstr(1:size(smplx,1),2) = inf;
end

iter = 0;
obj_best = inf;
while iter < iter_lim
   iter = iter + 1;

   temp  = temp_fn(iter);%,iter_lim);                        % Get the current temperature.
   
   obj_s = f(smplx,temp,1);                                  % Get objective vals of vertices.
   obj_a = f(smplx,0,1);                                     % Get actual objective vals also.

   [~, order] = sort(obj_s);                                 % Get the low -> high order of inds
   smplx      = smplx(order,:);                              % Reorder vertices
   obj_s      = obj_s(order);                                % Reorder associated objectives.
   
   [~, order] = sort(obj_a);                                 % Get the low -> high order of inds
   smplx_a    = smplx(order,:);                              % Reorder vertices
   obj_a      = obj_a(order,:);                              % Reorder associated objectives.
   
   if obj_a(1) < obj_best
      obj_best   = obj_a(1);
      state_best = smplx_a(1,:);
   end
   
   if obj_best < term_val
      continue;
   end
   
   trace.states(iter,:)   = smplx(1,:);
   trace.objectives(iter) = obj_a(1);
   
   cent = get_centroid(smplx);
   pt_r = get_reflection(smplx,cent,cnstr,param_r);
   
   obj_r = f(pt_r,temp,-1);                                 % Objective val. of reflected pt.
   
   selector = get_comparison(obj_s,obj_r);                  % Compare vertices to reflected pt.
   switch selector
   case(1) % Reflected point rocks!
      smplx = vertcat(smplx(1:end-1,:),pt_r);

   case(4) % Consider expansion
      pt_e  = get_expansion(smplx,cent,cnstr,param_e);      % Get the expanded point
      obj_e = f(pt_e,temp,-1);                              % Evaluate the obj. there.
      smplx(end,:) = get_better(pt_e,pt_r,obj_e,obj_r);     % Put the better of e/r in smplx.

   case(5) % Consider Shrinking or Contracting
      pt_c  = get_contraction(smplx,cent,cnstr,param_c);
      obj_c = f(pt_c,temp,-1);                              % Get the obj. of contracted pt.
      obj_w = obj_s(end);                                   % Get the "worst" obj in simplex

      choice = shrink_choice(obj_c,obj_w);
      switch choice
      case('shrink')
         smplx = shrink(smplx,cnstr,param_s);
      case('contract')
         smplx = contract(smplx,pt_c);
      end
   end 
   
   %print_step(selector,smplx,f,pt_r);                       % Tell the user what's up
end

obj_s = f(smplx,0,1);                                       % Get objective vals of vertices.

[~, order] = sort(obj_s);                                   % Get the low -> high order of inds
smplx      = smplx(order,:);                                % Reorder vertices
obj_s      = obj_s(order);                                  % Reorder associated objectives.

if obj_s(1) < obj_best
   solution = smplx(1,:);
else
   solution = state_best;
end

end






function [better_point] = get_better(pt1,pt2,pt1_obj,pt2_obj)
% Returns the better point of pt1, or pt2.
   if pt1_obj < pt2_obj
      better_point = pt1;
   else
      better_point = pt2;
   end
end

function [cent] = get_centroid(smplx)
% Calculate center of gravity of the points excluding the worst.
% Worst point is last in s_smplx, and centroid is analogue of mean:   
   less_pts  = smplx(1:end-1,:);
   smplx_dim = size(less_pts,1);
   cent      = sum(less_pts,1) / smplx_dim ;
end

function [selector] = get_comparison(sobjs,robj)
% Compare with best and second worst points.

   beats_best      = robj < sobjs(1);
   beats_2nd_worst = robj < sobjs(end-1);

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

function [cmnd] = shrink_choice(obj_c,obj_w)
% Either substitute the contracted point or shrink the simplex.
   if obj_c < obj_w
      cmnd = 'contract';
   else
      cmnd = 'shrink';
   end
end

function [smplx] = shrink(smplx,cnstr,param_s)
% Shrink the simplex, keeping the best point fixed.
for i = 2:size(smplx,1);
   new_pt     = smplx(1,:) + param_s*(smplx(i,:) - smplx(1,:));
   new_pt     = constrain(new_pt,cnstr);
   smplx(i,:) = new_pt;
end
end

function [smplx] = contract(smplx,pt_c)
   smplx = [smplx(1:end-1,:); pt_c];
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
