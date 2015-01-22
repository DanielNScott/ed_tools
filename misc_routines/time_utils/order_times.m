function [ order ] = order_times( tstr1, tstr2 )
%ORDER_TIMES Returns 1 if tstr2 is after tstr1, 0 if same, -1 if reversed.
%   Detailed explanation goes here

[yr1,mo1,d1,hr1,min1,sec1] = tokenize_time(tstr1,'std','num');
[yr2,mo2,d2,hr2,min2,sec2] = tokenize_time(tstr2,'std','num');

order = recurse_compare([yr1,mo1,d1,hr1,min1,sec1],[yr2,mo2,d2,hr2,min2,sec2]);

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
