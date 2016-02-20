function [mc] = proc_iso_eddy(varargin)
% This script reads some tower data and produces a file with that data and gaps filled with
% -9999 indicator values.

% Either read the file specified below or accept the data as an argument.
if nargin == 0
   % Read in the data
   fpath = 'C:\Users\Dan\moorcroft_lab\observations\harvard_forest_archives\hf-209-iso\proc\';
   fname = 'HF-FluxesEtc-QCpassed-safe-chars-min-no-units-2011-2012.csv';

   seperator = ',';
   fix_flg   = 0;
   nhead     = 0;
   raw       = read_cols_to_flds([fpath fname],seperator,nhead,0);
   
   % The CSV should look like this:
   %Yr	Mo	Day	Hr	Min	Field ...   Field
   %2012 5	19    18 56    value ...   value
   %...
   save('proc_iso_eddy_raw.mat')
else
   raw = varargin{1};
end

% Pre-process the data
tflds = {'Year','Month','Day','Hour','Min'};
[proc, times] = split_struct(raw,tflds);
proc = struct_valswap(proc,-9999,NaN);

% Interpolation onto the right grid
proc = licd(proc,times,0);

% Compute NEE and delta values from components
%proc.EddyFlux(abs(proc.EddyFlux) <= prctile(abs(proc.EddyFlux),1)) = NaN;
%proc.StorFlux(abs(proc.StorFlux) <= prctile(abs(proc.StorFlux),1)) = NaN;

Flux_d13C = proc.EddyIsoflux13 ./ proc.EddyFlux;
Stor_d13C = proc.StorIsoflux13 ./ proc.StorFlux;

Flux_C13 = get_C13(proc.EddyFlux,Flux_d13C);
Stor_C13 = get_C13(proc.StorFlux,Stor_d13C);

NEE     = proc.EddyFlux + proc.StorFlux;
NEE_C13 = Flux_C13      + Stor_C13;

% This removes ~0.75% of the data, with a total contribution pf 0.14% of absolute flux...
data.NEE_d13C     = get_d13C(NEE_C13,NEE);
data.NEE_d13C_std = 0.21495 + 14.204* abs(NEE).^(-0.95502);

msk = or(data.NEE_d13C >= 200,data.NEE_d13C <= -200);
data.NEE_d13C(msk) = NaN;
data.NEE_d13C_std(isnan(data.NEE_d13C)) = NaN;

% Start and end strings for Monte-Carlo resampling.
beg_str = pack_time(2011,1 ,1 ,0,0,0,'std');
end_str = pack_time(2013,1 ,1 ,0,0,0,'std');

% Get resampled data w/ SDs. 
% Note samples aren't forced to be positive, but this is alright for now.
mc = mc_ems_data(data.NEE_d13C,data.NEE_d13C_std,5000,beg_str,end_str,'normrnd');

% Save hourly data to the same structure.
[nt_op,dt_op] = get_nt_dt_ops([2011,2012]);
mc.hm         = data.NEE_d13C;
mc.hs         = data.NEE_d13C_std;
mc.hm_day     = data.NEE_d13C     .*dt_op;
mc.hs_day     = data.NEE_d13C_std .*dt_op;
mc.hm_night   = data.NEE_d13C     .*nt_op;
mc.hs_night   = data.NEE_d13C_std .*nt_op;



%NEE_Iso_sd = 0.21495 + 14.204* abs(NEE).^(-0.95502);
         
%neg_nee_msk = NEE <= 0;
%pos_nee_msk = ~neg_nee_msk;

%NEE_Unc     = ((25/7)*NEE     + (515/7)).*neg_nee_msk + (0.50)*NEE    .*pos_nee_msk;
%NEE_Iso_Unc = ((25/7)*NEE_Iso + (515/7)).*neg_nee_msk + (0.50)*NEE_Iso.*pos_nee_msk;

%----------------------------------------------------------------------------------------------%
end

% * Note: SD is conservative upper bound, twice the reported approx. error from
% "What are the instrument requirements for measuring the isotopic composition of net ecosystem
% exchange of CO2 using eddy covariance methods?" Saleska et al (2005)