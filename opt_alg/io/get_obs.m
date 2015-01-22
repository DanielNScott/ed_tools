%=========================================================================%
function [ obs ] = get_obs(opt_data_dir, model, data_fnames, simres)
%GET_OBS This function reads flux and demographic observation files for constraining ED.
%   Detailed explanation goes here

% User Options:
dbug   = 1;
rcache = 1;

%---------------------------------------------------------------%
% If we're not testing, or are testing with ED, get actual obs. %
%---------------------------------------------------------------%
if sum(strcmp(model,{'ED2.1','out.mat','read_dir'}))
   % Assume no cache, get number of years of obs.
   cache_exists = 0;

   %------------------------------------------------------------------------%
   % Load cache if it exists...                                             %
   %------------------------------------------------------------------------%
   if rcache && exist('./obs.mat','file')
      disp('Found observation cache "obs.mat", loading...')
      cache_exists = 1;
      tmp = load('obs.mat');
      obs = tmp.obs;
      clear tmp
   else
      if rcache && ~exist('obs.mat','file')
         disp('No cache detected, rcache is on, will be created.')
      else
         disp('No cache detected, rcache is off, will not create cache.')
      end

      %------------------------------------------------------------------------%
      %                                                                        %
      %------------------------------------------------------------------------%
      obs = struct();

      if simres.yearly
         obs = read_obs(obs, opt_data_dir, data_fnames.yr_FIA ,'yearly');
         obs = read_obs(obs, opt_data_dir, data_fnames.yr_flx ,'yearly');
      end

      if simres.monthly
         obs = read_obs(obs, opt_data_dir, data_fnames.mo_flx ,'monthly');
      end

      if simres.daily
         obs = read_obs(obs, opt_data_dir, data_fnames.day_flx,'daily');
      end

      if simres.fast
         obs = read_obs(obs, opt_data_dir, data_fnames.hr_flx ,'hourly');
      end

      % Save cache:
      if rcache
         save('obs.mat','obs')
         disp('Cache saved.')
      end
   end
else
   obs = 0;
end



end
%=========================================================================%


%=========================================================================%
function [ data ] = read_obs(data, fpath, fname, res )

fname = [ fpath fname ];      % Concatenate the file path & file name
raw   = readtext(fname,',');  % Read the data from the file

if strcmp(res,'yearly')
   time_cols = 1;             % If file is yearly data, skip yr col.
elseif strcmp(res,'monthly')
   time_cols = 2;             % If monthly, 'actual' data starts col 3.
elseif strcmp(res,'daily')
   time_cols = 3;             % Likewise for daily; Y, M, D precedes data.
elseif strcmp(res,'hourly')
   time_cols = 4;
end

matrix = cell2mat(raw(3:end,:));             % Extract the numerical data for ease...
fields = raw(2,time_cols+1:end);             % The types of data that exist (in the file)
nflds  = numel(fields);                      % The number of data fields

% Save column headers with data
for icol = 1:nflds
   fld  = fields{icol};                      % Extract the name of this data
   time = matrix(:,1:time_cols);             % Extract the times

   % Create strings for data limits
   beg_mo = 1; beg_d = 1; beg_hr = 0;        % Init defaults for beginning times
   end_mo = 1; end_d = 1; end_hr = 0;        % Same for ending times.
   if sum(strcmp(res,{'monthly','daily','hourly'}))
      beg_mo = time(1  ,2);                  % Get the start month
      end_mo = time(end,2);                  % Get the end month
      if sum(strcmp(res,{'daily','hourly'}));
         beg_d = time(1  ,3);                % Get start day
         end_d = time(end,3);                % Get end day
         if strcmp(res,'hourly');
            beg_hr = time(1  ,4);            % Get start day
            end_hr = time(end,4);            % Get end day
         end
      end
   end
   beg_str = pack_time(time(1  ,1),beg_mo,beg_d,beg_hr,0,0,'std');
   end_str = pack_time(time(end,1),end_mo,end_d,end_hr,0,0,'std');
   
   vals = matrix(:,time_cols + icol);              % Initialized 'processed data'
   vals(vals == -9999) = NaN;                      % Process data
   data.(res).(fld) = vals;                        % Assign data to header
   data.(res).([fld '_lims']) = {beg_str,end_str};
end

end
%=========================================================================%
