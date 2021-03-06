function [ y, mo, d, h, mi, s ] = tokenize_time( time, ifmt, ofmt )
%TOKENIZE_TIME(TIME,IFMT,OFMT) takes a string time input along with input format ('ED' or
%'std')and produces produces a year, month, day, hour, minute and second with output format as a
%string or number ofmt = 'str' or ofmt = 'num'.


if strcmp(ifmt,'ED')
   y  = time(1:4);
   mo = time(6:7);
   d  = time(9:10);
   h  = time(12:13);
   mi = time(14:15);
   s  = time(16:17);
elseif strcmp(ifmt,'std')
   y  = time(1:4);
   mo = time(6:7);
   d  = time(9:10);
   h  = time(12:13);
   mi = time(15:16);
   s  = time(18:19);
end

if strcmp(ofmt,'num');
   s  = str2double(s );
   mi = str2double(mi);
   h  = str2double(h );
   d  = str2double(d );
   mo = str2double(mo);
   y  = str2double(y );
end
   
end

