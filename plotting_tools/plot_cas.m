function [ ] = plot_cas( mpost )
%PLOT_CAS Summary of this function goes here
%   Detailed explanation goes here

subaxis(3,1,1, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.03)
   [AX, ~, ~] = ...
   plotyy(1:720,mpost.data.test.T.FMEAN_CARBON_ST_PA, ...
          1:720,mpost.data.test.T.FMEAN_CARBON_ST_d13C_PA);
   set(AX(1),'XLim',[0,720])
   set(AX(2),'XLim',[0,720],'YLim',[-50,50])

subaxis(3,1,2, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.03)
   [AX, ~, ~] = ...
   plotyy(1:720,mpost.data.test.T.FMEAN_CARBON_AC_PA, ...
          1:720,mpost.data.test.T.FMEAN_CARBON_AC_d13C_PA);
   set(AX(1),'XLim',[0,720])
   set(AX(2),'XLim',[0,720],'YLim',[-50,50])
       
subaxis(3,1,3, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.03)
   [AX, ~, ~] = ...
   plotyy(1:720,mpost.data.test.T.FMEAN_CSTAR_PA, ...
          1:720,mpost.data.test.T.FMEAN_CSTAR_d13C_PA);
   set(AX(1),'XLim',[0,720])
   set(AX(2),'XLim',[0,720],'YLim',[-50,50])

%subaxis(1,3,1, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.03)
%   plot(1:720,mpost.data.test.T.FMEAN_CARBON_ST_PA_d13C)
 
end

