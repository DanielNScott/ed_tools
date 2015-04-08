function [ times ] = fill_dates(res,start,fin,inc,varargin)
% FILL_DATES generates cell 'times' which lists all times btwn start and fin, inclusive, at a
% specified res.
% Inputs:
%   res      -- output type. e.g. 'Q', 'I', 'D'
%   start    -- start date string in format 'yyyy-mm-dd-hh-mm-ss'
%   fin      -- finish date, as start.
%   inc      -- increment for 'I' files. Use 'hhmmss' if res is 'I'
%               otherwise use '000000' (6 zeros). 
%   ['-mat'] -- produce matrix instead of cell of filenames. 

% Check the consistency of the user's input
if strcmp(inc,'000000')
    if strcmp(res,'I')
        error('The increment cannot be 000000 if res is I')
    end
end

if nargin > 4
   produce_mat = 1;
else
   produce_mat = 0;
end

% Get the start and finish times, and initialize strings.
[start_yr, start_mo, start_d, start_hr, start_min, start_sec] ...
   = tokenize_time(start,'std','num');

[yrstr, mostr, dstr, hrstr, minstr, secstr] ...
   = tokenize_time(start,'std','str');

[end_yr, end_mo, end_d, end_hr, end_min, end_sec] ...
   = tokenize_time(fin,'std','num');

% Integer indicator of resolution.
int_res = 0 + strcmp(res,'Y')*3 + strcmp(res,'M')*2 + strcmp(res,'D')*1; 

% Initialize the 'current' time
yr  =  start_yr;
mo  =  start_mo*(int_res < 3) +  end_mo*(int_res >= 3);
d   =   start_d*(int_res < 2) +   end_d*(int_res >= 2);
hr  =  start_hr*(int_res < 1) +  end_hr*(int_res >= 1);
min = start_min*(int_res < 1) + end_min*(int_res >= 1);
sec = start_sec*(int_res < 1) + end_sec*(int_res >= 1);

% Translate resolution
if strcmp(res,'I')
   resolution = 'hourly';
elseif strcmp(res,'D')
   resolution = 'daily';
elseif any(strcmp(res,{'Q','M','E'}))
   resolution = 'monthly';
elseif strcmp(res,'Y')
   resolution = 'yearly';
end

% Set prefix and suffix for filenames, initialize 'times'. Overestimate size.
nel   = get_date_index(start,fin,resolution) -1;
times = cell(nel,1);
if produce_mat
   times = NaN(nel,6);
end

if strcmp(res,'Y') && end_yr == start_yr;
   times = {};
   if produce_mat
      times = [];
   end
   return;
end

iter    = 0;
maxiter = 26*365*24;
%---- Create Remaining Filenames ------------------------------------------%
while ( yr < end_yr || mo < end_mo || d < end_d || hr < end_hr || min < end_min || sec < end_sec )
   iter = iter + 1;
   if iter > maxiter;
      disp('-----------------------------------------------')
      disp(' Do you want > 480 years of daily files...?')
      disp(' Or >~ 25 years of instantaneous fluxes...?')
      disp(' If no, this is a bug. If yes, change this code.')
      disp('------------------------------------------------')
      error('Loop limit achieved in fill_dates! Aborting!')
   end
      
   % Check that res is acceptable
   if sum(strcmp(res,{'Y','M','D','I'}))

      % Set sub file time increment strings
      if strcmp(res,'Y');
         mostr = '00';
         dstr  = '00';
      elseif strcmp(res,'M')
         dstr  = '00';
      end

      % Save the appropriate filename
      if produce_mat
         times(iter,:) = [str2double(yrstr), str2double(mostr), str2double(dstr),...
                          str2double(hrstr), str2double(minstr),str2double(secstr)];
      else
         times{iter} = [yrstr '-' mostr '-' dstr '-' hrstr '-' minstr '-' secstr];
      end
      
      % Determine if it's a leap year
      ly = is_leap_year(yr);

      % Set dmax (number of days / mo)
      if (sum(mo==[4,6,9,11]) == 1)
         dmax = 30;
      elseif mo==2 && ly == 0
         dmax = 28;
      elseif mo==2 && ly == 1
         dmax = 29;
      else
         dmax = 31;
      end
         
      % Determine the string for cur. month. Any output on shorter intervals
      % than requires a months string.
      if ~strcmp(res,'Y')
         % Days
         if strcmp(res,'D') || strcmp(res,'I')
            % Inst.
            if strcmp(res,'I') % => inc <  1d = 240000 == 1 00 00 00
               hr = hr + str2double(inc(1:2));
               % Inst. sub hour?
               if str2double(inc) < 010000 % i.e. less than 1hr
                  min = min + str2double(inc(3:4));
                  % Inst is sub min?
                  if str2double(inc) < 000100 % i.e. less than 1min
                     sec = sec + str2double(inc(5:6));
                     if sec >= 60
                        sec = sec - 60 ;
                        min = min + 1;
                     end
                     if sec<10; secstr = ['0' num2str(sec)];
                     else       secstr = num2str(sec);
                     end
                  end

                  % Out one level into min loop
                  if min >= 60
                     min = min - 60;
                     hr  = hr  + 1;
                  end
                  if min<10; minstr = ['0' num2str(min)];
                  else       minstr = num2str(min);
                  end
               end

               % Out one level into hour loop
               if hr >= 24
                  hr  = hr  - 24;
                  d   = d   + 1;
               end
               if hr<10; hrstr = ['0' num2str(hr)];
               else      hrstr = num2str(hr);
               end
            else % res IS 'D' not 'I'
               d = d + 1;
            end

            % Out one level into days loop
            if d   > dmax
               d   = 1;
               mo  = mo  + 1;
            end
            if d<10; dstr = ['0' num2str(d)];
            else     dstr = num2str(d);
            end
         else % res n.e. 'D' or 'I'
            mo = mo + 1;
         end

         % Out one level into month loop
         if mo  > 12
            mo  = 1;
            yr  = yr  + 1;
         end
         if mo<10; mostr = ['0' num2str(mo)];
         else      mostr = num2str(mo);
         end
      else % res = 'Y'
         yr = yr + 1;
      end

      yrstr = num2str(yr);
   else
      error('Invalid res. This must be Y, M, D, or I')
   end

end

if produce_mat
   times = times(~isnan(times(:,1)),:);
end
   
end