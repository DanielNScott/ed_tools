function [] = comp_nee_dset_fits(observations, output, metadata)

cache_fname = 'C:/Users/Dan/moorcroft_lab/data_and_ref_matlab/nee_comparison_cache.mat';
if ~ exist(cache_fname,'file')
   obs_filled_best   = preproc_obs(observations.filled, output.best    , metadata);
   pred_filled_best  = rework_data(obs_filled_best    , output.best    , metadata);
   stats_filled_best = get_stats  (pred_filled_best   , obs_filled_best, metadata);

   obs_filled_ref   = preproc_obs(observations.filled, output.ref    , metadata);
   pred_filled_ref  = rework_data(obs_filled_ref     , output.ref    , metadata);
   stats_filled_ref = get_stats  (pred_filled_ref    , obs_filled_ref, metadata);


   obs_unfilled_best   = preproc_obs(observations.unfilled, output.best      , metadata);
   pred_unfilled_best  = rework_data(obs_unfilled_best    , output.best      , metadata);
   stats_unfilled_best = get_stats  (pred_unfilled_best   , obs_unfilled_best, metadata);

   obs_unfilled_ref   = preproc_obs(observations.unfilled, output.ref      , metadata);
   pred_unfilled_ref  = rework_data(obs_unfilled_ref     , output.ref      , metadata);
   stats_unfilled_ref = get_stats  (pred_unfilled_ref    , obs_unfilled_ref, metadata);

%   obs_hybrid_best   = preproc_obs(observations.hybrid, output.best, metadata);
%   pred_hybrid_best  = rework_data(obs_hybrid_best, output.best, metadata);
%   stats_hybrid_best = get_stats  (output.best, obs_hybrid_best, metadata);

%   obs_hybrid_ref   = preproc_obs(observations.hybrid, output.ref, metadata);
%   pred_hybrid_ref  = rework_data(obs_hybrid_ref, output.ref, metadata);
%   stats_hybrid_ref = get_stats  (output.ref, obs_hybrid_ref, metadata);
   save(cache_fname)
else
   load(cache_fname)
end

rdegs = 15;
figure();

row_ind  = 0;
res_flds = fieldnames(stats_filled_best.likely);

init_likely = [];
init_names = {};
for res_num = 1:numel(res_flds)
   res = res_flds{res_num};
   obs_flds = fieldnames(stats_filled_best.likely.(res));

   for obs_num = 1:numel(obs_flds)
      obs = obs_flds{obs_num};
      
      if numel(obs) < 3 || ~strcmp(obs(1:3),'NEE')
         continue
      end
      
      row_ind = row_ind + 1;
      filled_ref_likely  (row_ind) = -1*nansum(stats_filled_ref.likely.(res).(obs)(:,1));
      %hybrid_ref_likely  (row_ind) = -1*nansum(stats_hybrid_ref.likely.(res).(obs)(:,1));
      unfilled_ref_likely(row_ind) = -1*nansum(stats_unfilled_ref.likely.(res).(obs)(:,1));
      
      filled_best_likely  (row_ind) = -1*nansum(stats_filled_best.likely.(res).(obs)(:,1));
      %hybrid_best_likely  (row_ind) = -1*nansum(stats_hybrid_best.likely.(res).(obs)(:,1));
      unfilled_best_likely(row_ind) = -1*nansum(stats_unfilled_best.likely.(res).(obs)(:,1));
      
      init_names{row_ind} = [res '.' obs];
   end
end

plot_data = [filled_ref_likely; filled_best_likely; ...
             %hybrid_ref_likely; hybrid_best_likely; ...
             unfilled_ref_likely; unfilled_best_likely;];

init_names = char_sub(init_names,'_',' ');
init_names = char_sub(init_names,'.',' ');

