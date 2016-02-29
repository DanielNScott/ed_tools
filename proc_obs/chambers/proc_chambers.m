function [mc] = proc_chambers(seperate,varargin)
%PROC_CHAMBERS Summary of this function goes here
%   Detailed explanation goes here

% Either read the file specified below or accept the data as an argument.
if nargin == 1
   filepath  = 'C:\Users\Dan\moorcroft_lab\observations\harvard_forest_archives\chamber\proc\inputs\';
   filename  = [filepath, '2012_2013_soil_resp_data.csv'];
   seperator = ',';
   
   % Heads up, raw gets altered/overwritten.
   raw   = readtext(filename,seperator);
   raw   = raw(3:end,:);
   
   % The CSV should look like this:
   %Yr	Mo	Day	Hr	Min	Chamber	CO2_flux    Treatment
   %2012 5	19    18 56    8        264.15      C
   %...
   save('proc_chambers_raw.mat')
else
   raw   = varargin{1};
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
         
         if any(ch_num == [1,3,5,7])
            sep_agg{ch_num} = licd(sep_data{ch_num},sep_time{ch_num},1);
            sep_agg{ch_num}.CO2_flux     = [sep_agg{ch_num}.CO2_flux    ; NaN(8760,1)];
            sep_agg{ch_num}.CO2_flux_std = [sep_agg{ch_num}.CO2_flux_std; NaN(8760,1)];
         else
            sep_agg{ch_num}  = licd(sep_data{ch_num},sep_time{ch_num},1);
         end
      end

      tmp{ch_num} = convert_and_resample(sep_agg{ch_num},2012,2014);
   end
   
   mc = struct();
   mc = replace_vals('hs'      ,'hm'      ,tmp,mc);
   mc = replace_vals('hs_day'  ,'hm_day'  ,tmp,mc);
   mc = replace_vals('hs_night','hm_night',tmp,mc);
   mc = replace_vals('ds'      ,'dm'      ,tmp,mc);
   mc = replace_vals('ds_day'  ,'dm_day'  ,tmp,mc);
   mc = replace_vals('ds_night','dm_night',tmp,mc);
   mc = replace_vals('ms'      ,'mm'      ,tmp,mc);
   mc = replace_vals('ms_day'  ,'mm_day'  ,tmp,mc);
   mc = replace_vals('ms_night','mm_night',tmp,mc);
   mc = replace_vals('ys'      ,'ym'      ,tmp,mc);
   mc = replace_vals('ys_day'  ,'ym_day'  ,tmp,mc);
   mc = replace_vals('ys_night','ym_night',tmp,mc);

%    mc.dm = nanmean([tmp{1}.dm, tmp{2}.dm, tmp{3}.dm, tmp{4}.dm ...
%                    ,tmp{5}.dm, tmp{6}.dm, tmp{7}.dm, tmp{8}.dm],2);
%    mc.ds = nanstd ([tmp{1}.dm, tmp{2}.dm, tmp{3}.dm, tmp{4}.dm ...
%                    ,tmp{5}.dm, tmp{6}.dm, tmp{7}.dm, tmp{8}.dm],0,2);
% 
%    mc.mm = nanmean([tmp{1}.mm, tmp{2}.mm, tmp{3}.mm, tmp{4}.mm ...
%                    ,tmp{5}.mm, tmp{6}.mm, tmp{7}.mm, tmp{8}.mm],2);
%    mc.ms = nanstd ([tmp{1}.mm, tmp{2}.mm, tmp{3}.mm, tmp{4}.mm ...
%                    ,tmp{5}.mm, tmp{6}.mm, tmp{7}.mm, tmp{8}.mm],0,2);
% 
%    mc.ym = nanmean([tmp{1}.ym, tmp{2}.ym, tmp{3}.ym, tmp{4}.ym ...
%                    ,tmp{5}.ym, tmp{6}.ym, tmp{7}.ym, tmp{8}.ym],2);
%    mc.ys = nanstd ([tmp{1}.ym, tmp{2}.ym, tmp{3}.ym, tmp{4}.ym ...
%                    ,tmp{5}.ym, tmp{6}.ym, tmp{7}.ym, tmp{8}.ym],0,2);

   %dlen = numel(sep_agg{1}.CO2_flux);
   %figure;
   %plot(1:dlen,[sep_agg{1}.CO2_flux'; ...
   %             sep_agg{2}.CO2_flux'; ...
   %             sep_agg{3}.CO2_flux'; ...
   %             sep_agg{4}.CO2_flux'; ...
   %             sep_agg{5}.CO2_flux'; ...
   %             sep_agg{6}.CO2_flux'; ...
   %             sep_agg{7}.CO2_flux'; ...
   %             sep_agg{8}.CO2_flux'; ...
   %     ],'.')
   
