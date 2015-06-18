function [ ] = repack_kathleen_data(varargin)
%REPACK_KATHLEEN_DATA Summary of this function goes here
%   Detailed explanation goes here

if nargin == 0
   filepath  = 'C:\Users\Dan\moorcroft_lab\data\harvard forest archive\rick_kathleen_ds_modified\';
   filename  = [filepath, 'kathleen_2012.csv'];
   seperator = ',';

   raw  = readtext(filename,seperator);
else
   raw = varargin{1};
end

data  = struct();
nflds = size(raw,2);
ndata = size(raw,1);

data.YYYY = NaN(ndata,1);
data.MO   = NaN(ndata,1);
data.DD   = NaN(ndata,1);
data.HH   = NaN(ndata,1);
data.MI   = NaN(ndata,1);

crap_msk = zeros(ndata,1);
for idata = 2:ndata
   
   if ischar(raw{idata,4})
      crap_msk(idata) = 1;
      %disp(raw(idata,:))
      continue;
   end

end

disp(['crap_msk sum: ' num2str(sum(crap_msk))])
raw = raw(~crap_msk,:);

for fld_num = 3:nflds
   fld = raw{1,fld_num};
   data.(fld) = cell2mat(raw(2:end,fld_num));
end


%----------------------------------------------------------------------------------------------%
% Get start and end dates and create a NaN matrix with entries for every hour between them,
% inclusive of the last.
%----------------------------------------------------------------------------------------------%
beg_str = pack_time(2012,1 ,1 ,1 ,0,0,'std');
end_str = pack_time(2013,1 ,1 ,1 ,0,0,'std');
nhrs    = get_date_index(beg_str,end_str,'hourly') - 1;        % (sr is endpoint inclusive)
nday    = get_date_index(beg_str,end_str,'daily')  - 1;        % (sr is endpoint inclusive)

CO2      = NaN(nhrs,8);
CO2_err  = NaN(nhrs,8);

sdev     = NaN(nhrs,8);

sdev_all = NaN(nhrs,1);
CO2_all  = NaN(nhrs,1);

hr_nobs  = zeros(nhrs,8);
hr_obs   = NaN(2,8);

% year      = NaN(nday,1);
% month     = NaN(nday,1);
% day       = NaN(nday,1);
% hour      = NaN(nhrs,1);

% no_dat    = data.Del13_Control == -9999;
% 
% data.Del13_Control = data.Del13_Control(~no_dat);
% data.YYYY = data.YYYY(~no_dat);
% data.MO   = data.MO(~no_dat);
% data.DD   = data.DD(~no_dat);

% diel_nobs = zeros(24,1);
% day_nobs  = zeros(nday,1);
ndata     = size(raw,1)-1;
%----------------------------------------------------------------------------------------------%





%----------------------------------------------------------------------------------------------%
% Aggregate data                                                                               %
%----------------------------------------------------------------------------------------------%
agg     = zeros(1,8);
old_index = 1;
for idata = 1:ndata
   [yr,mo,day,~,~,~] = datevec(raw{idata+1,1});                % idata + 1 because raw still
                                                               % has headers
   time_str  = raw{idata+1,2};
   tsep_inds = findstr(':',time_str);
   hr = str2double(time_str(1:tsep_inds(1)-1));
   %mi = time_str(tsep_inds(1)+1:tsep_inds(2)-1);
   
   itime = pack_time(yr,mo,day,hr,0,0,'std');                  % ...
   index = get_date_index(beg_str,itime,'hourly')+1;           % Index for datum in 'temp'

   new_time = idata ~=1 && index ~= old_index;                 % Is this a new day?
   if new_time                                                 % If so, save yesterday's data
      CO2(old_index,:)     = agg ./hr_nobs(old_index,:);
      %CO2_err(old_index,:) = agg ./hr_nobs(old_index,:) * 0.10;
      sdev(old_index,:)    = nanstd(hr_obs);
      
      sdev_all(old_index) = nanstd(hr_obs(:));
      CO2_all(old_index)  = nanmean(hr_obs(:)); 
      
      hr_obs  = NaN(2,8);
      agg     = zeros(1,8);
   end
   
   ch_num          = data.Chamber_id(idata);
   
   hr_nobs(index,ch_num) = hr_nobs(index,ch_num) + 1;          % Increment obs-per-day counter

   hr_obs(hr_nobs(index,ch_num),ch_num) = data.CO2_flux(idata);
   
   agg(ch_num) = agg(ch_num) + data.CO2_flux(idata);
   
   old_index = index;                                          % Save the index for next loop
end

%----------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------%
% Create year, month, day, hour fields for times without data.                                 %
%----------------------------------------------------------------------------------------------%
hours = [];
days  = [];
mos   = [];

mo_days = reshape(yrfrac(1:12,2012,'-days')',12,1);
yrs     = repmat(2012,nday*24,1);

for imo = 1:12
   mos   = [mos  ; repmat(mod(imo-1,12)+1,24*mo_days(imo),1)];
   days  = [days ; reshape(repmat(1:mo_days(imo),24,1),mo_days(imo)*24,1)];
   hours = [hours; repmat((0:23)',mo_days(imo),1)];
end

dates = [yrs,mos,days,hours];
%----------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------%
% Pack data for export.                                                                        %
%----------------------------------------------------------------------------------------------%
hr_data = [dates,CO2,CO2_err];

% if show
%    figure();
%    set(gcf,'Name','daily means')
%    errorbar(1:731,dy_data(:,4),dy_data(:,5),'or')
% 
%    figure();
%    set(gcf,'Name','number of obs per day')
%    plot(1:731,day_nobs,'ob')
% 
%    figure();
%    set(gcf,'Name','diel histogram')
%    bar(1:24,diel_nobs,'m')
% end

hr_data(isnan(hr_data)) = -9999;
%----------------------------------------------------------------------------------------------%

%----------------------------------------------------------------------------------------------%
% Export Data                                                                                  %
%----------------------------------------------------------------------------------------------%
header_line_1 = ['"# Soil Respiration [umol/m^2/s]"\n'];

header_line_2 = ['Year, Month, Day, Hour, Soil_Resp, Soil_Resp_sd \n'];
              
fid = fopen('chmbr_flux.csv','wt');
fprintf(fid,header_line_1);
fprintf(fid,header_line_2);
dlmwrite('chmbr_flux.csv',hr_data,'delimiter',',','-append');
fclose(fid);
%----------------------------------------------------------------------------------------------%

end

