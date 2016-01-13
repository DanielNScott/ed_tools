function [ dat ] = read_met( driver_dir, driver_fname, yrs, yrf, dbug )
%READ_MET Summary of this function goes here
%   Detailed explanation goes here

if ~strcmp(driver_dir(end),'\')
   driver_dir = [driver_dir, '\'];
end

info_raw    = readtext([driver_dir, driver_fname]);
info_parsed = parse_driver_info(info_raw);

dat_raw = struct();
fnum    = 0;
months  = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};

for iyr = yrs:yrf
   iyr_str = num2str(iyr);
   for imo = 1:12
      fnum    = fnum + 1;
      imo_str = months{imo};
      
      met_fname = [driver_dir, info_parsed.prfx, iyr_str, imo_str '.h5'];
      dat_raw   = append_hdf5_read(met_fname,info_parsed.vars,dat_raw,fnum,dbug);
   end
end
vdisp('File reads complete.',1,dbug)

for ivar = info_parsed.vars
   dat.(ivar{:}) = vertcat(dat_raw.(ivar{:}){:})';
end

dat.info = info_parsed;

end

function [parsed] = parse_driver_info(raw)
nhead = 1;

parsed.nfmts = raw{nhead+1};
parsed.dir   = raw{nhead+2};

splt_dir     = strsplit(parsed.dir,'/');
parsed.prfx  = splt_dir{end};

grid_str     = raw{nhead+3};
splt_str     = strsplit(grid_str,' ');
parsed.nlon  = splt_str{1};
parsed.nlat  = splt_str{2};
parsed.dx    = splt_str{3};
parsed.dy    = splt_str{4};
parsed.xmin  = splt_str{5};
parsed.ymin  = splt_str{6};

parsed.nvars = raw{nhead+4};

step_str     = raw{nhead+6};
parsed.steps = strsplit(step_str,' ');

type_str     = raw{nhead+7};
parsed.types = strsplit(type_str,' ');

vars_str     = raw{nhead+5};
parsed.vars  = strsplit(vars_str,' ');
for ivar = 1:parsed.nvars
   parsed.vars{ivar}(parsed.vars{ivar} == '''') = '';
   parsed.types{ivar}(parsed.types{ivar} == '''') = '';
   parsed.types{ivar} = str2double(parsed.types{ivar});
end

parsed.sngl = {};
parsed.sval = {};
parsed.real_names = {};
parsed.units      = {};
code_names  = {'lon','lat','pres','tmp','ugrd','vgrd','sh','dlwrf','prate','vbdsf' ...
              ,'vddsf','nbdsf','nddsf'};
real_names  = {'Longitude','Latitude','Pressure','Temperature','Zonal Wind'...
              ,'Meridional Wind','Specific Humidity' ...
              ,'Downward Longwave Radiation','Precipitation Rate' ...
              ,'Visible Beam Downward Solar Radiation' ...
              ,'Visual Diffuse Downward Solar Radiation' ...
              ,'Near IR Beam Downward Solar Radation' ...
              ,'Near IR Diffuse Downward Solar Radiation'};
units       = {'NA','NA','Pa','K','m/s','m/s','kg_H2O/kg_air','W/m2','kg_H2O/m2/s','W/m2' ...
              ,'W/m2','W/m2','W/m2'};
for ivar = 1:parsed.nvars
   if parsed.types{ivar} == 4
      parsed.sngl{end+1} = parsed.vars{ivar};
      parsed.sval{end+1} = parsed.steps{ivar};
      
      parsed.vars  = remove_cell_entry(parsed.vars ,ivar);
      parsed.steps = remove_cell_entry(parsed.steps,ivar);
   else
      name_msk = strcmp(parsed.vars{ivar},code_names);
      if any(name_msk)
         parsed.real_names{end+1} = real_names{name_msk};
         parsed.units{end+1}      = units{name_msk};
      end
   end
end



end


function [raw_dat] = append_hdf5_read(fname,flds,raw_dat,ifile,dbug)

% HDF5 Reader Options:
plist          = 'H5P_DEFAULT';
oflgs          = 'H5F_ACC_RDWR';
mem_type_id    = 'H5ML_DEFAULT';
mem_space_id   = 'H5S_ALL';
file_space_id  = 'H5S_ALL';
dxpl           = 'H5P_DEFAULT';

% Open file and read fields:
vdisp(' ',1,dbug)
vdisp(['Attempting file read: ' fname],1,dbug)
f_id    = H5F.open(fname,oflgs,plist);
for ifld = 1:numel(flds)
   vdisp(['Attempting data read: ' flds{ifld}],1,dbug)
   dset_id = H5D.open(f_id,flds{ifld});
   raw_dat.(flds{ifld}){ifile} = H5D.read(dset_id,mem_type_id,mem_space_id,file_space_id,dxpl);
   H5D.close(dset_id)
end

end


% STANDARD MET DRIVER README (accessed 07/13/15)
% Line 1:  Number of file formats (n)
% Then, loop over n:
%    Prefixes of the file format
%    nlon, nlat, dx, dy, xmin, ymin
%    Number of variables contained in this format 
%    list of variables for each format
%    frequency at which variables are updated, for each var, or the scalar value if the variable type is 4 (see next)
%    do: (0) read gridded data - no time interpolation
%        (1) read gridded data - with time interpolatation
%        (2) read gridded data - constant in time, not changing (if this is lat/lon, will overwrite line 3 information)
%        (3) read one value representing the whole grid - no time interpolation
%        (4) specify a constant for all polygons, constant in time (most likely reference height)
% End loop over n.
% VARIABLE NAMES FOLLOW NCEP NAMING CONVENTIONS:
% nbdsf:  near IR beam downward solar radiation [W/m2]
% nddsf:  near IR diffuse downward solar radiation [W/m2]
% vbdsf:  visible beam downward solar radiation [W/m2]
% vddsf:  visible diffuse downward solar radiation [W/m2]
% prate:  precipitation rate [kg_H2O/m2/s]
% dlwrf:  downward long wave radiation [W/m2]
% pres: pressure [Pa]
% hgt: geopotential height [m]
% ugrd: zonal wind [m/s]
% vgrd: meridional wind [m/s]
% sh: specific humidity [kg_H2O/kg_air]
% tmp: temperature [K]
% co2: surface co2 concentration [ppm]
% lat: grid of latitude coordinates, if this variable is present line 3 is ignored
% lon: grid of longitude coordinates, if this variable is present line 3 is ignored
