function [ hist, state_prop ] = prop_nm( cfe, hist, ui )
%CONFIG_JOBS Summary of this function goes here
%   Detailed explanation goes here

state_prop = [];
for ismp = 1:ui.nsimp
   
   iter  = cfe.iter;
      
   snum  = hist.smplx(ismp).snum;
   obj_r = hist.smplx(ismp).obj_r(snum);
   obj_e = hist.smplx(ismp).obj_e(snum);
   obj_c = hist.smplx(ismp).obj_c(snum);
   
   pt_r  = hist.smplx(ismp).pt_r(:,snum);
   pt_e  = hist.smplx(ismp).pt_e(:,snum);
   pt_c  = hist.smplx(ismp).pt_c(:,snum);

   cent  = hist.smplx(ismp).cent(:,snum);
   obj_s = hist.smplx(ismp).obj_s(:,snum);
   step  = hist.smplx(ismp).step;
   state = hist.smplx(ismp).state(:,:,snum);
   
   nvar  = size(state,1);
   
   switch step
   case('eval_simplex')
      state_prop = [state_prop, state];
   
   case('eval_shrink')
      scnt = hist.smplx(ismp).scnt;
      state_prop = [state_prop, state(:,scnt+2)];

   case('find_reflection')
      cent = get_centroid(state);
      pt_r = get_reflection(state,cent,cfe.bounds,ui.p_reflect);

      hist.smplx(ismp).cent(:,snum) = cent;
      hist.smplx(ismp).pt_r(:,snum) = pt_r';
      hist.smplx(ismp).step = 'eval_reflection';

      state_prop = [state_prop,pt_r];

   case('find_expansion')
      pt_e = get_expansion(state,cent,cfe.bounds,ui.p_expand);

      hist.smplx(ismp).pt_e(:,snum) = pt_e;
      hist.smplx(ismp).step = 'eval_expansion';

      state_prop = [state_prop,pt_e];

   case('find_contraction')
      pt_c = get_contraction(state,cent,cfe.bounds,ui.p_cntrct);

      hist.smplx(ismp).pt_c(:,snum) = pt_c;
      hist.smplx(ismp).step = 'eval_contraction';

      state_prop = [state_prop,pt_c];
   end
end

% Trim state_prop to not include NaNs.
ncol = size(state_prop,2);
col_mask = ones(1,ncol);
for icol = 1:ncol
   if isnan(state_prop(1,icol))
      col_mask(icol) = 0;
   end
end
state_prop = state_prop(:,logical(col_mask));

end


function [cent] = get_centroid(smplx)
% Calculate center of gravity of the points excluding the worst.
% Worst point is last in s_smplx, and centroid is analogue of mean:   
   cent = mean(smplx(:,1:end-1),2);
end

function [pt_r] = get_reflection(smplx,cent,cnstr,param_r)
% Compute domain constrained reflected point
   pt_r = cent + param_r*(cent - smplx(:,end));
   pt_r = constrain(pt_r,cnstr);
end

function [pt_e] = get_expansion(smplx,cent,cnstr,param_e)
% Compute domain constrained expanded point
   pt_e = cent + param_e*(cent - smplx(:,end));
   pt_e = constrain(pt_e,cnstr);
end

function [pt_c] = get_contraction(smplx,cent,cnstr,param_c)
% Compute the domain constrained contracted point
   pt_c = cent + param_c*(cent - smplx(:,end));
   pt_c = constrain(pt_c,cnstr);
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


