function [out] = licd( data, time, plot_stats)
%[out] = LICD(data) takes gappy time-series data on a 40-min collection interval and
%interpolates contiguous portions of that data into hourly mean values.
%  Details: This function assumes input has fields Year, Month, Day, Hour. 

%----------------------------------------------------------------------------------------------%
% Get start and end dates and create a NaN matrix with entries for every hour between them,
% inclusive of the last.
%----------------------------------------------------------------------------------------------%
beg_str = pack_time(time.Year(1)    ,1 ,1 ,1 ,0,0,'std');
end_str = pack_time(time.Year(end)+1,1 ,1 ,1 ,0,0,'std');
nhrs    = get_date_index(beg_str,end_str,'hourly') - 1;     % (sr is endpoint inclusive)
ndata   = numel(time.Year);
flds    = fieldnames(data);                                 % List of data field names.

for fld_num = 1:numel(flds)
   out.(flds{fld_num})          = NaN(nhrs,1);
   out.([flds{fld_num} '_std']) = NaN(nhrs,1);
end

%----------------------------------------------------------------------------------------------%
% Interpolate actual data                                                                      %
%----------------------------------------------------------------------------------------------%
for fld_num = 1:numel(flds)
   field = flds{fld_num};
   agg.(field)  = nan(60,1);
   nagg.(field) = 0;
end
   
for idata = 1:ndata
   % Get a string version of the time & indexing for a vector of year-hours
   itime = pack_time(time.Year(idata),time.Month(idata),...
           time.Day(idata),time.Hour(idata),0,0,'std');
   index = get_date_index(beg_str,itime,'hourly')+2;        % Index for datum in 'temp'

   if idata ~= ndata
      same_day = time.Day(idata)  == time.Day(idata+1);     % Next pt is in the same day?
      same_hr  = time.Hour(idata) == time.Hour(idata+1);    % Next pt is in the same hour?
   else
      same_day = 0;
      same_hr  = 0;
   end

   % Update aggregates
   for fld_num = 1:numel(flds)
      field = flds{fld_num};
      nagg.(field) = nagg.(field) + 1;
      agg.(field)(nagg.(field)) = data.(field)(idata);
   end

   if ~(same_day && same_hr)
      for fld_num = 1:numel(flds)
         field = flds{fld_num};

         % Process aggregates
         out.(field)(index)          = nanmean(agg.(field));
         out.([field '_std'])(index) = nanstd(agg.(field));
      
         % Reset aggregators
         nagg.(field) = 0;
         agg.(field)  = nan(60,1);
      end
   end
end
%----------------------------------------------------------------------------------------------%


% Data statistics:
nan_msk = isnan(out.(flds{1}));
non_nan = out.(flds{1})(~nan_msk);

disp(' ')
disp(['Data points in LICD input : ' num2str(ndata) ])
disp(['Data points in LICD output: ' num2str(numel(non_nan)) ])

% Plot hourly distribution of output data:
if plot_stats
   n = histc(time.Min,0:1:60);
   bar(0:1:60,n,'histc')
end


end

