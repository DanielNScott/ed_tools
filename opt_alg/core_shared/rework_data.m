function [ out ] = rework_data( obs, out, opt_metadata )
%REWORK_DATA Does two things: If an hourly data set has 'rework' flag set to 1, this routine
%masks the model output to correspond point-wise with the available data (i.e. an NaN/-9999 in
%the data implies the corresponding value in the output should be NaN) and then creates daily,
%monthly, and yearly means of the output for comparison with corresponding means in obs. These
%are saved in out.Y.(fld) fields.
%   Detailed explanation goes here

fields = fieldnames(obs.hourly);                         % What types of hourly data are there?
for fld_num = 1:numel(fields)                            % Cycle through fields
   fld = fields{fld_num};                                % Get the current field

   if iscell(fld); continue; end;                        % If the fld is a descriptor, ignore it
   if length(fld) > 2 && strcmp(fld(end-2:end),'_sd')    % If this is uncertainty data...
      continue;                                          % Ignore it; We deal with it at the
   end                                                   % same time as the nominal values.

   % Check to see if we should use this type of data.
   mdr_fld_msk = strcmp(opt_metadata(:,2),fld);          % Get rows in metadata w/ this type 
   mdr_res_msk = strcmp(opt_metadata(:,1),'hourly');     % Get rows in metadata w/ this hourly 
   mdr_msk = and(mdr_fld_msk,mdr_res_msk);               % The row num has this type and hourly
   metadata_row = opt_metadata(mdr_msk,:);               % Get the row in opt_metadata
   
   if ~isempty(metadata_row)                             % It's empty if no metadata exists
      rework = metadata_row{5};                          % Check the rework flag in metadata
      if rework
         prefix = metadata_row{4}(2);                    % Get fld prefix in out struct;
         
         out_fld  = metadata_row{4}(4:end);              % Data's field name in output
         obs_data = obs.proc.hourly.(fld);               % Get the nominal data
         nan_msk  = isnan(obs_data);                     % Create a NaN mask

         nan_vec  = double(~nan_msk);                    % Turn nan_msk 0=>1 and make double
         nan_vec(nan_vec == 0) = NaN;                    % Turn nan_vec 1=>NaN
         
         out_data = out.(prefix).(out_fld)';             % Get output data
         
         try
            out_data = out_data .*nan_vec;               % Apply the NaN mask
         catch ME
            out_size = num2str(length(out_data));
            obs_size = num2str(length(obs_data));
            msg = {'Output & obs have diff. length!';...
                  ['length of output: ' out_size];   ...
                  ['length of obs.  : ' obs_size]};
            disp(msg)
            disp(' ')
            error(ME)
         end
         
         out.Y.(out_fld) = out_data';                    % Save the modified data.
         
         out_fld_dmean = ['D' out_fld(2:end)];           % Create a DMEAN name
         out_fld_mmean = ['M' out_fld(2:end)];           % Create a MMEAN name
         out_fld_ymean = ['Y' out_fld(2:end)];           % Create a YMEAN name
         
         out_beg = refmt_time(out.nl.start,'ED','std');  % Reformat ED style time string
         out_end = refmt_time(out.nl.end  ,'ED','std');  % Reformat ED style time string
         
         % ASSUME RUN BEGINS JULY OF 1st YEAR! %
         % This has to be done since only complete year tower output gets read.
         beg_yr = tokenize_time(out_beg,'std','num')+1;  % Increment year by 1
         out_beg = [num2str(beg_yr), '-01-01-00-00-00']; % And pretend we started on the 1st.
         
         % Aggregate the modified data
         agg_dat = aggregate_data(out_data,out_beg,out_end,'ave');
         
         % Xfer the aggregates to new fields.
         out.Y.(out_fld_dmean) = agg_dat.dmeans';
         out.Y.(out_fld_mmean) = agg_dat.mmeans';
         out.Y.(out_fld_ymean) = agg_dat.ymeans';
         
         % Trim off partial first year of observations since we ignored it in aggregating model
         % output
         %obs.proc.(out_fld_dmean) = dmean';                 % Remove 1st June-Dec days
         %obs.proc.(out_fld_mmean) = mmean';                 % Remove 1st June-Dec

      end
   end
end

end

