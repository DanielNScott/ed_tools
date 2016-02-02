function [nt_op, dt_op] = get_nt_dt_ops(yrs)
% Creates two multiplicative unary operators, one for selecting night data and one for selecting
% daytime data from a year-length hourly resolution data vector.

nt_op = [];
dt_op = [];
for iyr = 1:numel(yrs)
   yr = yrs(iyr);
   mo_days = yrfrac(1:12,yr,'-days');              % Get the number of days in each month
   mnhrs   = get_night_hours(1:12);                % Define night hours by month

   yr_nt_msk = NaN(sum(mo_days)*24,1);             % Initialize the night time mask

   beg_ind = 1;                                    % Here we create the mask...
   for imo = 1:12                                  % ...
      end_ind = beg_ind + mo_days(imo)*24 - 1;     % ...
      yr_nt_msk(beg_ind:end_ind) = ...             % Create the mask
         repmat(mnhrs(imo,:)',mo_days(imo),1);     % ...
      beg_ind = beg_ind + mo_days(imo)*24;         % ...
   end

   yr_nt_msk  = double(yr_nt_msk);                 % Convert it to double so we can turn it
                                                   % into a multiplicative unary operator.

   yr_nt_op = yr_nt_msk;                           % Initialize the two multiplicative unary
   yr_dt_op = yr_nt_msk;                           % operators (for night and day)

   yr_nt_op(yr_nt_msk == 0) = NaN;                 % Make transform for day hour data -> NaNs
   yr_dt_op(yr_nt_msk == 1) = NaN;                 % Make transform for night hour data -> NaNs
   yr_dt_op(yr_nt_msk == 0) = 1;                   % Make the latter keep daytime data...
   
   nt_op = [nt_op; yr_nt_op];
   dt_op = [dt_op; yr_dt_op];
end

end

