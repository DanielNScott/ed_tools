%==========================================================================================%
% This file defines the variables needed to control 'optimize_ed'.                         %
% There are two 'optimization' algorithms:                                                 %
% 'DRAM': Adaptive Metropolis Hastings with Delayed Rejection                              %
%   'SA': Simulated Annealing                                                              %
%  'PSO': Canonical Particle Swarm Optimization                                            %
%==========================================================================================%
% Options for both testing the algorithm and optimizing ED follow...
%
% Options for the 'model' field:
%  - ED2.1              Runs the ED model.
%  - Rosenbrock         Runs an optimization on the coupled general Rosenbrock Function
%  - Sphere             Runs an optimization with objective = sum(square(x_i))
%  - Eggholder          Runs an optimization on the very difficult 2D 'Eggholder' function.
%  - Styblinski-Tang    Runs an optimization on the less difficult 2D 'Styblinski-Tang' fn.
%  - out.mat            Runs using an out.mat file as ED output. (Use 1 iter...)
%  - read_dir           Runs using a specified directory to obtain ED output. (Use 1 iter...)
%------------------------------------------------------------------------------------------%
model          = 'Rosenbrock';   % See note above.
prior_pdf      = 'uniform';      % Prior pdfs can be gaussian, uniform, or gammas.
opt_type       = 'NM';           % Optimization type can be DRAM, SA, PSO, or NM
niter          = 30;             % Number of iterations for outermost loop over simulations.
verbose        = 0;              % Verbosity: -1=>Silent, 0=>Progress Ind, 1=>Debug
multiplier     = 1.00;           % Multiplicative factor applied to initial parameters.
%------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------%
%                     Up-Front Job Resource Allocation Settings                            %
%------------------------------------------------------------------------------------------%
upfront_alloc = 1;             % Attempt to allocate all job resources at initialization?
time_per_sim  = 0.05;          % In hours, this determines the scheduler time request.
mem_per_sim   = 300;           % In MB, this determines the scheduler memory request.
%------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------%
%                    Matlab Distributed Computing Server Options                           %
%------------------------------------------------------------------------------------------%
use_dcs   = 0;                 % Use the matlab Distributed Computing Server?
job_queue = 'moorcroft_6100';  % The queue jobs will be submitted to
job_wtime = '0:01:30';         % Expected wall completion time per job
job_mem   = '80';              % Expected per-cpu-per-job memory requirement in MB
%------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------%
%                           SA Specific Parameters                                         %
% These all must be set, but won't do anything if the model is not running SA.             %
% Note: For geometric cooling sched. temp = mantissa ^ (-iter/niter * exp_mult)            %
%------------------------------------------------------------------------------------------%
acc_crit   = 'Boltzmann';   % Acceptance Criteria: Boltzmann (Default), Sq_Decay, Log_Decay 
cool_sched = 'Geometric';   % Cooling Schedule: Geometric, Linear, or Logarithmic
temp_start = 800;           % Starting Temperature of SA (1k max)
mantissa   = 6;             % See note above. Default to 4.
exp_mult   = 2;             % See note above. Default to 2.
%------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------%
%                          DRAM Specific Parameters                                        %
% These all must be set, but won't do anything if the model is not running DRAM.           %
%------------------------------------------------------------------------------------------%
ndr = 1;                      % Max # delayed rejection steps. 1 or 2
adapt_freq = 100;             % Freq @ which to adapt covar. matrix
%------------------------------------------------------------------------------------------%



%------------------------------------------------------------------------------------------%
%                          PSO Specific Parameters                                         %
% These all must be set, but won't do anything if the model is not running PSO.            %
%------------------------------------------------------------------------------------------%
nps   = 220;                  % Number of particles, i.e. simultaneous ED runs.
phi_1 = 4.1;                  % Governs strength of attractor at local best
phi_2 = 4.1;                  % Governs strength of attractor at neighbors' best
top   = 'Von Neumann';        % Topology. Currently only Von-Neumann supported.
%------------------------------------------------------------------------------------------%



