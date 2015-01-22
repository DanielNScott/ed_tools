function [obs] = preproc_obs(obs, out, opt_metadata)
%PREPROC_OBS This function pre-processes observational data.
%   It pads and truncates observational data to make it easy to manipulate
%   with output data.

resolutions = fieldnames(obs);                           % What data resolutions exist?
for res_num = 1:numel(resolutions)                       % Cycle through the resolutions
   
   res     = resolutions{res_num};                       % Set resolution
   fields  = fieldnames(obs.(res));                      % What types of data are there?
   
   for fld_num = 1:numel(fields)                         % Cycle through fields
      fld = fields{fld_num};                             % Get the current field
      unc = [fld '_sd'];                                 % Save the fld's uncertainty header

      if iscell(fld); continue; end;                     % If the fld is a descriptor, ignore it
      if length(fld) > 2 && strcmp(fld(end-2:end),'_sd') % If this is uncertainty data...
         continue;                                       % Ignore it; We deal with it at the
      end                                                % same time as the nominal values.
      
      % Check to see if we should use this type of data.
      mdr_fld_num = strcmp(opt_metadata(:,2),fld);       % Get rows in metadata w/ this type 
      mdr_res_num = strcmp(opt_metadata(:,1),res);       % Get rows in metadata w/ this res 
      mdr_num = and(mdr_fld_num,mdr_res_num);            % The row num has this type and res
      
      metadata_row = opt_metadata(mdr_num,:);            % Get the row in opt_metadata
      if ~isempty(metadata_row)                          % It's empty if no metadata exists
         obs_data = obs.(res).(fld);                     % Get the nominal data
         unc_data = obs.(res).(unc);                     % Get the uncertainty data
         
         if length(obs_data) ~= length(unc_data);        % Check the data have the same sizes
            error('obs_data & unc_data have diff lens!') % Raise an exception if not.
         end
            
         % Get the index of the start date relative to data
         obs_beg = obs.(res).([fld '_lims']){1};            % Extract the time of 1st obs
         obs_end = obs.(res).([fld '_lims']){2};            % Extract time of last obs
         out_start = refmt_time(out.nl.start,'ED','std');   % Reformat ED style time string
         out_end   = refmt_time(out.nl.end  ,'ED','std');   % Reformat ED style time string
         
         if strcmp(res,'hourly')
            [IYEARA,IMONTHA,IDATEA,~,~,~] = tokenize_time(out.nl.start,'ED','num');
            if IMONTHA ~= 1
               IYEARA = IYEARA + 1;
               out_start = pack_time(IYEARA,1,1,0,0,0,'std');
            end
         end
         
         beg_ind = get_date_index(obs_beg,out_start,res);   % This sr uses 'std' fmt
         end_ind = get_date_index(obs_end,out_end  ,res);   % Inclusive, so subtract 1.
         
         % If this is a yearly var, but we don't have a full year, manipulate indices.
         if strcmp(res,'yearly')
            if str2double(out.nl.start(12:13)) ~= 1      % If start month indicates partial year
               beg_ind = beg_ind + 1;                    % we 'say' the opt begins next year.
            end
         end
         % Hack, not sure what's wrong.
         if strcmp(res,'hourly')
            if str2double(out.nl.start(12:13)) ~= 1
               end_ind = end_ind - 23;
            end
         end
         
         % Pad or trim beginning of data
         if beg_ind <= 0
            % Then data starts after the run starts and we pad the beginning.
            obs_data = [NaN(-1*(beg_ind),1); obs_data];
            unc_data = [NaN(-1*(beg_ind),1); unc_data];
         elseif beg_ind > 1
            % Data starts before the run so we trim the beginning.
            obs_data = obs_data(beg_ind+1:end);
            unc_data = unc_data(beg_ind+1:end);
         end
         
         % Pad or trim end of data
         if end_ind <= 0
            % Then output ends before data ends so we truncate data
            obs_data = obs_data(1:end+(end_ind-1));
            unc_data = unc_data(1:end+(end_ind-1));
         elseif end_ind > 1
            % Then output ends after data ends, so we pad data
            obs_data = [obs_data; NaN(end_ind-1,1) ];
            unc_data = [unc_data; NaN(end_ind-1,1) ];
         end

         % Throw out any data with claimed uncertainty of 0.
         zero_unc_msk = (unc_data == 0);                       % Create a mask 4 claims of 0 unc
         obs_data(zero_unc_msk) = NaN;                         % Remove dubious data
         unc_data(zero_unc_msk) = NaN;                         % Remove their uncertainties
         
         % And threshold unrealistic uncertainty claims.
         low_unc_msk  = (unc_data < 0.001*abs(obs_data));            % Mask for absurd claims
         unc_data(low_unc_msk) = abs(obs_data(low_unc_msk))*0.001;   % And make them reasonable.         
         
         % Keep everything we've done under the field and resolution it lives in, but as
         % "processed" data.
         obs.proc.(res).(fld) = obs_data;
         obs.proc.(res).(unc) = unc_data;
     end
   end
end

