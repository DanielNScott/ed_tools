function [ ] = plot_carbon( data )
%PLOT_C_ANALY Summary of this function goes here
%   Detailed explanation goes here


nmonths  = length(data.H.MMEAN_GPP_CO); % Doesn't matter what monthly variable we use.


hw_maint = data.H.MMEAN_LEAF_MAINTENANCE_CO ...
         + data.H.MMEAN_ROOT_MAINTENANCE_CO ...
         + data.H.MMEAN_LEAF_DROP_CO;
     

hw_mass = data.H.MMEAN_BLEAF_CO + data.H.MMEAN_BROOT_CO + data.H.MMEAN_BSTORAGE_CO + ...
          data.H.BSAPWOODA + data.H.BSAPWOODB + data.H.BDEAD;

hw_mass_inc = [hw_mass(2:end) - hw_mass(1:end-1), NaN];

store_inc   = [data.H.MMEAN_BSTORAGE_CO(2:end) - data.H.MMEAN_BSTORAGE_CO(1:end-1), NaN];

living_inc = [data.H.BALIVE(2:end) - data.H.BALIVE(1:end-1), NaN];

figure()

dead_inc = [data.H.BDEAD(2:end) - data.H.BDEAD(1:end-1), NaN];

c_gain = data.H.MMEAN_NPP_CO/12 - hw_maint;

p1data = [c_gain                       ; ...
          ...hw_mass_inc               ; ...
          living_inc                   ; ...
          ...data.H.BALIVE             ; ...
          ...data.H.MMEAN_BSTORAGE_CO  ; ...
          store_inc                    ; ...
          ...dead_inc                  ; ...
          ...hw_maint];
          ];
tags   = {'C Gain.'        , ...
          '\Delta Living'  , ...
          '\Delta Storage' , ...
          ...'\Delta Dead'};
         };
       
plot(1:nmonths, p1data)
set_monthly_labels(gca,6);
legend(tags)



disp('Total C Gain')
disp(sum(c_gain))
disp('Total Living Biomass Gain')
disp(nansum(living_inc))
disp('Total Storage Biomass Gain')
disp(nansum(store_inc))
disp('Total Dead Biomass Gain')
disp(nansum(dead_inc))
disp('Balance')
disp(nansum(c_gain - living_inc - store_inc - dead_inc));

bai = [data.H.BA_CO(2:end) - data.H.BA_CO(1:end-1), NaN];
figure();
plot(1:nmonths, bai)
figure();
plot(1:nmonths, data.H.BA_CO)
%legend({'BA Total', 'BA HW', 'BA CO'})
   
end

