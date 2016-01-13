function [ ] = plot_met( met_dat, met_aggs, met_cols )
%PLOT_MET Summary of this function goes here
%   Detailed explanation goes here

exceptions = {'lon', 'lat'};

iplt = 0;
gen_new_fig('Raw Met Forcing');
nplts = numel(met_dat.info.vars) - 2;
for var_num = 1:nplts + 2;
   ivar = met_dat.info.vars{var_num};
   if any(strcmp(ivar,exceptions)); continue; end

   iplt = iplt + 1;
   subaxis(cieling(nplts/2),2,iplt,'S',0.015,'P',0.015,'M',0.03,'PB',0.03)
      plot(met_dat.(ivar))
      
      set(gca,'XLim',[0,length(met_dat.(ivar))+1]);
      data_min = min(met_dat.(ivar));
      data_max = max(met_dat.(ivar));
      data_rng = data_max - data_min;
      
      yupper = data_max + data_rng*0.05;
      ylower = data_min - data_rng*0.05;
      
      set(gca,'YLim',[ylower, yupper])
      
      title(['\bf{' met_dat.info.real_names{var_num} '}'])
      ylabel(['[', met_dat.info.units{var_num}, ']'],'Interpreter','None')
end

% gen_new_fig('Daily-Aggregated Met Forcing');
% nplts = size(met_aggs.dmeans,2);
% iplt  = 0;
% for var_num = 1:nplts;
%    
%    iplt = iplt + 1;
%    subaxis(nplts/2,2,iplt,'S',0.015,'P',0.015,'M',0.03,'PB',0.03)
%       
%       cur_data = met_aggs.dmeans(:,iplt);
%       plot(cur_data)
%    
%       set(gca,'XLim',[0,length(cur_data)+1]);
%       data_min = min(cur_data);
%       data_max = max(cur_data);
%       data_rng = data_max - data_min;
%       
%       yupper = data_max + data_rng*0.05;
%       ylower = data_min - data_rng*0.05;
%       
%       set(gca,'YLim',[ylower, yupper])
%       
%       title(['\bf{' met_cols{iplt} '}'])
%       %ylabel(['[', met_dat.info.units{var_num}, ']'],'Interpreter','None')
% end


gen_new_fig('Day and Night Mean Met Forcings');
nplts = size(met_aggs.dmeans_day,2);
iplt  = 0;
for var_num = 1:nplts;
   
   iplt = iplt + 1;
   subaxis(nplts/2,2,iplt,'S',0.015,'P',0.015,'M',0.03,'PB',0.03)
      
      day_data   = met_aggs.dmeans_day(:,iplt);
      night_data = met_aggs.dmeans_night(:,iplt);
      
      hold on;
      plot(day_data,'b')
      plot(night_data,'g')
      hold off
   
      set(gca,'XLim',[0,length(day_data)+1]);
      data_min = min(day_data);
      data_max = max(day_data);
      data_rng = data_max - data_min;
      
      yupper = data_max + data_rng*0.05;
      ylower = data_min - data_rng*0.05;
      
      set(gca,'YLim',[ylower, yupper])
      
      title(['\bf{' met_cols{iplt} '}'])
      %ylabel(['[', met_dat.info.units{var_num}, ']'],'Interpreter','None')
end


gen_new_fig('Day and Night Hourly Met Forcings');
nplts = size(met_aggs.dmeans_day,2);
iplt  = 0;
for var_num = 1:nplts;
   
   iplt = iplt + 1;
   subaxis(nplts/2,2,iplt,'S',0.015,'P',0.015,'M',0.03,'PB',0.03)
      
      day_data   = met_aggs.hourly_day(:,iplt);
      night_data = met_aggs.hourly_night(:,iplt);
      
      hold on;
      plot(day_data,'b')
      plot(night_data,'g')
      hold off
   
      set(gca,'XLim',[0,length(day_data)+1]);
      data_min = min(day_data);
      data_max = max(day_data);
      data_rng = data_max - data_min;
      
      yupper = data_max + data_rng*0.05;
      ylower = data_min - data_rng*0.05;
      
      set(gca,'YLim',[ylower, yupper])
      
      title(['\bf{' met_cols{iplt} '}'])
      %ylabel(['[', met_dat.info.units{var_num}, ']'],'Interpreter','None')
end

% 
% gen_new_fig('Night Time Mean Met Forcing');
% nplts = size(met_aggs.dmeans_night,2);
% iplt  = 0;
% for var_num = 1:nplts;
%    
%    iplt = iplt + 1;
%    subaxis(nplts/2,2,iplt,'S',0.015,'P',0.015,'M',0.03,'PB',0.03)
%       
%       cur_data = met_aggs.dmeans_night(:,iplt);
%       plot(cur_data)
%    
%       set(gca,'XLim',[0,length(cur_data)+1]);
%       data_min = min(cur_data);
%       data_max = max(cur_data);
%       data_rng = data_max - data_min;
%       
%       yupper = data_max + data_rng*0.05;
%       ylower = data_min - data_rng*0.05;
%       
%       set(gca,'YLim',[ylower, yupper])
%       
%       title(['\bf{' met_cols{iplt} '}'])
%       %ylabel(['[', met_dat.info.units{var_num}, ']'],'Interpreter','None')
% end


end


function [answer] = cieling(num)

answer = -floor(-num);

end