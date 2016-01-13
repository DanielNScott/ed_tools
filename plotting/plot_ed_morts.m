function [ ] = plot_ed_morts()
%PLOT_ED_MORTS Summary of this function goes here
%   Detailed explanation goes here

% ED Defaults:
% mort0(5:11) = 0.0
% mort1(5:11) = 1.0
% mort2(5:11) = 20.0

% mort3(5)  = 0.066
% mort3(6)  = 0.0033928
% mort3(7)  = 0.0043
% mort3(8)  = 0.0023568
% mort3(9)  = 0.006144
% mort3(10) = 0.003808
% mort3(11) = 0.00428

%------------------ Settings --------------------
mort0 = [ 0,  0,  0, -0.1, -0.2];
mort2 = [16, 20, 24,   20,   20];

lgnd = {'Common CB Region'        , ... 
        'mort0 =  0.0; mort2 = 16', ...
        'mort0 =  0.0; mort2 = 20', ...
        'mort0 =  0.0; mort2 = 24', ...
        'mort0 = -0.1; mort2 = 20', ... 
        'mort0 = -0.2; mort2 = 20', ... 
        };

upper_cb_lim =   0.4;
lower_cb_lim = - 0.4;
%------------------------------------------------

ncurves = length(mort0);
cbr_bar = lower_cb_lim:0.01:upper_cb_lim;
for cnum = 1:ncurves
   mort_curves(cnum,:) = get_mort_curve(cbr_bar, mort0(cnum), 1, mort2(cnum), 0, 0, 0);
end

hold on
ha = area([-0.2 0.2], [ 1  1]);
set(ha,'FaceColor',[0.8,1,1])
set(ha,'BaseValue', 0.3)
plot(cbr_bar,mort_curves)
hold off

legend(lgnd,'Location','SouthEast')
set(gca,'XLim',[lower_cb_lim,upper_cb_lim])
set(gca,'YLim',[0.3,1])
xlabel('Fractional Carbon Balance')
ylabel('Fractional Survivorship')
set(gca,'XGrid','on')
set(gca,'YGrid','on')

title('\bf{Sensitivity of CB Mortality to Mort0 and Mort2}')

end

function [dndt] = get_mort_curve(cbr_bar, mort0, mort1, mort2, mort3, frost_mort, treefall)

% Mort 0 should be (-inf,1] 
% - setting it at 1 would make it too close to 1 would make it effectively density-ind.
%
% Mort 1 (?)
% - y value of upper asymptote
%
% Mort 2
% - Curvature parameter.

% Set mort_rate vector up as it exists in ED.

npts = length(cbr_bar);
mort_rate(1,:) = repmat(mort3,1,npts);

lnexp_min = -38;
lnexp_max =  38;

expmort      = max(lnexp_min, min( lnexp_max, mort2' * ( cbr_bar - mort0 )));
mort_rate(2,:) = mort1 ./ (1. + exp(expmort));

mort_rate(3,:) = repmat(treefall,1,npts);

temp_dep = 1;
%temp_dep = max(0.0, min( 1.0, 1.0 - (avg_daily_temp - plant_min_temp) / 5.0) );
mort_rate(4,:) = repmat(frost_mort * temp_dep,1,npts);

dlnndt = - sum(mort_rate(1:4,:));
%dndt   = dlnndt * nplant;

%---------------------------------------------------------------------------!
%    Apply mortality, and do not allow nplant < negligible_nplant (such a   !
% sparse cohort is about to be terminated, anyway).                         !
% NB: monthly_dndt may be negative.                                         !
%---------------------------------------------------------------------------!
%monthly_dlnndt = dlnndt;
%monthly_dndt  (ico) = max( cpatch%monthly_dndt   (ico)               &
%                                , negligible_nplant     (ipft)              &
%                                - cpatch%nplant         (ico) )
%monthly_dlnndt(ico) = max( cpatch%monthly_dlnndt (ico)               &
%                                , log( negligible_nplant(ipft)              &
%                                     / cpatch%nplant    (ico) ) )
%nplant = nplant_in* exp(monthly_dlnndt);
%---------------------------------------------------------------------------!

dndt = exp(dlnndt);

end