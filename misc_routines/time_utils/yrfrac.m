function [ yrfrac ] = yrfrac( month, year, varargin )
%YRFRAC Returns the fraction of a given year a given month comprises.
%   month := the month or months we want to get a ratio for
%   year  := the year or years we want to get a ratio for
%   opt   := addnl input of '-days' sets output to days per mo rather than ratios
%   
%   If month is an M-vector and year is an N-vector, then yrfrac is an NxM matrix.
%
%   EX1: yrfrac(2,2012) should return 29/366, being the fraction of a leap
%        year comprised by february.
%   
%   EX2: yrfrac([2,4],[1991,1992,1993],'-days') should return
%        [28,30; 29,30; 28,30] since 1992 is a leap year but 1991, 1993 are not.


% Determine if the user wants days output instead of year fractions.
if nargin == 3;
   output_days  = strcmp(varargin{1},'-days');
else
   output_days = 0;
end

% Coerce year into being a column vector, month into being row vector.
nyrs  = numel(year );
nmo   = numel(month);
year  = reshape(year,nyrs,1);
month = reshape(month,1,nmo);

% Determine if the input year is a leap year
ly = is_leap_year(year);

% Vectorized code: Premature optimization? Probably... good practice though.
mo_days     = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
yrfrac      = repmat(mo_days,nyrs,1);
yrfrac(:,2) = yrfrac(:,2) + ly;
yrfrac      = yrfrac(:,month);

% Only calculate ratios if the user didn't request days.
if ~output_days
   yrfrac = yrfrac ./ repmat((ly + 365),1,12);
end

% Trim output to just those months requested.
yrfrac = yrfrac(:,month);

% Unvectorized code:
% Set number of days in each month, and number of days in year
% if ly
%     numdays = 366;
%     month_lengths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
% else
%     numdays = 365;
%     month_lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
% end
% 
% if ~output_days
%    num_months = length(month);
%    if num_months == 1
%        yrfrac = month_lengths(month)/numdays;
%    else
%        yrfrac = zeros(1,num_months);
%        for i=1:num_months
%            yrfrac(i) = month_lengths(month(i))/numdays;
%        end
%    end
% end

end

