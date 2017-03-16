function [mc_co2, mc_d13C] = better_co2_fit()
%PROFILES_TO_OPT_DATA creates ed_opt observations from pre-processed
% profile data, the output of INTEGRATE_PROFILES.m

% Read profile data to extract time vectors.
profile_fname = '/home/dan/documents/harvard/data/observations/harvard_forest_archives/hf-209-iso/orig/HF-Profiles.tsv';

% Get means and variations of canopy integrals;
use_cache = 1;
[co2_ave, c13_ave, co2_var, c13_var] = get_canopy_ints(use_cache);

tsv_data  = dlmread(profile_fname, '\t', 1, 0);
time_data = tsv_data(:, 1:5);

time.Min   = time_data(:, 5);
time.Hour  = time_data(:, 4);
time.Year  = time_data(:, 3);
time.Month = time_data(:, 2);
time.Day   = time_data(:, 1);

data.co2_ave = co2_ave;
data.c13_ave = c13_ave;

data.co2_std = co2_var.^0.5;
data.c13_std = c13_var.^0.5;

% One means of generating a VERY conservative estimate of d13C uncertainty.
% Can figure out how to use the data in cov(co2_mean', c13_mean') later...
%max_d13C = get_d13C(c13_mean + c13_vars, co2_mean - co2_vars);
%min_d13C = get_d13C(c13_mean - c13_vars, co2_mean + co2_vars);
%d13C_var = (max_d13C - min_d13C)/2;
%d13C_std = d13C_var.^0.5;

licd_data = licd(data, time, 1);

%plot(licd_data.co2)

licd_data.d13C = get_d13C(licd_data.c13_ave, licd_data.co2_ave);

beg_str = pack_time(2011,1,1,0,0,0,'std');
end_str = pack_time(2014,1,1,0,0,0,'std');

mc_co2  = mc_ems_data (licd_data.co2_ave, licd_data.co2_std, ...
                       2000, beg_str, end_str, 'normrnd');

mc_d13C = mc_d13C_data(licd_data.c13_ave, licd_data.c13_std, ...
                       licd_data.co2_ave, licd_data.co2_std, ...
                       2000, beg_str, end_str, 'normrnd');
end



function [co2_prof_mean, c13_prof_mean, co2_prof_vars, c13_prof_vars, d13C_prof_mean] = get_canopy_ints(use_cache)
% This function reads a tsv of canopy height-profile co2 and d13C data,
% fits a curve to the profile at each time point and then computes
% an average co2 concentration and d13C value by integrating that curve
% from ground level to a pre-determined canopy height set in accordance
% with the can_depth variable in ED.
%
% Matrix dimension reference:
%
% co2_profile_:  hr-by-hgt
%   design_mat: hgt-by-regressor (i.e. X and bias)
%      weights: wgt-by-model_num (i.e. fit 1 model per profile)
%    residuals:  hr-by-hgt

% Data read:
[prof_co2, prof_c13] = read_in_data(use_cache);

% Useful stuff:
heights = [0.2, 1.0, 7.5, 12.5, 18.3, 24.1, 29.0];
n_hrs   = length(prof_co2);

% Data with full height profile
len_7pt_data = 14500 - 7544;
len_6pt_data = 14500 - len_7pt_data;

% Subdivide data into matrices with 6 and 7 height 
% measurements respectively; Otherwise NaNs are an issue.
co2_profile_7pt = prof_co2(1:len_7pt_data,:);
co2_profile_6pt = prof_co2(len_7pt_data+1:end,:);
co2_profile_6pt = co2_profile_6pt(:,[1:5,7]);

c13_profile_7pt = prof_c13(1:len_7pt_data,:);
c13_profile_6pt = prof_c13(len_7pt_data+1:end,:);
c13_profile_6pt = c13_profile_6pt(:,[1:5,7]);

% Define heights for 6, 7 point profiles
heights_7pt = heights;
heights_6pt = heights([1:5,7]);

% Fit the model co2 = a + b*hgt.^-0.25
design_fn = @(x) [ones(size(x,1),1), x.^(-0.25)];

