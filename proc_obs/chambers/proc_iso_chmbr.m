function [ mc ] = proc_iso_chmbr( )

% Read in the data
fpath = 'C:\Users\Dan\moorcroft_lab\observations\harvard_forest_archives\chamber_iso\proc\';
fname = 'HF-Soil-Resp-d13C.csv';

seperator = ',';
fix_flg   = 0;
raw       = read_cols_to_flds([fpath fname],seperator,1,fix_flg);

% Pre-process the data
time = rmfield(raw,'d13C_control');
data.d13C_Control = raw.d13C_control;
data.d13C_Control(data.d13C_Control == -9999) = NaN;

% Interpolation onto the right grid
data = licd(data,time,0);

% No uncertainty data, so assume single points have uncertainty of 0.5 permil.
data.d13C_Control_std(data.d13C_Control_std == 0) = 0.5;

% Start and end strings for Monte-Carlo resampling.
beg_str = pack_time(2012,1 ,1 ,0,0,0,'std');
end_str = pack_time(2014,1 ,1 ,0,0,0,'std');

% Get resampled data w/ SDs. 
% Note samples aren't forced to be positive, but this is alright for now.
mc = mc_ems_data(data.d13C_Control,data.d13C_Control_std,5000,beg_str,end_str,'normrnd');

% Save hourly data to the same structure.
[nt_op,dt_op] = get_nt_dt_ops([2012,2013]);
mc.hm         = data.d13C_Control;
mc.hs         = data.d13C_Control_std;
mc.hm_day     = data.d13C_Control     .*dt_op;
mc.hs_day     = data.d13C_Control_std .*dt_op;
mc.hm_night   = data.d13C_Control     .*nt_op;
mc.hs_night   = data.d13C_Control_std .*nt_op;


if 0
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

%----------------------------------------------------------------------------------------------%
end

