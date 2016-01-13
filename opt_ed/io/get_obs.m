%=========================================================================%
function [ obs ] = get_obs(opt_data_dir, data_names_pre, simres, obs_yrs)
%GET_OBS This function reads flux and demographic observation files for constraining ED.
%   Detailed explanation goes here

%------------------------------------------------------------------------%
%                                                                        %
%------------------------------------------------------------------------%
if exist('./obs.mat','file')
   disp('Found observation cache "obs.mat", loading...')
   tmp = load('obs.mat');
   obs = tmp.obs;
   clear tmp
else
   if ~exist('obs.mat','file')
      disp('No cache detected, rcache is on, will be created.')
   else
      disp('No cache detected, rcache is off, will not create cache.')
   end

   %------------------------------------------------------------------------%
   %                                                                        %
   %------------------------------------------------------------------------%
   obs = struct();

   for id = 1:numel(data_names_pre)
      dname = data_names_pre{id};
      for iyr = obs_yrs
         resolutions = fieldnames(simres);
         for ires = 1:numel(resolutions)
            res = resolutions{ires};
            if simres.(res)
               if strcmp(res,'fast')
                  res = 'hourly';
               end
               fname = [dname '_' res '_' num2str(iyr) '.csv'];
               obs = read_obs(obs, opt_data_dir, fname, res, iyr);
            end
         end
      end
   end

   % Save cache:
   save('obs.mat','obs')
   disp('Cache saved.')
end

end
%=========================================================================%


%=========================================================================%
function [ obs ] = read_obs(obs, fpath, fname, res , year)

if strcmp(fname,'')
   return
end
fname = [ fpath fname ];      % Concatenate the file path & file name

if exist(fname,'file')
   try
      %data = csvread(fname,2,time_cols + 1);        % Read the data from the file
      data = read_cols_to_flds(fname,',',1,0);
      disp(['Loaded file    : ' fname])
   catch ME
      disp(['Failure to load: ' fname])
      return
      %disp(ME)
   end
else
   disp(['Does not exist : ' fname])
   return
end
   

% Save column headers with data
flds = fieldnames(data);
for ifld = flds'
   if any(strcmpi(ifld,{'year','month','day','hour'}))
      continue
   end
   ifld = char(ifld);
   
   data.(ifld)(data.(ifld) == -9999) = NaN;
   
   beg_str = pack_time(year, 1, 1, 0,0,0,'std');
   end_str = pack_time(year,12,31,23,0,0,'std');
      
   if ~isfield(obs,res)
      obs.(res) = struct();
   end
   
   if isfield(obs.(res),ifld);
      obs.(res).(ifld) = [obs.(res).(ifld); data.(ifld)];    % Assign obs to header
      obs.(res).([ifld '_lims']){2} = end_str;
   else
      obs.(res).(ifld) = data.(ifld);                        % Assign obs to header
      obs.(res).([ifld '_lims']) = {beg_str,end_str};
   end
end

end
%=========================================================================%
