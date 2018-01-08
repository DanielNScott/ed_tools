function [ hist ] = gen_state( cfe, hist, ui )
%GEN_STATE Summary of this function goes here
%   Detailed explanation goes here

if strcmp(ui.opt_type,'PSO')
   state = hist.state(:,:,cfe.iter);
   vels  = hist.vels (:,:,cfe.iter);
   
   [state,vels] = update_pso_state(state,vels,cfe.vel_max,cfe.chi,ui.phi_1,ui.phi_2 ...
                                  ,hist.pbs,hist.pbo,cfe.nbrhd,cfe.nvar);

   hist.state(:,:,cfe.iter+1) = state;
   hist.vels (:,:,cfe.iter+1) = vels;
                               
elseif strcmp(ui.opt_type,'NM')
   state = hist.state(:,:,cfe.iter);
   obj   = hist.obj  (:,:,cfe.iter);
   smplx = extract_smplx(cfe,state);
   
   [state, obj]   = reorder_nm_state(state,smplx,obj);
   [state, smplx] = get_comparisons (state,obj,smplx,ui);

   hist.state(:,:,cfe.iter+1) = state;
   
end

end

