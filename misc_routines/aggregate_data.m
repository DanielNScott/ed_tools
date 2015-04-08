function[ agg_dat ] = aggregate_data(data, start_str, end_str)
%AGGREGATE_DATA(DATA) takes hourly data and the time of the first point then aggregates it to
%daily, daily-night-time, daily-day-time, monthly, and yearly means. It also outputs hourly data
%masked to night and day hours.
%  Note: The hourly data should not include time columns.

%----------------------------------------------------------------------------------------------%
% Initialize a bunch of stuff
%----------------------------------------------------------------------------------------------%
time = fill_dates('I',start_str,end_str,'010000','-mat');

years  = time(:,1);
months = time(:,2);
days   = time(:,3);
hours  = time(:,4);

yr_list = unique(years);
nyrs    = numel(yr_list);

ndcol  = size(data,2);

mcnt = 1;
dcnt = 1;
hind = 1;

ymeans       = NaN(nyrs       ,ndcol);
mmeans       = NaN(nyrs*12    ,ndcol);
dmeans       = NaN(nyrs*366   ,ndcol);
dmeans_day   = NaN(nyrs*366   ,ndcol);
dmeans_night = NaN(nyrs*366   ,ndcol);
hourly_day   = NaN(nyrs*366*24,ndcol);
hourly_night = NaN(nyrs*366*24,ndcol);

mnhrs = get_night_hours(1:12);
%----------------------------------------------------------------------------------------------%
% Now start aggregating year/month/daily means.
%----------------------------------------------------------------------------------------------%
mv_msk = or(data == -9999, isnan(data));           % Create missing value mask
data(mv_msk) = NaN;                                % Standardize missing vals to NaNs

for yr_num = 1:nyrs
   yr     = yr_list(yr_num);
   yr_msk = years == yr;                           % Create a mask for it
   yr_dat = data(yr_msk,:);                        % Mask out this year's data.

   ymean = nansum(yr_dat);                         % Aggregate
   ymeans(yr_num,:) = ymean;                       % Save
   
   mo_days = yrfrac(1:12,yr,'-days');              % Get the number of days in each month
   for imo = 1:12
      mo_msk = and(months == imo, yr_msk);         % Create mask for this month of this year
      mo_dat = data(mo_msk,:);                     % Mask out this months data
      
      mmean = nansum(mo_dat);                      % Aggregate
      mmeans(mcnt,:) = mmean;                      % Save
      mcnt = mcnt + 1;                             % Increment counter
      
      mo_nt_msk  = mnhrs(imo,:)';                  % Create a mask for this month's night hours
      mo_nt_msk  = double(mo_nt_msk);              % convert it to double so we can turn it
                                                   % into a multiplicative unary operator.
                                                   
      nt_op = mo_nt_msk;                           % Init. night data selecting mult. unary op.
      dt_op = mo_nt_msk;                           % Init. day data selecting mult. unary op.
                                                   
      nt_op(mo_nt_msk == 0) = NaN;                 % Make transform for day hour data -> NaNs
      dt_op(mo_nt_msk == 1) = NaN;                 % Make transform for night hour data -> NaNs
      dt_op(mo_nt_msk == 0) = 1;                   % Make the latter keep daytime data...
      
      nt_op = repmat(nt_op,1,ndcol);               % Give transforms appropriate # of columns.
      dt_op = repmat(dt_op,1,ndcol);
      
      for id = 1:mo_days(imo)
         d_msk = and(days == id, mo_msk);          % Create mask for this day         
         d_dat = data(d_msk,:);                    % Extract this day's data,
         nt_dat = d_dat .*nt_op;                   % Extract this day's night-time data.
         dt_dat = d_dat .*dt_op;                   % Extract this day's day-time data.
         
         dmeans(dcnt,:)       = nansum(d_dat);     % Sum to get total daily flux
         dmeans_day(dcnt,:)   = nansum(dt_dat);    % Sum to get total day time flux   
         dmeans_night(dcnt,:) = nansum(nt_dat);    % Sum to get total night time flux
         
         hourly_day  (hind:hind+23,:) = dt_dat;    % Save masked hourly day time data
         hourly_night(hind:hind+23,:) = nt_dat;    % Save masked hourly night time data
         
         dcnt = dcnt + 1;                          % Increment counter
         hind = hind + 24;                         % Update hour index
      end
   end
end

%----------------------------------------------------------------------------------------------%
% Aggregating is done, finalize output.
%----------------------------------------------------------------------------------------------%
% Trim the matrices to actual data size. dcnt and hind are the indexes of the first element that
% would be inserted if we had one more day, so we take everything before those indices.
hourly_night = hourly_night(1:hind-1,:);
dmeans_night = dmeans_night(1:dcnt-1,:);

hourly_day   = hourly_day(1:hind-1,:);
dmeans_day   = dmeans_day(1:dcnt-1,:);

dmeans = dmeans(1:dcnt-1,:);
mmeans = mmeans(1:mcnt-1,:);

% Turn zeros (from nansum) back into NaNs
ymeans(ymeans == 0) = NaN;
mmeans(mmeans == 0) = NaN;
dmeans(dmeans == 0) = NaN;

% Package in structure for output
agg_dat.ymeans       = ymeans;
agg_dat.mmeans       = mmeans;
agg_dat.dmeans       = dmeans;
agg_dat.dmeans_day   = dmeans_day;
agg_dat.dmeans_night = dmeans_night;
agg_dat.hourly_day   = hourly_day;
agg_dat.hourly_night = hourly_night;

end
