function [ hr_data ] = proc_iso_eddy( data )
%PROC_ISODATA Transforms the isotope data into a hourly dataset for use with optimizer.
%  
%  The data input is full of gaps and is on a 40-minute sampling freq. With the optimization
%     framework we use fast-freq ED output of hourly means, so we want to get estimates of
%     these hourly means from the data for comparison. To do this, we'll interpolate to the half
%     hour mark whenever we're not on a gap boundary, in which case we'll just use the value
%     we're given for whatever time in that hour as the hourly ave.


%----------------------------------------------------------------------------------------------%
% Get start and end dates and create a NaN matrix with entries for every hour between them,
% inclusive of the last.
%----------------------------------------------------------------------------------------------%
beg_str = pack_time(data.YYYY(1)    ,1 ,1 ,1 ,0,0,'std');
end_str = pack_time(data.YYYY(end)+1,1 ,1 ,1 ,0,0,'std');
nhrs    = get_date_index(beg_str,end_str,'hourly') - 1;        % (sr is endpoint inclusive)
ndata   = numel(data.YYYY);

EddyFlux      = NaN(nhrs,1);
StorFlux      = NaN(nhrs,1);
EddyIsoflux13 = NaN(nhrs,1);
StorIsoflux13 = NaN(nhrs,1);
meanDel13C    = NaN(nhrs,1);
meanCO2       = NaN(nhrs,1);

year          = NaN(nhrs,1);
month         = NaN(nhrs,1);
day           = NaN(nhrs,1);
hour          = NaN(nhrs,1);
%----------------------------------------------------------------------------------------------%




%----------------------------------------------------------------------------------------------%
% Interpolate actual data                                                                      %
%----------------------------------------------------------------------------------------------%
skip  = 0;
for idata = 1:ndata
   if ~skip;                                                % Have we already processed this?
      itime = pack_time(data.YYYY(idata),data.MO(idata),... % Time of datum
              data.DD(idata),data.HH(idata),0,0,'std');     % ...
      index = get_date_index(beg_str,itime,'hourly')+2;     % Index for datum in 'temp'

      if data.MI(idata) < 20                                % Then expect a pt after 40min too.
         same_day = data.DD(idata) == data.DD(idata+1);     % Next pt is in the same day?
         same_hr  = data.HH(idata) == data.HH(idata+1);     % Next pt is in the same hour?

         if same_day && same_hr
            EddyFlux(index)      = (data.EddyFlux(idata)      + data.EddyFlux(idata+1))/2; 
            StorFlux(index)      = (data.StorFlux(idata)      + data.StorFlux(idata+1))/2;
            EddyIsoflux13(index) = (data.EddyIsoflux13(idata) + data.EddyIsoflux13(idata+1))/2;
            StorIsoflux13(index) = (data.StorIsoflux13(idata) + data.StorIsoflux13(idata+1))/2;
            meanDel13C(index)    = (data.meanDel13C(idata)    + data.meanDel13C(idata+1))/2;
            meanCO2(index)       = (data.meanCO2(idata)       + data.meanCO2(idata+1))/2;
            skip = 1;
         else                                               % Next pt not in hr, use this one
            EddyFlux(index)      = data.EddyFlux(idata); 
            StorFlux(index)      = data.StorFlux(idata);
            EddyIsoflux13(index) = data.EddyIsoflux13(idata);
            StorIsoflux13(index) = data.StorIsoflux13(idata);
            meanDel13C(index)    = data.meanDel13C(idata);
            meanCO2(index)       = data.meanCO2(idata);
         end
         
      else                                                  % Next pt not in hr, use this one
         EddyFlux(index)      = data.EddyFlux(idata); 
         StorFlux(index)      = data.StorFlux(idata);
         EddyIsoflux13(index) = data.EddyIsoflux13(idata);
         StorIsoflux13(index) = data.StorIsoflux13(idata);
         meanDel13C(index)    = data.meanDel13C(idata);
         meanCO2(index)       = data.meanCO2(idata);
      end
%       year (index) = data.YYYY(idata);
%       month(index) = data.MO(idata);
%       day  (index) = data.DD(idata);
%       hour (index) = data.HH(idata);
   else
      skip = 0;
   end
end
%----------------------------------------------------------------------------------------------%

% hr_data.year  = year;
% hr_data.month = month;
% hr_data.day   = day;
% hr_data.hour  = hour+1;
% 
% hr_data.EddyFlux = EddyFlux;
% hr_data.StorFlux = StorFlux;
% hr_data.EddyIsoflux13 = EddyIsoflux13;
% hr_data.StorIsoflux13 = StorIsoflux13;

%----------------------------------------------------------------------------------------------%
% Create year, month, day, hour fields for times without data.                                 %
%----------------------------------------------------------------------------------------------%
hours = [];
days  = [];
mos   = [];

mo_days = reshape(yrfrac(1:12,2011:2012,'-days')',24,1);
yrs     = [repmat(2011,nhrs/2-12,1); repmat(2012,nhrs/2+12,1)];

for imo = 1:24
   mos   = [mos  ; repmat(mod(imo-1,12)+1,24*mo_days(imo),1)];
   days  = [days ; reshape(repmat(1:mo_days(imo),24,1),mo_days(imo)*24,1)];
   hours = [hours; repmat((0:23)',mo_days(imo),1)];
end

dates = [yrs,mos,days,hours];
%----------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------%
% Pack data for export.                                                                        %
%----------------------------------------------------------------------------------------------%
NEE     = EddyFlux + StorFlux;
NEE_Iso = EddyIsoflux13 + StorIsoflux13;

neg_nee_msk = NEE <= 0;
pos_nee_msk = ~neg_nee_msk;

NEE_Unc     = ((25/7)*NEE     + (515/7)).*neg_nee_msk + (0.50)*NEE    .*pos_nee_msk;
NEE_Iso_Unc = ((25/7)*NEE_Iso + (515/7)).*neg_nee_msk + (0.50)*NEE_Iso.*pos_nee_msk;

d13C_Unc = meanDel13C * 0.01;
CO2_Unc  = meanCO2    * 0.01;

hr_data = [dates, NEE, NEE_Unc, NEE_Iso, NEE_Iso_Unc, meanDel13C, d13C_Unc, meanCO2, CO2_Unc];
hr_data(isnan(hr_data)) = -9999;

%----------------------------------------------------------------------------------------------%
end