%    data = rmfield(data,'Chamber');
%    for ich = 1:8
%       valname = ['Ch' num2str(ich) '_CO2_flux'];
%       stdname = ['Ch' num2str(ich) '_CO2_flux_std'];
%       if any(ich == [1,3,5,7])
%          data.(valname) = [NaN(8784,1); sep_agg{ich}.CO2_flux];
%          data.(stdname) = [NaN(8784,1); sep_agg{ich}.CO2_flux_std];
%       else
%          data.(valname) = sep_agg{ich}.CO2_flux;
%          data.(stdname) = sep_agg{ich}.CO2_flux_std;
%       end
%    end
   
else
   % Linearly interpolate the contiguous portions of the data:
   data = licd(data,time,1);
   data = rmfield(data,'Chamber');
   mc = convert_and_resample(data,2012,2014);
end


end


function [mc] = replace_vals(sfield,mfield,tmp,mc)

   mc.(mfield) = nanmean([tmp{1}.(mfield), tmp{2}.(mfield), tmp{3}.(mfield), tmp{4}.(mfield) ...
                         ,tmp{5}.(mfield), tmp{6}.(mfield), tmp{7}.(mfield), tmp{8}.(mfield)],2);
                
   mc.(sfield) = nanstd ([tmp{1}.(mfield), tmp{2}.(mfield), tmp{3}.(mfield), tmp{4}.(mfield) ...
                         ,tmp{5}.(mfield), tmp{6}.(mfield), tmp{7}.(mfield), tmp{8}.(mfield)],0,2);

   perc_rep = sum(mc.(sfield)(mc.(sfield) == 0))/numel(mc.(sfield))*100;
   mean_val = nanmean(mc.(sfield)(mc.(sfield) ~= 0));
   mc.(sfield)(mc.(sfield) == 0) = mean_val;
   disp(['Mean value of SDs: ', num2str(mean_val)])
   disp(['Number replaced  : ', num2str(perc_rep)])
   disp(' ')

end

function [mc] = convert_and_resample(data,beg_yr,end_yr)

   % Set the SD for single data-point-hours to the mean SD.
   data.CO2_flux_std(data.CO2_flux_std == 0) = nanmean(data.CO2_flux_std(data.CO2_flux_std ~= 0));

   % Convert units from mg/m2/hr to kg/m2/yr.
   conversion        = (1/10^6) * 8760;
   data.CO2_flux     = data.CO2_flux     * conversion;
   data.CO2_flux_std = data.CO2_flux_std * conversion;

   % Start and end strings for Monte-Carlo resampling.
   beg_str = pack_time(beg_yr  ,1 ,1 ,0,0,0,'std');
   end_str = pack_time(end_yr,1 ,1 ,0,0,0,'std');

   % Get resampled data w/ SDs. 
   % Note samples aren't forced to be positive, but this is alright for now.
   mc = mc_ems_data(data.CO2_flux,data.CO2_flux_std,5000,beg_str,end_str,'normrnd');

   % Save hourly data to the same structure.
   [nt_op,dt_op] = get_nt_dt_ops(beg_yr:(end_yr-1));
   mc.hm         = data.CO2_flux;
   mc.hs         = data.CO2_flux_std;
   mc.hm_day     = data.CO2_flux     .*dt_op;
   mc.hs_day     = data.CO2_flux_std .*dt_op;
   mc.hm_night   = data.CO2_flux     .*nt_op;
   mc.hs_night   = data.CO2_flux_std .*nt_op;

end
