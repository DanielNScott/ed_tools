function [ stats ] = get_stats( out, obs, opt_metadata)
%GET_STATS Summary of this function goes here
%   Detailed explanation goes here

dbug = 1;

%-----------------------------------------------------------------------------------------%
% Initialize those statistics (which will be incremented in loops) to zero.               %
%-----------------------------------------------------------------------------------------%
stats.ns        = 0;          % Number of samples
stats.SSTot     = 0;          % Sum of squares [total]            sum((obs - obs_ave)^2)
stats.SSRes     = 0;          % Sum of squared residuals [errors] sum((obs - pred   )^2)
stats.Sx        = 0;          % Sum of observations               sum((obs          )  )
stats.Sy        = 0;          % Sum of predictions                sum((pred         )  )
stats.Sx2       = 0;          % Sum of square of obs.             sum((obs          )^2)
stats.Sy2       = 0;          % Sum of square of pred.            sum((pred         )^2)
stats.SPxy      = 0;          % Sum of product of obs. and pred.  sum((obs*pred     )  )

stats.total_likely          = 0;       % Weighted sum of all likelihoods, to be objective fn.
stats.total_likely_c_pool   = 0;       % 
stats.total_likely_c_flux   = 0;       % 
stats.total_likely_c13_pool = 0;       % 
stats.total_likely_c13_flux = 0;       % 
stats.total_likely_not_c    = 0;       % 
%-----------------------------------------------------------------------------------------%

resolutions = fieldnames(obs);                           % What data resolutions exist?
for res_num = 1:numel(resolutions)                       % Cycle through the resolutions

   res     = resolutions{res_num};                       % Set resolution
   fields  = fieldnames(obs.(res));                      % What types of data are there?

   for fld_num = 1:numel(fields)                         % Cycle through fields
      fld = fields{fld_num};                             % Get the current field
      if length(fld) > 2 && strcmp(fld(end-2:end),'_sd') % Ignore uncertainty data headers
         continue
      end
      if iscell(fld)                                     % Ignore data limits descriptors
         continue
      end

      mdr_typ_msk  = strcmp(opt_metadata(:,2),fld);      % Get rows in metadata w/ this type 
      mdr_res_msk  = strcmp(opt_metadata(:,1),res);      % Get rows in metadata w/ this res 
      mdr_msk      = and(mdr_typ_msk,mdr_res_msk);       % Want row with this type and res
      metadata_row = opt_metadata(mdr_msk,:);            % Get the row in opt_metadata

      % Only keep going if output for comparison exists.
      if ~isempty(metadata_row)                          % It's empty if no metadata exists
         type    = metadata_row{3};                      % Get the "type" of data.
         out_fld = metadata_row{4};                      % Get data's field name in output
         rework  = metadata_row{5};                      % See if the data was "re-worked";
         use     = metadata_row{6};                      % Determine if this field should be ignored
         c_class = metadata_row{7};                      % Determine if data is C, C-13 or other

         if rework                                       % If so change the path in the out
            out_fld(2) = 'Y';                            % struct to reworked copy under "Y".
         end

         msg = ['Computing stats for ' fld ' & ' out_fld];
         vdisp(msg,1,dbug)

         out_data = out.(out_fld(2)).(out_fld(4:end));   % Get output data
         obs_data = obs.proc.(res).(fld);                % Get the observational data
         obs_unc  = obs.proc.(res).([fld '_sd']);        % Get the uncertainty data

         [obs_data, obs_unc, out_data] ...               % Make sure sizes are conformant.
            = check_sizes(obs_data,obs_unc,out_data,fld);% If not, leading data trimmed.

