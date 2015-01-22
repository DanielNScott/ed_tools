function [ ind ] = get_date_index( dstr1, dstr2, res )
%GET_DATE_INDEX Returns the number of months dstr2 occurs after dstr1, inclusively.

% This is way overkill, but who cares? 
% Premature optimization is the root of all evil!
order = order_times(dstr1,dstr2);
if order == 0;                                        % Then dstr2 is the same date as dstr1
  ind = 1;                                            % ... and it's the first an ra of dates
  return;
elseif order < 0;
   tmp = dstr2;
   dstr2 = dstr1;
   dstr1 = tmp;
end

[yr1,mo1,d1,hr1,~,~] = tokenize_time(dstr1,'std','num');
[yr2,mo2,d2,hr2,~,~] = tokenize_time(dstr2,'std','num');

yr_diff = yr2 - yr1;
mo_diff = mo2 - mo1;
d_diff  = d2  - d1 ;
hr_diff = hr2 - hr1;

if strcmp(res,'hourly')
   days = reshape(yrfrac(1:12,yr1:yr2,'-days')',(yr_diff+1)*12,1);
   ind = 24*(sum(days(mo1:end-(12-mo2)-1)) + (d2-1));
elseif strcmp(res,'daily')
   days = reshape(yrfrac(1:12,yr1:yr2,'-days')',(yr_diff+1)*12,1);
   ind = sum(days(mo1:end-(12-mo2)-1)) + (d2-1);
elseif strcmp(res,'monthly')
   ind = yr_diff*12 + mo_diff;
elseif strcmp(res,'yearly')
   ind = yr_diff;
end

ind = ind*order;

end