n_names = numel(init_names);
bar(plot_data')      
legend({'Filled Ref','Filled Best' ...,'Hybrid Ref','Hybrid Best'
   ,'Unfilled Ref','Unfilled Best'})


%set(gca,'YScale','log')
set(gca,'xtick',1:n_names)
set(gca,'xlim',[0,n_names+1])
set(gca,'XTickLabel',init_names)
rotateXLabels(gca,rdegs)
set(gca,'YGrid','on')
set(gca,'YMinorGrid','off')
ylabel('-1 * Log Likelihood')
title('\bf{Data Likelihoods}')


iter_best = 1;
opt_metadata = metadata;
out     = pred_filled_best;
out_ref = pred_filled_ref;

row_ind  = 0;

resolutions = fieldnames(observations.filled);           % What data resolutions exist?
for res_num = 1:numel(resolutions)                       % Cycle through the resolutions

   res     = resolutions{res_num};                       % Set resolution
   fields  = fieldnames(observations.filled.(res));                      % What types of data are there?

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
         
         if numel(fld) < 3 || ~strcmp(fld(1:3),'NEE')
            continue
         end

         if rework                                       % If so change the path in the out
            out_fld(2) = 'Y';                            % struct to reworked copy under "Y".
         end

         out_data = out.(out_fld(2)).(out_fld(4:end));   % Get output data
         
         obs_filled = obs_filled_best.proc.(res).(fld);                % Get the observational data
         obs_unfill = obs_unfilled_best.proc.(res).(fld);                % Get the observational data
%         obs_hybrid = obs_hybrid_best.proc.(res).(fld);                % Get the observational data
         
         obs_filled_unc  = obs_filled_best.proc.(res).([fld '_sd']);        % Get the uncertainty data
         obs_unfill_unc  = obs_unfilled_best.proc.(res).([fld '_sd']);        % Get the uncertainty data
%         obs_hybrid_unc  = obs_hybrid_best.proc.(res).([fld '_sd']);        % Get the uncertainty data

         
         [obs_filled, obs_filled_unc] ...                         % Make sure sizes are conformant.
            = check_sizes(obs_filled,obs_filled_unc,out_data,fld);% If not, leading data trimmed.
         
%         [obs_hybrid, obs_hybrid_unc] ...                         % Make sure sizes are conformant.
%            = check_sizes(obs_hybrid,obs_hybrid_unc,out_data,fld);% If not, leading data trimmed.
         
         [obs_unfill, obs_unfill_unc] ...                         % Make sure sizes are conformant.
            = check_sizes(obs_unfill,obs_unfill_unc,out_data,fld);% If not, leading data trimmed.
         
         
         %---------------------------------------------%
         % Set data name and save the x axis title.    %
         %---------------------------------------------%
         datalen = numel(obs_filled);
         data_name = {[res ' ' fld]};
         data_name = char_sub(data_name,'_',' ');
         data_name = char_sub(data_name,'.',' ');
         data_name = data_name{1};
         %---------------------------------------------%

         
         %---------------------------------------------%
         % Open a figure and save formatting info.     %
         %---------------------------------------------%
         figure('Name',data_name)
         %fig_pos = get(gcf,'Position');
         fig_pos = [109   177   765   549];
         set(gcf,'Position',fig_pos)
         
         % Subaxis options
         sp = 0.015; pd = 0.03;
         pt = 0.05;  pb = 0.06;
         ma = 0.03;  mt = 0.03;
         mb = 0.03;
         
         [yrs, mos, ds] = tokenize_time(out.sim_beg,'ED','num');
         [yrf, mof, df] = tokenize_time(out.sim_end,'ED','num');
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
         filled_ref = pred_filled_ref.(out_fld(2)).(out_fld(4:end));
         unfill_ref = pred_unfilled_ref.(out_fld(2)).(out_fld(4:end));
%         hybrid_ref = pred_hybrid_ref.(out_fld(2)).(out_fld(4:end));
         
         filled_best = pred_filled_best.(out_fld(2)).(out_fld(4:end));
         unfill_best = pred_unfilled_best.(out_fld(2)).(out_fld(4:end));
%         hybrid_best = pred_hybrid_best.(out_fld(2)).(out_fld(4:end));
         
         ref_likely_filled = stats_filled_ref.likely.(res).(fld);
         ref_likely_unfill = stats_unfilled_ref.likely.(res).(fld);
%         ref_likely_hybrid = stats_hybrid_ref.likely.(res).(fld);
            
         zero_pad   = zeros(size(obs_filled_unc')); 
         bar_unc    = [zero_pad; zero_pad; zero_pad; zero_pad; obs_filled_unc'; obs_unfill_unc'];
         
         best_likely_filled     = stats_filled_best.likely.(res).(fld)(:,iter_best);
         best_likely_unfill     = stats_unfilled_best.likely.(res).(fld)(:,iter_best);
%         best_likely_hybrid     = stats_hybrid_best.likely.(res).(fld)(:,iter_best);

         pdata  = [filled_ref ; filled_best; ...
                   unfill_ref ; unfill_best; ...
                   obs_filled'; obs_unfill'];

         likely = [ref_likely_filled, best_likely_filled, ...
                   ref_likely_unfill, best_likely_unfill];

         likely = -1 *likely;
         

         %---------------------------------------------%
         % Plot predictions, observations, likelihoods %
         %---------------------------------------------%
         if datalen > 200
            marker = '.';
            lstyle = 'none';
            plot_ebar = 0;
         else
            marker = 'o';
            lstyle = '--';
            plot_ebar = 1;
         end
            
         subaxis(2,2,1,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
         plot_stuff(datalen,pdata,bar_unc,marker,lstyle,1,2,5,plot_ebar)
         
         title(['\bf{' data_name '}'])
         set(gca,'YGrid','on')
         set(gca,'YMinorGrid','off')

         legend({'Ref','Best','Filled'})
         ylabel(' ')
         xlabel(xlab)
            
         
         subaxis(2,2,3,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
         plot_stuff(datalen,pdata,bar_unc,marker,lstyle,3,4,6,plot_ebar)
         
         title(['\bf{' data_name '}'])
         set(gca,'YGrid','on')
         set(gca,'YMinorGrid','off')

         legend({'Ref','Best','Unfilled'})
         ylabel(' ')
         xlabel(xlab)
            
         
         % Plot associated (detailed) likelihoods.     %
         subaxis(2,2,2,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
         if datalen < 4
            bar(likely(:,1:2)')
         else
            plot(1:datalen,likely(:,1:2),marker,'LineStyle',lstyle)
         end
         legend({'Filled-Ref', 'Filled-Best'})
         
         title(['\bf{' data_name ' Likelihood}'])
         set(gca,'YGrid','on')
         set(gca,'YMinorGrid','off')
         ylabel('-1 * Log Likelihood')
         xlabel(xlab)
         
         % Plot associated (detailed) likelihoods.     %
         subaxis(2,2,4,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
         if datalen < 4
            bar(likely(:,3:4)')
         else
            plot(1:datalen,likely(:,3:4),marker,'LineStyle',lstyle)
         end
         legend({'Unfilled-Ref', 'Unfilled-Best'})
         
         title(['\bf{' data_name ' Likelihood}'])
         set(gca,'YGrid','on')
         set(gca,'YMinorGrid','off')
         ylabel('-1 * Log Likelihood')
         xlabel(xlab)
         %---------------------------------------------%
         
         
         %if save; export_fig( gcf, data_name, '-jpg', '-r150' ); end
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


function [] = plot_stuff(datalen,pdata,bar_unc,marker,lstyle,ind1,ind2,ind3,plot_ebar)

if datalen < 4
   barwitherr(bar_unc([ind1,ind2,ind3],:)',pdata([ind1,ind2,ind3],:)')
   colormap([0,0,1; 0,0.489,0; 1,0,0])
else
   hold on
   plot(1:datalen,pdata(ind1,:),marker,'LineStyle',lstyle,'Color','b')
   plot(1:datalen,pdata(ind2,:),marker,'LineStyle',lstyle,'Color',[0,0.489,0])
   if plot_ebar
      errorbar(1:datalen,pdata(ind3,:),bar_unc(ind3,:)...
         ,'Marker',marker,'LineStyle',lstyle,'Color','r');
   else
      plot(1:datalen,pdata(ind3,:),marker,'LineStyle',lstyle,'Color','r');
   end
   hold off
end

end


