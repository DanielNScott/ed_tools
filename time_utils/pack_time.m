function [ time_str ] = pack_time( y, mo, d, h, mi, s, ofmt)
%PACK_TIME( y, mo, d, h, mi, s, ofmt) Takes an input of numbers denoting year, month, day, hour,
%min. and sec. with an output format specification of 'std' or 'ED' and returns a string in 
%yyyy-mm-dd-mm-hh-ss or yyyy-mm-dd-mmhhss respectively.

ystr  = num2str(y );
mostr = num2str(mo);
dstr  = num2str(d );
hstr  = num2str(h );
mistr = num2str(mi);
sstr  = num2str(s );

if length(ystr) ~= 4
   disp('Sorry, pack_time wants to make four-character year-strings...')
   error('... but your year is WIERD!.')
end
if mo < 10
   mostr = ['0', mostr];
end
if d < 10
   dstr = ['0', dstr];
end
if h < 10
   hstr = ['0', hstr];
end
if mi < 10
   mistr = ['0', mistr];
end
if s < 10
   sstr = ['0', sstr];
end

if strcmp(ofmt,'std')
   time_str = [ystr '-' mostr '-' dstr '-' hstr '-' mistr '-' sstr ];
elseif strcmp(ofmt,'ED')
   time_str = [ystr '-' mostr '-' dstr '-' hstr mistr sstr ];
else
   error('Unrecognized output format! Should be std or ED.')
end

end

