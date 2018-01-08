function [ hist ] = proc_jobs( cfe, hist, ui )
%KEEP_BOOKS Summary of this function goes here
%   Detailed explanation goes here

switch ui.opt_type
   case('PSO')
      % Create a mask for those objectives which are better than previous particle bests.
      obj = hist.obj(:,cfe.iter);
      better_msk = obj < hist.pbo;

      % Set the particle best states to those resulting in such objectives, and save the objectives.
      hist.pbs(:,better_msk) = hist.state(:,better_msk,cfe.iter);
      hist.pbo(better_msk)   = hist.obj(better_msk,cfe.iter);

      % Save the best state yet encountered.
      min_msk = hist.pbo == min(hist.pbo);
      hist.best_state = hist.pbs(:,min_msk);

      %if cfe.multi_node
      %   fmt        = get_fmt(length(better_msk));
      %   prfx       = '/job_';
      %   num_best   = num2str(find(min_msk),fmt);
      %   
      %   pred_name  = ['.' prfx num_best prfx 'pred.mat'];    % Particle Data Filename
      %   stats_name = ['.' prfx num_best prfx 'stats.mat'];  % Particle Data Filename
      %
      %   load(pred_name);
      %   load(stats_name);
      %   vdisp(['particle_' num_best ' (best) pred, stats loaded.'],1,verbose)
      %end

      %if strcmp(ui.model,'ED2.1')
      %   hist.out_best = out;
      %   disp('not sure what to do with stats at line 97 of proc_jobs.')
      %   hist.stats = stats;
      %end
      
   case('NM')
   
   iter  = cfe.iter;
   
   for ismp = 1:ui.nsimp

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
         simp_inds = ((ismp-1)*(nvar+1)+1):(ismp*(nvar+1));
         obj_s = hist.obj(simp_inds,iter);

         hist.smplx(ismp).obj_s(:,snum) = obj_s;
         hist.smplx(ismp).step = 'find_reflection';

      case('eval_reflection')
         obj_r = hist.obj(ismp,iter);
         hist.smplx(ismp).obj_r(snum) = obj_r;

         selector = get_comparison(obj_s,obj_r);                        % Compare verts to reflection
         switch selector
         case('replace_worst') % Reflected point rocks!
            new_smplx = [state(:,1:end-1),pt_r];
            new_obj_s = [obj_s(1:end-1); obj_r];
            
            hist.smplx(ismp).snum = snum + 1;
            hist.smplx(ismp).state(:,:,snum+1) = new_smplx;
            hist.smplx(ismp).obj_s(:,snum+1) = new_obj_s;
            hist.smplx(ismp).step = 'find_reflection';

         case('try_expansion') % Consider expansion
            hist.smplx(ismp).step = 'find_expansion';
         case('try_contraction') % Consider Shrinking or Contracting
            hist.smplx(ismp).step = 'find_contraction';
         end

      case('eval_expansion')
         obj_e = hist.obj(ismp,iter);
         hist.smplx(ismp).obj_e(snum) = obj_e;
         
         new_pt  = get_better(pt_e,pt_r,obj_e,obj_r);          % Put pt_e or pt_r in smplx.
         new_obj = min(obj_e,obj_r);
         state  = [state(:,1:end-1), new_pt];
         obj_s  = [obj_s(1:end-1)  ; new_obj];
         
         hist.smplx(ismp).snum = snum + 1;
         hist.smplx(ismp).state(:,:,snum+1) = state;
         hist.smplx(ismp).obj_s(:,snum+1)   = obj_s;
         
         hist.smplx(ismp).step = 'find_reflection';

      case('eval_contraction')
         obj_c = hist.obj(ismp,iter);
         hist.smplx(ismp).obj_c(snum) = obj_c;
         
         obj_w  = obj_s(end);                                  % Get the "worst" obj in simplex
         choice = shrink_choice(obj_c,obj_w);
         switch choice
         case('shrink')
            state = shrink(state,cfe.bounds,ui.p_shrink);
            
            hist.smplx(ismp).snum = snum + 1;
            hist.smplx(ismp).state(:,:,snum+1) = state;
            hist.smplx(ismp).obj_s(1,snum+1)   = hist.smplx(ismp).obj_s(1,snum);
            
            hist.smplx(ismp).step = 'eval_shrink';

         case('contract')
            new_smplx = [state(:,1:end-1),pt_c];
            new_obj_s = [obj_s(1:end-1); obj_c];
            
            hist.smplx(ismp).snum = snum + 1;
            hist.smplx(ismp).state(:,:,snum+1) = new_smplx;
            hist.smplx(ismp).obj_s(:,snum+1) = new_obj_s;
            hist.smplx(ismp).step = 'find_reflection';
         end
            
      case('eval_shrink')
         hist.smplx(ismp).scnt = hist.smplx(ismp).scnt + 1;
         scnt = hist.smplx(ismp).scnt;
         
         new_vert_obj = hist.obj(ismp,iter);
         hist.smplx(ismp).obj_s(scnt,snum) = new_vert_obj;
            
         if scnt == nvar
            hist.smplx(ismp).scnt = 0;
            hist.smplx(ismp).step = 'find_reflection';
            
         end
      end
      
      if strcmp(hist.smplx(ismp).step,'find_reflection');
         snum  = hist.smplx(ismp).snum;
         state = hist.smplx(ismp).state(:,:,snum);
         obj_s = hist.smplx(ismp).obj_s(:,snum);
         
         [~, order] = sort(obj_s);
         state = state(:,order);
         obj_s = obj_s(order);
         
         hist.smplx(ismp).obj_s(:,snum) = obj_s;
         hist.smplx(ismp).state(:,:,snum) = state;
         
         %snum = snum + 1;
         %hist.smplx(ismp).snum = snum;
      end
      
      if sum(isnan(hist.smplx(ismp).obj_s(:,snum))) == 3
         disp('obj_s is NaNs! pausing in proc_jobs at 225.')
         pause;
      end
      
   end
end

%-------------------------------------------------------------------------------------%

end



function [better_point] = get_better(pt1,pt2,pt1_obj,pt2_obj)
% Returns the better point of pt1, or pt2.
   if pt1_obj < pt2_obj
      better_point = pt1;
   else
      better_point = pt2;
   end
end

function [selector] = get_comparison(sobjs,robj)
% Compare with best and second worst points.

   beats_best      = robj < sobjs(1);
   beats_2nd_worst = robj < sobjs(end-1);

   if ~beats_best && beats_2nd_worst
      selector = 'replace_worst';                                % We'll replace the wrost. 
   elseif beats_best
      selector = 'try_expansion';                                % We'll try expansion
   else
      selector = 'try_contraction';                              % We'll try contraction
   end
end

function [choice] = shrink_choice(obj_c,obj_w)
% Either substitute the contracted point or shrink the simplex.
   if obj_c < obj_w
      choice = 'contract';
   else
      choice = 'shrink';
   end
end

function [smplx] = contract(smplx,pt_c)
   smplx = [smplx(1:end-1,:); pt_c];
end

function [smplx] = shrink(smplx,cnstr,param_s)
% Shrink the simplex, keeping the best point fixed.
for i = 2:size(smplx,2);
   new_pt     = smplx(:,1) + param_s*(smplx(:,i) - smplx(:,1));
   new_pt     = constrain(new_pt,cnstr);
   smplx(:,i) = new_pt;
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
