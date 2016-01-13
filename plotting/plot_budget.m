function [ ] = plot_budget( )
%PLOT_BUDGET Summary of this function goes here
%   Detailed explanation goes here

nps = 289;

for patch_num = 1:16
   prfx = 'test_new_c13_budget_state_patch_';
   if patch_num < 10;
      num_str = ['000' num2str(patch_num)];
   else
      num_str = [ '00' num2str(patch_num)];
   end
   fname = [prfx num_str '.txt'];
   
   budget{patch_num} = read_cols_to_flds(fname,'\s+',0,0);
end
   
name_list = {'CO2_STORAGE' ; ...
             'CO2_RESIDUAL'; ...
             'CO2_DSTORAGE'; ...
             'CO2_NEP'     ; ...
             'CO2_DENS_EFF'; ... 
             'CO2_LOSS2ATM'  };

for i = 1:numel(name_list)
   name = name_list{i};
   figure('Name',name)

%    if cflg == 0;
%       plot(1:48,budget.(name)(1:nps))
%    else
%       budget_names = fieldnames(budget);
%       nbudgets     = numel(budget_names);
%       
%       big_budget   = NaN(nbudgets,nps);
%       for budget_num = 1:nbudgets
%          cur_budget = budget.(budget_names{budget_num});
%          big_budget(budget_num,:) = cur_budget.(name)(1:nps)';
%       end

      plot_points = [];
      for patch_num = 1:16
         plot_points = [plot_points, budget{1}.(name)];
      end
      plot(1:nps,plot_points')
%   end
end

end

