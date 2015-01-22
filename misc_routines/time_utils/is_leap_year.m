function [ is_ly ] = is_leap_year( year )
%IS_LEAP_YEAR Returns a vector of Boolean values indicating leap years.
%   Input : year   - a vector of julian years
%   Output: is_ly  - an indicator vector marking which years from 'year' are leap years.

% Vectorized form. Premature optimization?
test1 = year/400 - floor(year/400) == 0;
test2 = year/100 - floor(year/100) == 0;
test3 = year/4   - floor(year/4  ) == 0; 

is_ly = test1 + (~test1 .* test2) + (~test1 .* ~test2 .* test3);

% Scalar form:
% Determine if the input year is a leap year
%if (year/400 - floor(year/400)) == 0
%   is_ly = 1;
%elseif (year/100 - floor(year/100)) == 0
%   is_ly = 0;
%elseif (year/4 - floor(year/4)) == 0
%   is_ly = 1;
%else
%   is_ly = 0;
%end

end

