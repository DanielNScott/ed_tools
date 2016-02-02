function [ hr_data ] = proc_iso_chmbr( show )

filename  = ['C:\Users\Dan\Moorcroft_Lab\data\' ...
             'harvard forest archive\hf-209-iso\HF-Chambers_Final_2012_2013.csv'];
seperator = ',';
fix_flg   = 0;
data      = read_cols_to_flds(filename,seperator,fix_flg);

%----------------------------------------------------------------------------------------------%
% Get start and end dates and create a NaN matrix with entries for every hour between them,
% inclusive of the last.
%----------------------------------------------------------------------------------------------%
beg_str = pack_time(data.YYYY(1)    ,1 ,1 ,1 ,0,0,'std');
end_str = pack_time(data.YYYY(end)+1,1 ,1 ,1 ,0,0,'std');
nhrs    = get_date_index(beg_str,end_str,'hourly') - 1;        % (sr is endpoint inclusive)
nday    = get_date_index(beg_str,end_str,'daily')  - 1;        % (sr is endpoint inclusive)

d13C     = NaN(nday,1);
d13C_err = NaN(nday,1);
% CO2      = NaN(nhrs,1);
% CO2_err  = NaN(nhrs,1);

year     = NaN(nday,1);
month    = NaN(nday,1);
day      = NaN(nday,1);
%hour     = NaN(nhrs,1);
%----------------------------------------------------------------------------------------------%


diel_nobs = zeros(24,1);
day_nobs  = zeros(nday,1);

%----------------------------------------------------------------------------------------------%
% Mask out data flagged as bad.
%----------------------------------------------------------------------------------------------%
data.Del13_KeelingPlot_York_permilVPDB = data.Del13_KeelingPlot_York_permilVPDB(~data.badKP);
data.Del13_KeelingPlot_err_permilVPDB  = data.Del13_KeelingPlot_err_permilVPDB(~data.badKP);

%data.CO2flux_umol_m2_s     = data.CO2flux_umol_m2_s(~data.badCO2);
%data.CO2flux_err_umol_m2_s = data.CO2flux_err_umol_m2_s(~data.badCO2);

data.YYYY = data.YYYY(~data.badKP,:);
data.MO   = data.MO(~data.badKP,:);
data.DD   = data.DD(~data.badKP,:);
data.HH   = data.HH(~data.badKP,:);
%data.MI   = data.MI(~data.badKP,:);
%data.SS   = data.SS(~data.badKP,:);

ndata   = size(data.YYYY,1);
%----------------------------------------------------------------------------------------------%





%----------------------------------------------------------------------------------------------%
% Aggregate data                                                                               %
%----------------------------------------------------------------------------------------------%
agg     = 0;
agg_err = 0;

for idata = 1:ndata
   itime = pack_time(data.YYYY(idata),data.MO(idata),...       % Time of datum
           data.DD(idata),0,0,0,'std');                        % ...
   index = get_date_index(beg_str,itime,'daily')+2;            % Index for datum in 'temp'

   new_day = idata ~=1 && index ~= old_index;                  % Is this a new day?
   if new_day                                                  % If so, save yesterday's data
      d13C(old_index)     = agg    /day_nobs(old_index);
      d13C_err(old_index) = agg_err/day_nobs(old_index);
      
      agg     = 0;
      agg_err = 0;
   end
   
   hour = data.HH(idata) + 1;                                  % Converting from 0-23 -> 1-24
   
   diel_nobs(hour) = diel_nobs(hour) + 1;                      % Increment diel obs counter
   day_nobs(index) = day_nobs(index) + 1;                      % Increment obs-per-day counter
   
   agg     = agg     + data.Del13_KeelingPlot_York_permilVPDB(idata);
   agg_err = agg_err + data.Del13_KeelingPlot_err_permilVPDB(idata);
   
   old_index = index;                                          % Save the index for next loop
end
%----------------------------------------------------------------------------------------------%

%----------------------------------------------------------------------------------------------%
% Create year, month, day, hour fields for times without data.                                 %
%----------------------------------------------------------------------------------------------%
hours = [];
days  = [];
mos   = [];

mo_days = reshape(yrfrac(1:12,2012:2013,'-days')',24,1);
yrs     = [repmat(2012,nhrs/2-12,1); repmat(2013,nhrs/2+12,1)];

for imo = 1:24
   mos   = [mos  ; repmat(mod(imo-1,12)+1,24*mo_days(imo),1)];
   days  = [days ; reshape(repmat(1:mo_days(imo),24,1),mo_days(imo)*24,1)];
   hours = [hours; repmat((0:23)',mo_days(imo),1)];
end

%dates = [yrs,mos,days,hours];
%----------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------%
% Pack data for export.                                                                        %
%----------------------------------------------------------------------------------------------%
%conversion = 10^(-6) * 44.01 * 0.272892524426267 * 10^(-3) * 60 *60 *24 *365;
%CO2     = CO2 *conversion;
%CO2_err = CO2_err *conversion;

%hr_data = [dates, d13C, d13C_err, CO2, CO2_err];
hr_data = [d13C,d13C_err];
%hr_data = [dates, d13C, d13C_err];

if show
   figure();
   set(gcf,'Name','daily means')
   errorbar(1:731,hr_data(:,1),hr_data(:,2),'or')

   figure();
   set(gcf,'Name','number of obs per day')
   plot(1:731,day_nobs,'ob')

   figure();
   set(gcf,'Name','diel histogram')
   bar(1:24,diel_nobs,'m')
end

hr_data(isnan(hr_data)) = -9999;

%----------------------------------------------------------------------------------------------%
end