% Design matrices for linear model fit
design_7pt = design_fn(heights_7pt');
design_6pt = design_fn(heights_6pt');

% Fit the linear models
[~, co2_model_vals_7pt, co2_residuals_7pt] = lmfit(design_7pt, co2_profile_7pt);
[~, co2_model_vals_6pt, co2_residuals_6pt] = lmfit(design_6pt, co2_profile_6pt);

[~, c13_model_vals_7pt, c13_residuals_7pt] = lmfit(design_7pt, c13_profile_7pt);
[~, c13_model_vals_6pt, c13_residuals_6pt] = lmfit(design_6pt, c13_profile_6pt);

% Get mean and variation of profile integrals
n_sample = 100;
[co2_prof_mean_7pt, co2_prof_vars_7pt] = bootstrap(n_sample, co2_model_vals_7pt, design_7pt, co2_residuals_7pt);
[co2_prof_mean_6pt, co2_prof_vars_6pt] = bootstrap(n_sample, co2_model_vals_6pt, design_6pt, co2_residuals_6pt);

[c13_prof_mean_7pt, c13_prof_vars_7pt] = bootstrap(n_sample, c13_model_vals_7pt, design_7pt, c13_residuals_7pt);
[c13_prof_mean_6pt, c13_prof_vars_6pt] = bootstrap(n_sample, c13_model_vals_6pt, design_6pt, c13_residuals_6pt);

% Pad 6pt data so we can re-agglomorate
co2_residuals_6pt = [co2_residuals_6pt(:,1:5), NaN(len_6pt_data,1) co2_residuals_6pt(:,6)];
c13_residuals_6pt = [c13_residuals_6pt(:,1:5), NaN(len_6pt_data,1) c13_residuals_6pt(:,6)];

% Re-agglomorate
co2_residuals = [co2_residuals_7pt; co2_residuals_6pt];
co2_prof_mean = [co2_prof_mean_7pt, co2_prof_mean_6pt];
co2_prof_vars = [co2_prof_vars_7pt, co2_prof_vars_6pt];

c13_residuals = [c13_residuals_7pt; c13_residuals_6pt];
c13_prof_mean = [c13_prof_mean_7pt, c13_prof_mean_6pt];
c13_prof_vars = [c13_prof_vars_7pt, c13_prof_vars_6pt];

%prof_mean = [prof_mean_7pt; prof_mean_6pt];
%prof_vars = [prof_vars_7pt; prof_vars_6pt ];

% Plot histogram of residuals for each height:
plot_resid = 0;
if plot_resid
   figure()
   for i = 1:7
      subplot(2,4,i)
      hist(co2_residuals_7pt(:,i),200);
      title(['\bf{Residuals for Height ', num2str(heights(i)), '}'])
      set(gca,'XLim',[-30,30]);
      %set(gca,'YLim',[0,500]);
   end
end
%savefig('CO2 Profile Residuals')
%save('integrate_canopy_means_results.mat');

d13C_prof_mean = get_d13C(c13_prof_mean, co2_prof_mean);
%d13C_prof_vars;

end


function [int_mean, int_var] = bootstrap(n_sample, model_vals, design, residuals)
% Generate many copies of data to re-fit based on model vals and residuals
% This is meant to work with two parameter models!

% Number of times profile was sampled and number of heights
[n_prof, n_hgts] = size(model_vals);

% Slice beginning and ending indices
beg_inds = 1:n_prof:(n_prof*n_sample-1);
end_inds = n_prof:n_prof:(n_prof*n_sample);

% Generate random permutations of residuals by height
random_residuals = NaN(n_prof*n_sample, n_hgts);
for sample = 1:n_sample
   
   lower = beg_inds(sample);
   upper = end_inds(sample);
   
   for col = 1:n_hgts
      random_residuals(lower:upper,col) = residuals(randperm(n_prof),col);
   end
end

% Boostrap new values by adding the random residuals to the data copies
repeated_vals = repmat(model_vals, [n_sample,1]);
bootstraps    = repeated_vals + random_residuals;

% Fit the same model to the boostrapped data
weights = lmfit(design, bootstraps);
weights = reshape(weights,[2, n_prof, n_sample]);

% Calculate the mean and variance of the integrals.
% (Using easier notation...)
h = 20.75;

weight_means = mean(weights,3);
weight_vars  = permute( var(permute(weights,[3,2,1])) ,[3,2,1] );

mean_cent_weights = bsxfun(@minus,weights,weight_means);

a_bar = weight_means(1,:);
b_bar = weight_means(2,:);

a_var = weight_vars(1,:);
b_var = weight_vars(2,:);
covar = dot(mean_cent_weights(1,:,:), mean_cent_weights(2,:,:),3)/100;

% The actual mean and variance:
int_mean = a_bar + 4/3 *b_bar *h^(-1/4);
int_var  = a_var + 8/3 *h^(-1/4) *covar + 16/9 *h^(-1/2) *b_var;
end



function [weights, yhats, residuals, gram] = lmfit(design,y)
% This function inverts the standard linear model design*weights = y

% Intermediate step to solution: Gram matrices
gram = design'*design;

% Solve for weights
weights = (gram)^-1*design'*y';

% Calculate model values
yhats = (design*weights)';

% Calculate the data residuals
residuals = yhats - y;

end



function [prof_co2, prof_c13] = read_in_data(use_cache)
% This is a sub-function just to keep the main more readable.

% It can take a minute to load all this, so for dev purposes
% there's cacheing.
if use_cache
   load('/home/dan/documents/harvard/data/observations/harvard_forest_archives/hf-209-iso/orig/integrate_canopy_means.mat');
   disp('Loaded integrate_canopy_means.mat rather than tsv file.')
else
   profile_fname = '/home/dan/documents/harvard/data/observations/harvard_forest_archives/hf-209-iso/orig/HF-Profiles.tsv';
   prof_data = read_cols_to_flds(profile_fname,'\t',0,0);
   
   save('integrate_canopy_means.mat');
end

prof_co2 = [prof_data.CO2_0_2m_ppm_, prof_data.CO2_1_0m_ppm_, ...
           prof_data.CO2_7_5m_ppm_ , prof_data.CO2_12_5m_ppm_,...
           prof_data.CO2_18_3m_ppm_, prof_data.CO2_24_1m_ppm_,...
           prof_data.CO2_29_0m_ppm_];

prof_d13C = [prof_data.Del13_0_2m_ppm_, prof_data.Del13_1_0m_ppm_,  ...
            prof_data.Del13_7_5m_ppm_ , prof_data.Del13_12_5m_ppm_, ...
            prof_data.Del13_18_3m_ppm_, prof_data.Del13_24_1m_ppm_, ...
            prof_data.Del13_29_0m_ppm_];
         
prof_co2 (prof_co2  == 9999) = NaN;
prof_d13C(prof_d13C == 9999) = NaN;

prof_c13 = get_C13(prof_co2, prof_d13C);

end
