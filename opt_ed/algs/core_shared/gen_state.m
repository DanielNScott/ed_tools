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
   
   [state,obj]   = reorder_nm_state(state,smplx,obj);
   [state,smplx] = get_comparisons (state,obj,smplx,ui);

   hist.state(:,:,cfe.iter+1) = state;
   
end

if uses_proposals
   loop_count     = 0;
   state_conforms = 0;
   while state_conforms == 0 && loop_count < 1000
      loop_count       = loop_count + 1;
      switch opt_type
         case({'DRAM','SA'})
            % In the case of SA, this is implementing the "get_neighbor" function.
            
            if strcmp(prior_pdf,'gaussian')
               state_prop = normrnd(state, sdevs);

            elseif strcmp(prior_pdf,'uniform')
               % Generate uniform random state in means + [-2*sdevs,2*sdevs]
               rands = rand(numel(state),1);
               rands = rands - 0.5;
               rands = rands .* (2*sdevs);
               state_prop = rands + state;
            end
      end
      state_conforms = get_conformance(state_prop, ui.model);
   end
   hist.state(:,:,cfe.iter+1) = state_prop;
end

end

