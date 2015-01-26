function [fnames] = gen_poly_fnames(dir,f_type,out_type,start,fin,inc)
% GEN_POLY_FNAMES generates cell 'fnames' which lists ED2 output filenames by date.
% Inputs:
%   - dir      -- the directory in which files will be found
%   - f_type   -- the file type. E.g. 'analy' or the polygon name
%   - out_type -- output type. e.g. 'Q', 'I', 'D'
%   - start    -- start date string in format 'hhmmss-dd-mm-yyyy'
%   - fin      -- finish date, as start.
%   - inc      -- increment for 'I' files. Use 'hhmmss' if out_type is 'I'
%                 otherwise use '000000' (6 zeros). 

% Set prefixes and suffixes for filenames.
path   = dir;
prefix = [path, f_type, '-', out_type '-'];
suffix = '-g01.h5';

% Convert output type to resolution input for fill_dates
possible_res = {'Y','Y','M','M','D','I'};
res_selector = strcmp(out_type,{'T','Y','E','Q','D','I'});
resolution   = possible_res{res_selector};

% Get times
start  = refmt_time(start,'ED','std');
fin    = refmt_time(fin  ,'ED','std');
times  = fill_dates(resolution,start,fin,inc);
ntimes = numel(times);

% Initialize and fill cell fnames
fnames = cell(1,ntimes);
for i = 1:ntimes
   fnames{i} = [prefix, times{i}(1:13), times{i}(15:16), times{i}(18:19), suffix];
end

end
