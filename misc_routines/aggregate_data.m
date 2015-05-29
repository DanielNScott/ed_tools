function[ agg_dat ] = aggregate_data(data, start_str, end_str, sopt)
%AGGREGATE_DATA(DATA) takes filled hourly data, the time of the first datum, and the time of the
%first hour AFTER the data ends, and aggregates it into many sums or means, depending on "sopt".
%  INPUTS:
%     - DATA - A column vector or matrix of columns of data, filled, with missing values denoted
%       by -9999 values, at hourly resolution.
%     - START_STR - A string in the format 'yyyy-mm-dd-hh-00-00' for time of first datum.
%     - END_STR - As start_str, but for first hour AFTER last datum.
%     - SOPT - Controls the aggregation, as either 'sum' or 'ave'.
%  OUTPUT:
%     - A structure with the following fields:
%        - ymeans        - The mean (or sum) over the year of all data.
%        - mmeans        - The mean (or sum) over each month of data.
%        - qmeans        - The mean (or sum) of the diurnal cycle over each month of data.
%        - dmeans        - The mean (or sum) over each day of data.
%        - dmeans_day    - The mean (or sum) of daytime points over each day of data.
%        - dmeans_night  - The mean (or sum) of night time points over each day of data.
%        - hourly_day    - The hourly data, masked by daylight hours
%        - hourly_night  - The hourly data, masked by nigh time hours

if ~any(strcmp(sopt,{'sum','ave'}))
   error('Input ''sopt'' must be set to ''sum'' or ''ave''.')
end

%----------------------------------------------------------------------------------------------%
% Initialize a bunch of stuff
%----------------------------------------------------------------------------------------------%
time = fill_dates('I',start_str,end_str,'010000','-mat');

if length(time) ~= length(data)
   msg = ['The length of "data" is not compatible with "start_str" and "end_str" ' ...
          'Is the data filled? It should be hourly, with missing vals as -9999.'];
   error(msg)
end

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


%----------------------------------------------------------------------------------------------%
% Initialize means/sums, their corrosponding SDs, fields for gap %, and missing val %
%----------------------------------------------------------------------------------------------%
ymeans       = NaN(nyrs       ,ndcol);
ysdevs       = NaN(nyrs       ,ndcol);
ygaps        = NaN(nyrs       ,ndcol);
ymvals       = NaN(nyrs       ,ndcol);

mmeans       = NaN(nyrs*12    ,ndcol);
msdevs       = NaN(nyrs*12    ,ndcol);
mgaps        = NaN(nyrs*12    ,ndcol);
mmvals       = NaN(nyrs*12    ,ndcol);

qmeans       = NaN(nyrs*12    ,ndcol*24);
qsdevs       = NaN(nyrs*12    ,ndcol*24);
qgaps        = NaN(nyrs*12    ,ndcol*24);
qmvals       = NaN(nyrs*12    ,ndcol*24);

dmeans       = NaN(nyrs*366   ,ndcol);
dsdevs       = NaN(nyrs*366   ,ndcol);
dgaps        = NaN(nyrs*366   ,ndcol);
dmvals       = NaN(nyrs*366   ,ndcol);

dmeans_day   = NaN(nyrs*366   ,ndcol);
dsdevs_day   = NaN(nyrs*366   ,ndcol);
dgaps_day    = NaN(nyrs*366   ,ndcol);
dmvals_day   = NaN(nyrs*366   ,ndcol);

dmeans_night = NaN(nyrs*366   ,ndcol);
dsdevs_night = NaN(nyrs*366   ,ndcol);
dgaps_night  = NaN(nyrs*366   ,ndcol);
dmvals_night = NaN(nyrs*366   ,ndcol);

hourly_day   = NaN(nyrs*366*24,ndcol);
hourly_night = NaN(nyrs*366*24,ndcol);

%----------------------------------------------------------------------------------------------%
% Now start aggregating year/month/daily means.
%----------------------------------------------------------------------------------------------%
mnhrs = get_night_hours(1:12);                     % Define night hours by month

mv_msk = or(data == -9999, isnan(data));           % Create missing value mask
data(mv_msk) = NaN;                                % Standardize missing vals to NaNs

