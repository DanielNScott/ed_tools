function [ ] = plot_param_stars( hist,cfe,opt_type,state_ref,save,fileID)
%PLOT_PARAM_STARS Summary of this function goes here
%   Detailed explanation goes here


labels = cfe.labels(:,1);                                 % Alias the param labels.
nps    = size(hist.state,2);
niter  = size(hist.state,3);

q_msk = strcmp(labels,'q');
if any(q_msk) > 0
   q_flds = labels(q_msk);
   q_flds{1} = 'q_co';
   q_flds{2} = 'q_hw';
   labels(q_msk) = q_flds;
end

labels = char_sub(labels,'_',' ');

init_best_ind   = hist.obj(:,1) == min(hist.obj(:,1));
init_best_ind   = [init_best_ind, zeros(nps,niter-1)];
global_best_ind = hist.obj      == min(hist.obj(:));
best_inds       = or(init_best_ind,global_best_ind);
best_params     = hist.state(:,best_inds);

iteration = floor((find(init_best_ind)-1)/44)+1;
job = mod(find(init_best_ind)-1,44)+1;

if iteration == 1
   smplx_num = floor((job-1)/11)+1;
   job_num2 = mod((job-1),11)+1;
else
   smplx_num = job;
   job_num2  = 1;
end

if strcmp(opt_type,'NM')
   best_params = hist.smplx(smplx_num).state(:,job_num2,iteration);
else
   best_params = hist.best_state;
end

if init_best_ind == global_best_ind
   best_params = [best_params, best_params];
end

lgnd = 'Best';
%if isfield(ui,'state_ref')
   best_params = [state_ref, best_params];
   %labels = {'Ref', labels{:}};
   lgnd = {'Ref','Best'};
%end
% co_param_names = ...
% {'vmfact','q','R_growth fact'}';
% hw_param_names = ...
% {'vmfact','q','stor. turn'}';
% sh_param_names = ...
% {'stom. slope','vm low temp','root turn', 'water cond.',...
% 'resp opt H2O','resp Q10','resp w1', 'resp w2'}';
% 
% co_params = [hist.state_prop(1:3,1)'   ; hist.state_prop(1:3,hist.iter_best)'    ];
% hw_params = [hist.state_prop(4:6,1)'   ; hist.state_prop(4:6,hist.iter_best)'    ];
% sh_params = [hist.state_prop(7:end,1)' ; hist.state_prop(7:end,hist.iter_best)'  ];
% starplot(co_params,co_param_names,'Conifer Parameters' ,save)
% starplot(hw_params,hw_param_names,'Hardwood Parameters',save)
% starplot(sh_params,sh_param_names,'Shared Parameters',save)

starplot(best_params',labels,'Parameter star plot',lgnd,save,fileID);

end

