function [ order ] = order_times( tstr1, tstr2, res )
%ORDER_TIMES Returns 1 if tstr2 is after tstr1, 0 if same, -1 if reversed.
%   Detailed explanation goes here

[yr1,mo1,d1,hr1,min1,sec1] = tokenize_time(tstr1,'std','num');
[yr2,mo2,d2,hr2,min2,sec2] = tokenize_time(tstr2,'std','num');

if strcmp(res,'yearly')
   time1 = [yr1,0,0,0,0,0];
   time2 = [yr2,0,0,0,0,0];

elseif strcmp(res,'monthly')
   time1 = [yr1,mo1,0,0,0,0];
   time2 = [yr2,mo2,0,0,0,0];
   
elseif strcmp(res,'daily')
   time1 = [yr1,mo1,d1,0,0,0];
   time2 = [yr2,mo2,d2,0,0,0];
   
elseif strcmp(res,'hourly')
   time1 = [yr1,mo1,d1,hr1,0,0];
   time2 = [yr2,mo2,d2,hr2,0,0];
   
elseif strcmp(res,'min')
   time1 = [yr1,mo1,d1,hr1,min1,0];
   time2 = [yr2,mo2,d2,hr2,min2,0];

elseif strcmp(res,'sec')
   time1 = [yr1,mo1,d1,hr1,min1,sec1];
   time2 = [yr2,mo2,d2,hr2,min2,sec2];
   
end

order = recurse_compare(time1,time2);

end

function [order] = recurse_compare(ra1,ra2)
   if ra2(1) > ra1(1)
      order = 1;
   elseif ra2(1) < ra1(1)
      order = -1;
   else
      if numel(ra1) > 1
         order = recurse_compare(ra1(2:end),ra2(2:end));
      else
         order = 0;
      end
   end
end