%------------------------------------------------------------------------------------------%
%                            Nelder-Mead Algorithm Settings                                %
%------------------------------------------------------------------------------------------%
nsimp = 3;                   % Number of simplexes to run simultaneously.
                             % Every vertex will be run simultaneously at initialization
                             % then the standard serial algorithm will be run on each
                             % simplex.
p_reflect = 1;
p_expand  = 2;
p_cntrct  = -1/2;
p_shrink  = 1/2;
%------------------------------------------------------------------------------------------%



%------------------------------------------------------------------------------------------%
% General I/O Settings:                                                                    %
%  - rundir (the directory where this file should be) is assumed to have a subdirectory    %
%    titled 'analy' in which the model's output can be found.                              %
%  - opt_data_dir is the directory holding data we want to optimize against. (ED2.1 only)  %
%------------------------------------------------------------------------------------------%
rundir = '/n/moorcroftfs2/dscott/runfiles/optim/pso_10/';

opt_data_dir = '/n/moorcroftfs2/dscott/data/USHa_MC_BAG_Unc/';
%------------------------------------------------------------------------------------------%


%------------------------------------------------------------------------------------------%
% ED specific options... (Ignore if you're running a toy problem)                          %
% These do get used if model = 'out.mat' or 'read_dir'.                                    %
%                                                                                          %
% This specifies what data to use in the optimization. The optimizer will attempt to use   %
% as much of the data read from files in the optimization data directory specified below,  %
% excepting a 6-month spinup period.                                                       %
% For example, if the run is from 6/01/06 to 9/01/07 it will attempt                       %
%                                                                                          %
% NOTE: the names to the right MUST match column headers in CSV's in the data dir.         %
% Also, this get's TRIMMED IMMEDIATELY to those rows with vals 1 in the "Use This?" col.   %
%------------------------------------------------------------------------------------------%
opt_metadata = ...
...  Res    , Data Name       , Type  ,  Field from 'import_poly'   ,  Rework? Use?
{  'hourly' , 'NEE_Day'       , 'flx' , '.X.FMEAN_NEE_Day'          ,     1,     1; ...
   'hourly' , 'NEE_Night'     , 'flx' , '.X.FMEAN_NEE_Night'        ,     1,     1; ...
   'hourly' , 'Sens'          , 'flx' , '.X.FMEAN_SENSIBLE_CA_PY'   ,     0,     1; ...
   ...
   'daily'  , 'NEE_Night'     , 'flx' , '.Y.DMEAN_NEE_Night'        ,     1,     1; ...
   'daily'  , 'NEE_Day'       , 'flx' , '.Y.DMEAN_NEE_Day'          ,     1,     1; ...
   'daily'  , 'Sens'          , 'flx' , '.X.DMEAN_SENSIBLE_CA_PY'   ,     0,     1; ...
   'daily'  , 'Soil_Resp'     , 'flx' , '.X.DMEAN_Soil_Resp'        ,     0,     1; ...
   ...
   'monthly', 'NEE_Night'     , 'flx' , '.Y.MMEAN_NEE_Night'        ,     1,     1; ...
   'monthly', 'NEE_Day'       , 'flx' , '.Y.MMEAN_NEE_Day'          ,     1,     1; ...
   'monthly', 'Sens'          , 'flx' , '.X.MMEAN_SENSIBLE_CA_PY'   ,     0,     1; ...
   ...
   'yearly' , 'NEE_Night'     , 'flx' , '.Y.YMEAN_NEE_Night'        ,     1,     1; ...
   'yearly' , 'NEE_Day'       , 'flx' , '.Y.YMEAN_NEE_Day'          ,     1,     1; ...
   'yearly' , 'Sens'          , 'flx' , '.X.YMEAN_SENSIBLE_CA_PY'   ,     0,     1; ...
   ...
   ...
   'yearly' , 'BAG'           , 'FIA' , '.T.BAG'                    ,     0,     1; ...
   'yearly' , 'BAG_Hw'        , 'FIA' , '.H.BAG'                    ,     0,     1; ...
   'yearly' , 'BAG_Co'        , 'FIA' , '.C.BAG'                    ,     0,     1; ...
   ...
   'yearly' , 'BAM'           , 'FIA' , '.T.BAM'                    ,     0,     1; ...
   'yearly' , 'BAM_Hw'        , 'FIA' , '.H.BAM'                    ,     0,     1; ...
   'yearly' , 'BAM_Co'        , 'FIA' , '.C.BAM'                    ,     0,     1; ...
  };

% Filenames for observational data
% Note: Using an hourly data file trimmed to the appropriate years may save a lot of time.
data_fnames.yr_FIA  = 'yearly_FIA_stats_DM.csv';
data_fnames.yr_flx  = 'yearly_flux_11_12.csv';
data_fnames.mo_flx  = 'monthly_flux_11_12.csv';
data_fnames.day_flx = 'daily_flux_11_12.csv';
data_fnames.hr_flx  = 'hourly_flux_11_12.csv';

obs_years = 2010:2012;
obs_prefixes = {'sr','obs_nee/nee','sens','fia'};


% Set which pfts are found in params below, what to multiply all sdevs by.
pfts = [6,7,8,9,10,11];

% Structure defining which params to optimized, their prior means and prior standard
% deviations, and the pfts to apply each instance of the parameter to.
params = { ...
...% Parameter Name           ,  Tag              ,  PFTS    ,  Mean ,  Sdev ,Bounds, Mask
   'vmfact_co'                , 'pft'             , [6,7,8]  , 1.0000, 0.1500, [0.5,1.5], 1 ; ...
   'q'                        , 'pft'             , [6,7,8]  , 0.3463, 0.1500, [0  ,1.5], 1 ; ...
   'growth_resp_factor'       , 'pft'             , [6,7,8]  , 0.3330, 0.1200, [0  ,1  ], 1 ; ...
...
   'vmfact_hw'                , 'pft'             , [6,7,8]  , 1.0000, 0.1500, [0.5,1.5], 1 ; ...
   'q'                        , 'pft'             , [9,10,11], 1.1274, 0.5000, [0  ,2  ], 1 ; ...
   'storage_turnover_rate'    , 'pft'             , [9,10,11], 0.6200, 0.3000, [0  ,1  ], 1 ; ...
...
   'root_turnover_rate'       , 'pft'             , [6:11]   , 5.1000, 2.5000, [0,8]     , 1 ; ...
   'root_respiration_factor'  , 'pft'             , [6:11]   , 0.5280, 0.3000, [0,1]     , 1 ; ...
   'mort0'                    , 'pft'             , [6:11]   , 0.0000, 0.2500, [-0.5,0.5], 1 ; ...
   'mort2'                    , 'pft'             , [6:11]   , 20.000, 7.2500, [5,35]    , 1 ;
};

% (*) decomp_scheme 0,1
%------------------------------------------------------------------------------------------%



%------------------------------------------------------------------------------------------%
% Test specific options, these do nothing with model = 'ED2.1'                             %
%------------------------------------------------------------------------------------------%
if strcmp(model,'Rosenbrock')
   params = {... Name  ,   Initial Value  ,  Sdev,    Rng, Msk
                  'x1' , (rand() - 0.5) *6,  0.5 , [-3,3], 1; ...
                  'x2' , (rand() - 0.5) *6,  0.5 , [-3,3], 1; ...
                  'x4' , (rand() - 0.5) *6,  0.5 , [-3,3], 0; ...
                  'x5' , (rand() - 0.5) *6,  0.5 , [-3,3], 0; ...
                  'x6' , (rand() - 0.5) *6,  0.5 , [-3,3], 0; ...
                  'x7' , (rand() - 0.5) *6,  0.5 , [-3,3], 0; ...
            };
end
%------------------------------------------------------------------------------------------%

%==========================================================================================%
