%function [co2_mean, c13_mean, d13C_mean] = integrate_canopy_means()
% This function reads a tsv of canopy height-profile co2 and d13C data,
% fits a curve to the profile at each time point and then computes
% an average co2 concentration and d13C value by integrating that curve
% from ground level to a pre-determined canopy height set in accordance
% with the can_depth variable in ED.

%dlmread('HF-Profiles.tsv',' ')

%heights = [0.2, 1.0, 7.5, 12.5, 18.3, 24.1, 29.0];

%big_co2 = [CO2_0_2m_ppm_,  CO2_1_0m_ppm_, ...
%           CO2_7_5m_ppm_,  CO2_12_5m_ppm_,...
%           CO2_18_3m_ppm_, CO2_24_1m_ppm_,...
%           CO2_29_0m_ppm_];

%big_d13C = [Del13_0_2m_ppm_,  Del13_1_0m_ppm_,  ...
%            Del13_7_5m_ppm_,  Del13_12_5m_ppm_, ...
%            Del13_18_3m_ppm_, Del13_24_1m_ppm_, ...
%            Del13_29_0m_ppm_];
         
%big_co2( big_co2 == 9999 ) = NaN;
%big_d13C(big_d13C == 9999) = NaN;

%big_c13 = get_C13(big_co2, big_d13C);

co2_mean  = NaN(14500,1);
c13_mean  = NaN(14500,1);

for i = 1:14501;

   co2_nans = isnan(big_co2(i,:));
   n_heights_missing = sum(co2_nans);
   
   if n_heights_missing == 0
      co2_fit = fit(heights',big_co2(i,:)','a - b*log(c*x)','StartPoint',[400,1,5],'Lower',[0,0,0]);
      c13_fit = fit(heights',big_c13(i,:)','a - b*log(c*x)','StartPoint',[400,1,5],'Lower',[0,0,0]);
      
   elseif n_heights_missing <= 3
      masked_heights = heights(~co2_nans);
      masked_co2     = big_co2(i,~co2_nans);
      masked_c13     = big_c13(i,~co2_nans);
      
      co2_fit = fit(masked_heights',masked_co2','a - b*log(c*x)','StartPoint',[400,1,5],'Lower',[0,0,0]);
      c13_fit = fit(masked_heights',masked_c13','a - b*log(c*x)','StartPoint',[400,1,5],'Lower',[0,0,0]);
   else
      continue
   end
   
   co2_fit_transp = @(x) co2_fit(x)';
   c13_fit_transp = @(x) c13_fit(x)';
   
   co2_mean(i)  = integral(co2_fit_transp, 0, 20.75) /20.75;
   c13_mean(i)  = integral(c13_fit_transp, 0, 20.75) /20.75;
      
   if mod(i,5) == 0
      clc;
      disp(['Progress [%]: ' num2str(i/14501*100)]);
   end
end

d13C_mean = get_d13C(c13_mean, co2_mean);

%end
