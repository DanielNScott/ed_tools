function [ ] = plot_pred_and_obs( hist,obs,ui,save )
%PLOT_LIKELY_ANALY Summary of this function goes here
%   Detailed explanation goes here

if strcmp(ui.opt_type,'PSO')
   init_best_ind   = hist.obj == min(hist.obj(:,1));
   global_best_ind = hist.obj == min(hist.obj(:));
   best_inds       = or(init_best_ind,global_best_ind);
   iter_best       = find(sum(global_best_ind));
else
   iter_best = hist.iter_best;
end


opt_metadata = ui.opt_metadata;
out = hist.out_best;

row_ind  = 0;

resolutions = fieldnames(obs);                           % What data resolutions exist?
for res_num = 1:numel(resolutions)                       % Cycle through the resolutions

   res     = resolutions{res_num};                       % Set resolution
   fields  = fieldnames(obs.(res));                      % What types of data are there?

   for fld_num = 1:numel(fields)                         % Cycle through fields
      fld = fields{fld_num};                             % Get the current field
      if length(fld) > 2 && strcmp(fld(end-2:end),'_sd') % Ignore uncertainty data headers
         continue
      end
      if iscell(fld)                                     % Ignore data limits descriptors
         continue
      end

      mdr_typ_msk  = strcmp(opt_metadata(:,2),fld);      % Get rows in metadata w/ this type 
      mdr_res_msk  = strcmp(opt_metadata(:,1),res);      % Get rows in metadata w/ this res 
      mdr_msk      = and(mdr_typ_msk,mdr_res_msk);       % Want row with this type and res
      metadata_row = opt_metadata(mdr_msk,:);            % Get the row in opt_metadata

      % Only keep going if output for comparison exists.
      if ~isempty(metadata_row)                          % It's empty if no metadata exists
         type    = metadata_row{3};                      % Get the "type" of data.
         out_fld = metadata_row{4};                      % Get data's field name in output
         rework  = metadata_row{5};                      % See if the data was "re-worked";

         if rework                                       % If so change the path in the out
            out_fld(2) = 'Y';                            % struct to reworked copy under "Y".
         end

         out_data = out.(out_fld(2)).(out_fld(4:end));   % Get output data
         obs_data = obs.proc.(res).(fld);                % Get the observational data
         obs_unc  = obs.proc.(res).([fld '_sd']);        % Get the uncertainty data

         
         [obs_data, obs_unc] ...                         % Make sure sizes are conformant.
            = check_sizes(obs_data,obs_unc,out_data,fld);% If not, leading data trimmed.
         
