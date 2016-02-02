function [mc] = proc_chambers(varargin)
%PROC_CHAMBERS Summary of this function goes here
%   Detailed explanation goes here

seperate = 0;

% Either read the file specified below or accept the data as an argument.
if nargin == 0
   filepath  = 'C:\Users\Dan\moorcroft_lab\observations\harvard_forest_archives\chamber\proc\inputs\';
   filename  = [filepath, '2012_2013_soil_resp_data.csv'];
   seperator = ',';
   
   % Heads up, raw gets altered/overwritten.
   raw   = readtext(filename,seperator);
   nhead = 2;
   head  = raw(1:2,:);
   raw   = raw(3:end,:);
   
   % The CSV should look like this:
   %Yr	Mo	Day	Hr	Min	Chamber	CO2_flux    Treatment
   %2012 5	19    18 56    8        264.15      C
   %...
   save('proc_chambers_raw.mat')
   
else
   head  = varargin{1};
   raw   = varargin{2};
   nhead = 2;
end

% Clean data:
nrows   = size(raw,1);
rem_msk = zeros(nrows,1);
for irow = 1:nrows
   % First check cell isn't empty, which messes up logicals.
   empty = isempty(raw{irow,6}) ...
        || isempty(raw{irow,7}) ...
        || isempty(raw{irow,8});
   
   if empty
      rem_msk(irow) = 1;
      %disp(['Removing: ' raw(irow,:)])
      continue;
   end
   
   % Remove non-numerics and mask out treatment, i.e. trenched plots.
   bad = ischar(raw{irow,6}) ...
      || ischar(raw{irow,7}) ...
      || ischar(raw{irow,8});

   % Codes translated in file from C,PT,T -> 0,1,2.
   unwanted = raw{irow,8} == 2;
   
   if bad || unwanted
      rem_msk(irow) = 1;
      %disp(['Removing: ' raw(irow,:)])
   end
   
end
raw = raw(~rem_msk,:);

% Say how much got removed:
disp(['Data points total   : ' num2str(nrows)])
disp(['Data points removed : ' num2str(sum(rem_msk))])
disp(['As fraction of total: ' num2str(sum(rem_msk)/nrows)])

% Create primary data structures: Fields with vectors of data-point attributes.
data  = struct();
flds  = {'Year','Month','Day','Hour','Min','Chamber','CO2_flux'};
nflds = numel(flds);
for fld_num = 1:nflds
   fld = flds{fld_num};
   if fld_num <= 5;
      time.(fld) = cell2mat(raw(:,fld_num));
   else
      data.(fld) = cell2mat(raw(:,fld_num));
   end
end

% Now we do two seperate analysis: treating all chambers as measurements of the same thing, and
% treating each chamber as it's own time-series...
if seperate
   for ch_num = 1:max(data.Chamber);
      ch_msk{ch_num} = data.Chamber == ch_num;

      for fld_num = 1:5
         fld = flds{fld_num};
         sep_time{ch_num}.(fld) = time.(fld)(ch_msk{ch_num});
      end

      for fld_num = 7
         fld = flds{fld_num};
         sep_data{ch_num}.(fld) = data.(fld)(ch_msk{ch_num});      
         if isempty(sep_data{ch_num}.(fld)); continue; end
         sep_agg{ch_num}  = licd(sep_data{ch_num},sep_time{ch_num},1);
      end
   end

   figure;
   plot(1:8784,[sep_agg{1}.CO2_flux'; ...
                sep_agg{3}.CO2_flux'; ...
                sep_agg{5}.CO2_flux'; ...
                sep_agg{7}.CO2_flux'; ...
        ],'.')
   
   figure;
   plot(1:8784,[sep_agg{2}.CO2_flux'; ...
                sep_agg{4}.CO2_flux'; ...
                sep_agg{6}.CO2_flux'; ...
                sep_agg{8}.CO2_flux'; ...
        ],'.')
end

% Linearly interpolate the contiguous portions of the data:
data = licd(data,time,1);
save('proc_chambers_proc.mat')

% Set the SD for single data-point-hours to the mean SD.
data.CO2_flux_std(data.CO2_flux_std == 0) = nanmean(data.CO2_flux_std(data.CO2_flux_std ~= 0));

% Convert units from mg/m2/hr to kg/m2/yr.
conversion        = (1/10^6) * 8760;
data.CO2_flux     = data.CO2_flux     * conversion;
data.CO2_flux_std = data.CO2_flux_std * conversion;

% Start and end strings for Monte-Carlo resampling.
beg_str = pack_time(2012,1 ,1 ,0,0,0,'std');
end_str = pack_time(2014,1 ,1 ,0,0,0,'std');

% Get resampled data w/ SDs. 
% Note samples aren't forced to be positive, but this is alright for now.
mc = mc_ems_data(data.CO2_flux,data.CO2_flux_std,5000,beg_str,end_str,'normrnd');

% Save hourly data to the same structure.
[nt_op,dt_op] = get_nt_dt_ops([2012,2013]);
mc.hm         = data.CO2_flux;
mc.hs         = data.CO2_flux_std;
mc.hm_day     = data.CO2_flux     .*dt_op;
mc.hs_day     = data.CO2_flux_std .*dt_op;
mc.hm_night   = data.CO2_flux     .*nt_op;
mc.hs_night   = data.CO2_flux_std .*nt_op;

end

% 
% %----------------------------------------------------------------------------------------------%
% % Create year, month, day, hour fields for times without data.                                 %
% %----------------------------------------------------------------------------------------------%
% hours = [];
% days  = [];
% mos   = [];
% 
% mo_days = reshape(yrfrac(1:12,2012,'-days')',12,1);
% yrs     = repmat(2012,nday*24,1);
% 
% for imo = 1:12
%    mos   = [mos  ; repmat(mod(imo-1,12)+1,24*mo_days(imo),1)];
%    days  = [days ; reshape(repmat(1:mo_days(imo),24,1),mo_days(imo)*24,1)];
%    hours = [hours; repmat((0:23)',mo_days(imo),1)];
% end
% 
% dates = [yrs,mos,days,hours];
% %----------------------------------------------------------------------------------------------%
% 
% 
% %----------------------------------------------------------------------------------------------%
% % Pack data for export.                                                                        %
% %----------------------------------------------------------------------------------------------%
% hr_data = [dates,CO2,CO2_err];
% 
% % if show
% %    figure();
% %    set(gcf,'Name','daily means')
% %    errorbar(1:731,dy_data(:,4),dy_data(:,5),'or')
% % 
% %    figure();
% %    set(gcf,'Name','number of obs per day')
% %    plot(1:731,day_nobs,'ob')
% % 
% %    figure();
% %    set(gcf,'Name','diel histogram')
% %    bar(1:24,diel_nobs,'m')
% % end
% 
% hr_data(isnan(hr_data)) = -9999;
% %----------------------------------------------------------------------------------------------%
% 
% %----------------------------------------------------------------------------------------------%
% % Export Data                                                                                  %
% %----------------------------------------------------------------------------------------------%
% header_line_1 = ['"# Soil Respiration [umol/m^2/s]"\n'];
% 
% header_line_2 = ['Year, Month, Day, Hour, Soil_Resp, Soil_Resp_sd \n'];
%               
% fid = fopen('chmbr_flux.csv','wt');
% fprintf(fid,header_line_1);
% fprintf(fid,header_line_2);
% dlmwrite('chmbr_flux.csv',hr_data,'delimiter',',','-append');
% fclose(fid);
% %----------------------------------------------------------------------------------------------%