%             % THIS IS A HACK TO MAKE FIA DATA WORK! %
%             if strcmp(type,'FIA')
%                obs_data = obs_data(2:end);
%                obs_unc  = obs_unc (2:end);
%             end
%             % THIS IS A HACK TO MAKE ISOTOPE DATA WORK! %
%             % Trim our reworked data.
%             if strcmp(out_fld(2),'Y')
%                if strcmp(res,'monthly')
%                   obs_data = obs_data(8:end);               % Ignore partial first year.
%                   obs_unc  = obs_unc (8:end);               % 
%                elseif strcmp(res,'daily')
%                   obs_data = obs_data(215:end);             % Ignore partial first year.
%                   obs_unc  = obs_unc (215:end);             % 
%                end
%             end

         obs_ave  = mean(obs_data);                      % Get the average of the data
         ns       = length(obs_data(~isnan(obs_data)));  % Get the number of samples

         % Update Statistics
         try
            % Sick of stupid shape errors!
            out_data = reshape(out_data, size(obs_data));

            stats.SSTot = stats.SSTot +  nansum((obs_data - obs_ave  ).^2);
            stats.SSRes = stats.SSRes +  nansum((obs_data - out_data ).^2);
            stats.Sx    = stats.Sx    +  nansum( obs_data                ); 
            stats.Sy    = stats.Sy    +  nansum( out_data                );
            stats.Sx2   = stats.Sx2   +  nansum( obs_data.^2             );
            stats.Sy2   = stats.Sy2   +  nansum( out_data.^2             );
            stats.SPxy  = stats.SPxy  +  nansum( obs_data.*out_data      );
            stats.ns    = stats.ns    +  ns;
         catch ME
            ME.getReport()
            disp('---------------------------------------------')
            disp('Extra Diagnostics from get_objective:')
            disp(['Field          : ', fld])
            disp(['Resolution     : ', res])
            disp(['Size(obs_data) : ', mat2str(size(obs_data))])
            disp(['Size(out_data) : ', mat2str(size(out_data))])
            disp('Saving dump.mat')
            save('dump.mat')
            error('See Previous Messages.')
            disp('---------------------------------------------')
         end

         if strcmp(res,'hourly')
            % Get the normalized absolute error.
            stats.likely.(res).(fld) = get_NAE(obs_data, out_data, obs_unc)* -0.5/ns;
         else
            % Get Nintendo Entertainment System! Sweeet!
            stats.likely.(res).(fld) = get_NES(obs_data, out_data, obs_unc)* -0.5/ns;
         end

         % Update total likelihood
         stats.total_likely = stats.total_likely + nansum(stats.likely.(res).(fld));
         
         % Update likelihood partitions for C-13, C, and non-carbon respectively
         switch (c_class)
            case ('C13 pool')
            stats.total_likely_c13_pool = stats.total_likely_c13_pool + nansum(stats.likely.(res).(fld));
            
            case ('C13 flux')
            stats.total_likely_c13_flux = stats.total_likely_c13_flux + nansum(stats.likely.(res).(fld));
            
            case ('C pool')
            stats.total_likely_c_pool = stats.total_likely_c_pool + nansum(stats.likely.(res).(fld));
            
            case ('C flux')
            stats.total_likely_c_flux = stats.total_likely_c_flux + nansum(stats.likely.(res).(fld));
            
            case ('Not C')
            stats.total_likely_not_c = stats.total_likely_not_c + nansum(stats.likely.(res).(fld));
               
            otherwise
            disp(['Field ', fld, ' at resolution ', res, ' has invalid carbon class tag in opt_metadata.'])
         end
         
         % Can check that things add up:
         % check = stats.total_likely_c_pool + stats.total_likely_c_flux + stats.total_likely_c13_pool ...
         %    + stats.total_likely_c13_flux + stats.total_likely_not_c == stats.total_c

      end
   end
end

%-----------------------------------------------------------------------------------------%
% Update fit statistics.                                                                  %
%-----------------------------------------------------------------------------------------%
stats.RMSE      = sqrt(stats.SSRes / (stats.ns - 1));
stats.CoefDeter = 1.0         - stats.SSRes ./ stats.SSTot;
stats.SSx       = stats.Sx2  - (stats.Sx  * stats.Sx) / stats.ns;
stats.SSy       = stats.Sy2  - (stats.Sy  * stats.Sy) / stats.ns;
stats.SPxy      = stats.SPxy - (stats.Sx  * stats.Sy) / stats.ns;
stats.R2        = stats.SPxy * stats.SPxy / stats.SSx / stats.SSy;
%-----------------------------------------------------------------------------------------%
end


function [ NDS ] = get_NES(numerator_1, numerator_2, denominator)
% Get normalized error squared.
   NDS = ((numerator_1 - numerator_2)./denominator).^2;
end


function [ NAD ] = get_NAE(numerator_1, numerator_2, denominator)
% Get normalized absolute difference
   NAD = abs(numerator_1 - numerator_2)./denominator;
end


function [ SSE ] = get_SSE( ra1, ra2 )
% Get Sum of the squared error
   SSE = sum((ra1 - ra2).^2);
end

function [ out ] = ceiling(in)
% Computes the mathematical ceiling, the 'opposite' of floor.
   out = -floor(-in);
end


function [obs, unc, out] = check_sizes(obs,unc,out,fld)
   nobs = numel(obs);
   nout = numel(out);
   if nobs ~= nout
      new_first_ind = nobs - nout + 1;
      
      disp('--------- Warning! --------------')
      disp('numel(obs) ~= numel(out)')
      disp(['Field     : ', fld])
      disp(['numel(obs): ', num2str(nobs)])
      disp(['numel(out): ', num2str(nout)])
      disp(['new index : ', num2str(new_first_ind)])
      
      if new_first_ind <= 0;
         disp('Rmoving leading portion of out')
         out = out(2-new_first_ind:end);
      else
         disp('Removing leading portion of obs.')
         obs = obs(new_first_ind:end);
         unc = unc(new_first_ind:end);
      end
   end
end