%          % THIS IS A HACK TO MAKE FIA DATA WORK! %
%          if strcmp(type,'FIA')
%            %obs_data = obs_data(2:end);
%            %obs_unc  = obs_unc (2:end);
%          end
%          % Trim our reworked data.
%          if strcmp(out_fld(2),'Y')
%             switch lower(res)
%             case('yearly')
%                %if strcmp(fld(1:3),'BAG') || strcmp(fld(1:3),'BAM')
%                %   obs_data = obs_data(2:end);
%                %   obs_unc  = obs_unc (2:end);
%                %end
%             case('monthly')
%                obs_data = obs_data(8:end);               % Ignore partial first year.
%                obs_unc  = obs_unc (8:end);               % 
%             case('daily')
%                obs_data = obs_data(215:end);             % Ignore partial first year.
%                obs_unc  = obs_unc (215:end);             % 
%             end
%          end
         
         
         %---------------------------------------------%
         % Set data name and save the x axis title.    %
         %---------------------------------------------%
         datalen = numel(obs_data);
         data_name = {[res ' ' fld]};
         data_name = char_sub(data_name,'_',' ');
         data_name = char_sub(data_name,'.',' ');
         data_name = data_name{1};
         %---------------------------------------------%

         
         %---------------------------------------------%
         % Open a figure and save formatting info.     %
         %---------------------------------------------%
         figure('Name',data_name)
         fig_pos = get(gcf,'Position');
         fig_pos(3) = fig_pos(3)*2;
         set(gcf,'Position',fig_pos)
         
         % Subaxis options
         sp = 0.015; pd = 0.03;
         pt = 0.05;  pb = 0.06;
         ma = 0.03;  mt = 0.03;
         mb = 0.03;
         
         [yrs, mos, ds] = tokenize_time(hist.out_best.nl.start,'ED','num');
         [yrf, mof, df] = tokenize_time(hist.out_best.nl.end  ,'ED','num');
         switch (res)
            case('yearly')
               xlab = 'year';
               xtck = yrs:yrf;
               xtck = xtck(2:end-1);
            case('monthly')
               xlab = 'month';
            case('daily')
               xlab = 'day';
            case('hourly')
               xlab = 'hour';
         end
         %---------------------------------------------%
         
         zero_pad   = zeros(size(obs_unc'));
         bar_unc    = [zero_pad; obs_unc'];
         pdata      = [out_data; obs_data'];
         likely     = hist.stats.likely.(res).(fld)(:,iter_best);
         
         ref_exists = isfield(hist,'out_ref');
         if ref_exists
            ref_data = hist.out_ref.(out_fld(2)).(out_fld(4:end));
            ref_like = hist.stats.ref.likely.(res).(fld);
            
            pdata   = [ref_data; pdata];
            likely  = [ref_like, likely];
            bar_unc = [zero_pad; bar_unc];
         end
         
         likely = -1 *likely;
         

         %---------------------------------------------%
         % Plot predictions, observations, likelihoods %
         %---------------------------------------------%
         if datalen > 200
            marker = '.';
         else
            marker = '-o';
         end
            
         subaxis(2,2,1,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
         if datalen < 4
            barwitherr(bar_unc',pdata')               
            colormap(cool)
         else
            plot(1:datalen,pdata,marker);
         end
         
         title(['\bf{' data_name '}'])
         set(gca,'YGrid','on')
         set(gca,'YMinorGrid','off')
         
         if ref_exists
            legend({'Ref','Best','Obs'})
         else
            legend({'Best','Obs'})
         end
         ylabel(' ')
         xlabel(xlab)
            
         
         % Plot associated (detailed) likelihoods.     %
         subaxis(2,2,2,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
         if datalen < 4
            bar(likely)
         else
            plot(1:datalen,likely,marker)
         end
         
         if ref_exists
            legend({'Ref', 'Best'})
         else
            legend({'Likelihood'})
         end
         title(['\bf{' data_name ' Likelihood}'])
         set(gca,'YGrid','on')
         set(gca,'YMinorGrid','off')
         ylabel('-1 * Log Likelihood')
         xlabel(xlab)
         %---------------------------------------------%
         
         
         if 1
            ns         = numel(obs_data(~isnan(obs_data)));
            likely     = ((obs_data' - out_data)./ obs_unc').^2 * -0.5/ns;
            likely_ref = ((obs_data' - ref_data)./ obs_unc').^2 * -0.5/ns;
            likely = [ -1* likely_ref; -1* likely]';
            
            % Plot associated (detailed) likelihoods.     %
            subaxis(2,2,3,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
            if datalen < 4
               bar(likely)
            else
               plot(1:datalen,likely,marker)
            end
            
         end
         
         
         if save; export_fig( gcf, data_name, '-jpg', '-r150' ); end
      end
   end
end




end



function [obs, unc] = check_sizes(obs,unc,out,fld)
   nobs = numel(obs);
   nout = numel(out);
   if nobs ~= nout
      disp('--------- Warning! --------------')
      disp('numel(obs) ~= numel(out)')
      disp(['Field     : ', fld])
      disp(['numel(obs): ', num2str(nobs)])
      disp(['numel(out): ', num2str(nout)])
      disp('Removing leading portion of nobs.')
      
      new_first_ind = nobs - nout + 1;
      obs = obs(new_first_ind:end);
      unc = unc(new_first_ind:end);
   end
end