for yr_num = 1:nyrs
   yr     = yr_list(yr_num);
   yr_msk = years == yr;                           % Create a mask for it
   yr_dat = data(yr_msk,:);                        % Mask out this year's data.
   
   yr_agg = agg_data(yr_dat,sopt);                 % Aggregate as mean if req.
   
   ymeans(yr_num,:) = yr_agg.agg;                  % Save
   ysdevs(yr_num,:) = yr_agg.sdev;                 % ...
   ymvals(yr_num,:) = yr_agg.mvals;                % ...
   ygaps(yr_num,:)  = yr_agg.gaps;                 % ...
   
   mo_days = yrfrac(1:12,yr,'-days');              % Get the number of days in each month
   for imo = 1:12
      mo_msk = and(months == imo, yr_msk);         % Create mask for this month of this year
      mo_dat = data(mo_msk,:);                     % Mask out this months data
      
      qdata = reshape(mo_dat,24,mo_days(imo))';    % Refmt data for to preserve diurnal cycle
      
      q_agg = agg_data(qdata,sopt);                % Aggregate
      m_agg = agg_data(mo_dat,sopt);               % ...
      
      qmeans(mcnt,:) = q_agg.agg;                  % Save
      qsdevs(mcnt,:) = q_agg.sdev;                 % ...
      qmvals(mcnt,:) = q_agg.mvals;                % ...
      qgaps(mcnt,:)  = q_agg.gaps;                 % ...
      
      mmeans(mcnt,:) = m_agg.agg;                  % ...
      msdevs(mcnt,:) = m_agg.sdev;                 % ...
      mmvals(mcnt,:) = m_agg.mvals;                % ...
      mgaps(mcnt,:)  = m_agg.gaps;                 % ...
      
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
         
         if length(d_dat) < 24                     % Only possible on first/last day in data
            nt_dat = zeros(24,1);                  % Need placeholders, and zeros => nans
            dt_dat = zeros(24,1);                  % Need placeholders, and zeros => nans.
         else
            nt_dat = d_dat .*nt_op;                % Extract this day's night-time data.
            dt_dat = d_dat .*dt_op;                % Extract this day's day-time data.
         end

         d_agg  = agg_data(d_dat,sopt);            % Total daily sum
         dt_agg = agg_data(dt_dat,sopt);           % Day hour sum   
         nt_agg = agg_data(nt_dat,sopt);           % Night hour sum
         
         dmeans(dcnt,:)       = d_agg.agg;         % Save 
         dsdevs(dcnt,:)       = d_agg.sdev;        % ...
         dmvals(dcnt,:)       = d_agg.mvals;       % ...
         dgaps(dcnt,:)        = d_agg.gaps;        % ...
         
         dmeans_day(dcnt,:)   = dt_agg.agg;        % ...
         dsdevs_day(dcnt,:)   = dt_agg.sdev;       % ...
         dmvals_day(dcnt,:)   = dt_agg.mvals;      % ...
         dgaps_day(dcnt,:)    = dt_agg.gaps;       % ...
         
         dmeans_night(dcnt,:) = nt_agg.agg;        % ...
         dsdevs_night(dcnt,:) = nt_agg.sdev;       % ...
         dsdevs_night(dcnt,:) = nt_agg.mvals;      % ...
         dsdevs_night(dcnt,:) = nt_agg.gaps;       % ...
         
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
dsdevs_night = dsdevs_night(1:dcnt-1,:);
dmvals_night = dmvals_night(1:dcnt-1,:);
dgaps_night  = dgaps_night(1:dcnt-1,:);

hourly_day   = hourly_day(1:hind-1,:);
dmeans_day   = dmeans_day(1:dcnt-1,:);
dsdevs_day   = dsdevs_day(1:dcnt-1,:);
dmvals_day   = dmvals_day(1:dcnt-1,:);
dgaps_day    = dgaps_day(1:dcnt-1,:);

dmeans = dmeans(1:dcnt-1,:);
dsdevs = dsdevs(1:dcnt-1,:);
dmvals = dmvals(1:dcnt-1,:);
dgaps  = dgaps(1:dcnt-1,:);

mmeans = mmeans(1:mcnt-1,:);
msdevs = msdevs(1:mcnt-1,:);
mmvals = mmvals(1:mcnt-1,:);
mgaps  = mgaps(1:mcnt-1,:);

% Package in structure for output
agg_dat.ymeans       = ymeans;
agg_dat.mmeans       = mmeans;
agg_dat.qmeans       = qmeans;
agg_dat.dmeans       = dmeans;
agg_dat.dmeans_day   = dmeans_day;
agg_dat.dmeans_night = dmeans_night;
agg_dat.hourly_day   = hourly_day;
agg_dat.hourly_night = hourly_night;

agg_dat.ysdevs       = ysdevs;
agg_dat.msdevs       = msdevs;
agg_dat.qsdevs       = qsdevs;
agg_dat.dsdevs       = dsdevs;
agg_dat.dsdevs_day   = dsdevs_day;
agg_dat.dsdevs_night = dsdevs_night;

% Turn zeros (from nansum) back into NaNs
fields = fieldnames(agg_dat);
for ifldnum = 1:numel(fields)
   ifld = fields{ifldnum};
   agg_dat.(ifld)(agg_dat.(ifld) == 0) = NaN;
end

% Finish packing...
agg_dat.ymvals       = ymvals;
agg_dat.mmvals       = mmvals;
agg_dat.qmvals       = qmvals;
agg_dat.dmvals       = dmvals;
agg_dat.dmvals_day   = dmvals_day;
agg_dat.dmvals_night = dmvals_night;

agg_dat.ygaps       = ygaps;
agg_dat.mgaps       = mgaps;
agg_dat.qgaps       = qgaps;
agg_dat.dgaps       = dgaps;
agg_dat.dgaps_day   = dgaps_day;
agg_dat.dgaps_night = dgaps_night;

end


function [out] = agg_data(data,type)
% This function is a wrapper for nansum / nanmean depending on selection by "type."

   nans = isnan(data);
   ndat = length(data);
   out.mvals = sum(nans)/ndat;
   
   if strcmp(type,'sum')
      out.agg  = nansum(data);
      out.sdev = nanstd(data)*sqrt(length(data(~nans)));
   else
      out.agg  = nanmean(data);
      out.sdev = nanstd(data);
   end
   
   not_nans = find(~isnan(data));
   if numel(not_nans) == 0
      out.gaps = 1;
   else
      interior_data = data(not_nans(1):not_nans(end));
      interior_nans = isnan(interior_data);
      out.gaps  = sum(interior_nans)/length(interior_data);
   end
   
end

