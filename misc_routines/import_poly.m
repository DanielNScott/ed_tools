%======================================================================================%
function [ out ] = import_poly( varargin )
%IMPORT_POLY reads HDF5 files, either with information given in the input in the form of a
%directory plus timeframe info or with information set below as a default.
%   Detailed explanation goes here
   
   dbug = 0;

   if nargin == 1
      out.nl = varargin{1};
   else
      out.nl.f_type   = 'HFF_Fast';
      out.nl.out_type = 'Y';
      out.nl.dir      = 'C:\Users\Dan\Moorcroft Lab\ED Output\r85-DS\HFF_Fast_1994_1997\analy\';
      out.nl.splflg   = 1;
      out.nl.c13out   = 0;

      % Format        = 'hhmmss-dd-mm-yyyy'
      out.nl.start    = '1994-06-01-000000';
      out.nl.end      = '1997-01-01-000000';
      out.nl.inc      = '000000';
   end
   
   actual_start = out.nl.start;
   if sum(strcmp(out.nl.out_type,{'Y','T'}))
      [yr,mo,d,hr,mi,s] = tokenize_time(out.nl.start,'ED','num');
      if mo ~= 1;
         yr = yr+1;
         mo = 1;
         out.nl.start = pack_time(yr,mo,d,hr,mi,s,'ED');
      else
      end
      
   end
   
   fnames   = gen_poly_fnames(out.nl.dir, out.nl.f_type, out.nl.out_type, out.nl.start,...
                                 out.nl.end, out.nl.inc );

   out.nl.start = actual_start;
   if isempty(fnames)
      disp('Warning, import poly was asked to generate a 0 length list of filenames.')
      disp('Check the simulation start and end times and the output type.')
      return;
   end
   
   disp('Importing model output using import_poly.m...')
   out      = init_out_struct (out);
   out.raw  = read_vars       (out.raw,fnames,out.nl.out_type,dbug);
   out      = process_vars    (out,fnames,out.nl.out_type,dbug);
   out.desc = 'Created with import_poly using nl in (this).nl';

   %save('out.mat','out')

end
%======================================================================================%


%======================================================================================%
function [ ofld ] = read_vars(ofld,fnames,res,dbug)
%

% ------------------------------------------------------------------------
% Initialize some stuff.
%--------------------------------------------------------------------------
nfiles         = length(fnames);
flds           = fieldnames(ofld);
plist          = 'H5P_DEFAULT';
oflgs          = 'H5F_ACC_RDWR';
mem_type_id    = 'H5ML_DEFAULT';
mem_space_id   = 'H5S_ALL';
file_space_id  = 'H5S_ALL';
dxpl           = 'H5P_DEFAULT';

%--------------------------------------------------------------------------
% Read in HDF5 fields
%%-------------------------------------------------------------------------
% We should only ever need to read in SLZ once
if res ~= 'T'
   ofld.SLZ = hdf5read(fnames{1},'SLZ');
end

disp('Reading Files...')
for ifile = 1:nfiles
    if dbug; disp('----------------------------------------------------------')  ; end
    if dbug; disp(['Reading File: ',fnames{ifile}])                              ; end
    f_id = H5F.open(fnames{ifile},oflgs,plist);    
    
    % Copy Vars
    for ifld = 1:numel(flds)
        if dbug; disp([' - Reading Var: ',flds{ifld}]); end
        if strcmp(flds{ifld},'SLZ'   ); continue            ; end
        if strcmp(flds{ifld},'nl'    ); continue            ; end
        if strcmp(flds{ifld},'map'   ); continue            ; end
        if strcmp(flds{ifld},'T'     ); continue            ; end
        if strcmp(flds{ifld},'Co'    ); continue            ; end
        if strcmp(flds{ifld},'Hw'    ); continue            ; end
        if strcmp(flds{ifld},'Gr'    ); continue            ; end
        if strcmp(flds{ifld},'thick' ); continue            ; end
        if strcmp(flds{ifld},'raw'   ); continue            ; end
        dset_id = H5D.open(f_id,flds{ifld});
        ofld.(flds{ifld}){ifile} = H5D.read(dset_id,mem_type_id,mem_space_id,file_space_id,dxpl);
        H5D.close(dset_id)
    end
end
end
%======================================================================================%


%======================================================================================%
function [ out ] = process_vars(out,fnames,res,dbug)

   %----------------------------------------------------------------------%
   % Some Set Up                                                          %
   %----------------------------------------------------------------------%
   nfiles = length(fnames);      %
   flds   = fieldnames(out.raw); % 
   tables();                     % Import tables for QMEAN night time mask

   %Convert SLZ to layer thickness
   if res ~= 'T'
      for i = 1:length(out.raw.SLZ)-1
         out.thick(i) = out.raw.SLZ(i) + out.raw.SLZ(i+1);
      end
      out.thick(end+1) = - out.raw.SLZ(end);
   end
   %----------------------------------------------------------------------
    
    
    
   %---- START POST PROCESSING VARIABLES ---------------------------------
   disp('Processing Files...')
   for fnum = 1:nfiles
      
      if dbug; disp(' ')                                                         ; end
      if dbug; disp('----------------------------------------------------------'); end
      if dbug; disp(['Processing vars from file: ',fnames{fnum}])                ; end
      
      %Cycle through vars -----------------------------------------------
      for varnum = 1:numel(flds)
         varname = flds{varnum}; % Most vars we'll load by their name and save under it too...
         savname = varname;      % ...but we save vars we manipulate alot under different names
         
         % This var flags output vars which are scaled (in the HDF5) by nplant.
         % Currently, there is only one other kind of variable (LAI) that we process
         % differently; Its output is m2/m2, which we want to keep, take weighted avg.
         plant_intensive = 1;
         
         % Exceptions: For these vars either skip this entire block or
         % skip some portion of it.
         if strcmp(varname,'NPLANT'       )  ; continue           ; end
         if strcmp(varname,'PFT'          )  ; continue           ; end
         if strcmp(varname,'SLZ'     )       ; continue           ; end
         if strcmp(varname,'AREA'    )       ; continue           ; end
         if strcmp(varname,'PACO_ID' )       ; continue           ; end
         if strcmp(varname,'nl'    ); continue            ; end
         if strcmp(varname,'map'   ); continue            ; end
         if strcmp(varname,'T'     ); continue            ; end
         if strcmp(varname,'Co'    ); continue            ; end
         if strcmp(varname,'Hw'    ); continue            ; end
         if strcmp(varname,'Gr'    ); continue            ; end
         if strcmp(varname,'thick' ); continue            ; end
         if strcmp(varname,'raw'   ); continue            ; end
         if strcmp(varname(end-1:end),'3C')  ; continue           ; end
         if strcmp(varname(end-1:end),'13')  ; continue           ; end
         
         if strcmp(varname,'LAI_CO'       )  ; plant_intensive = 0; end
         if strcmp(varname,'MMEAN_LAI_CO' )  ; plant_intensive = 0; end
         
         %Process Patch Vars -----------------------------------------------
         if out.map.(varname){1}
            if dbug; disp([' - Processing Pa Var: ', varname]); end

            % Scale the patch var...
            [tempVar,savname] = scale_patch_var(out,varname,fnum,plant_intensive);

            % Sum the rescaled variables to get the total.
            out.T.(savname)(fnum) = sum(tempVar);

            % PROCESS SPLIT -----------------------------------------------
            if out.nl.splflg == 1 && out.map.(varname){5}
               if dbug; disp('    - Processing Split'); end
               out = process_split(out,savname,fnum,tempVar);
            end
            
            % DETERMINE R AND DELTA, but only if c13out == 1 -----------------%
            if out.nl.c13out && out.map.(varname){4}
               %var     = out.(spltFlds{n}).(varname)(fnum);
               %var_C13 = out.(spltFlds{n}).([varname,'_C13'])(fnum);

               %out.(spltFlds{n}).([varname,'_d13C'])(fnum) = ((var_C13/(var - var_C13))/0.011237 - 1.0)*1000.0;
               savname = [varname '_C13'];
               delname = [varname '_d13C'];
               [tempVar,savname] = scale_patch_var(out,savname,fnum,plant_intensive);
               
               var     = out.T.(varname)(fnum);
               var_C13 = sum(tempVar);

               out.T.(savname)(fnum) = var_C13;
               out.T.(delname)(fnum) = ((var_C13/(var - var_C13))/0.011237 - 1.0)*1000.0;
            end
            
         %Process Site Vars -----------------------------------------------
         elseif out.map.(varname){2}
            if dbug; disp([' - Processing Si Var: ',varname]); end
            out.T.(varname)(fnum) = out.raw.AREA{fnum}'*out.raw.(varname){fnum};
            
            if out.nl.c13out && out.map.(varname){4}
               if strcmp(varname(end-1:end),'_C')
                  savname = [varname '13'];
               else
                  savname = [varname '_C13'];
               end
               delname = [varname '_d13C'];
               
               var     = out.T.(varname)(fnum);
               var_C13 = out.raw.AREA{fnum}'*out.raw.(savname){fnum};
               
               out.T.(savname)(fnum) = var_C13;
               out.T.(delname)(fnum) = ((var_C13/(var - var_C13))/0.011237 - 1.0)*1000.0;
            end
         
         %Process Ed Vars -----------------------------------------------
         elseif out.map.(varname){3}
            if dbug; disp([' - Processing Ed Var: ',varname]); end
            if strcmp(out.map.(varname){6},'Q')
               savname = ['MMEAN' varname(6:end) '_Night'];
               tempMsk = logical(month_night_hrs{mod(fnum+4,12)+1}');
               tempDiv = sum(tempMsk); 
               tempVar = out.raw.(varname){fnum}(tempMsk);
               tempVar = sum(tempVar,1)'/tempDiv;
               out.T.(savname)(fnum) = tempVar;
            else
               out.T.(savname) = [out.T.(savname), out.raw.(varname){fnum} ];
%               out.T.(savname)(fnum) = out.raw.(varname){fnum};
            end
            
         %Process Uncatagorized Vars -------------------------------------
         else
            if dbug; disp([' - Processing Uncat Var: ',varname]); end
            if strcmp(varname,'BASAL_AREA_MORT')  || ...
               strcmp(varname,'BASAL_AREA_GROWTH')
               
               tempVar = out.raw.(varname){fnum};
               out.T.(savname)(fnum) = sum(sum(out.raw.(varname){fnum}));
               out.C.(savname)(fnum) = 0.0;
               out.H.(savname)(fnum) = 0.0;
               out.G.(savname)(fnum) = 0.0;
               for ipft=1:size(tempVar,2)
                  if sum(ipft == [6,7,8] > 0)
                     out.C.(savname)(fnum) = out.C.(savname)(fnum) + sum(tempVar(ipft,:));
                  elseif sum(ipft == [9,10,11] > 0)
                     out.H.(savname)(fnum) = out.H.(savname)(fnum) + sum(tempVar(ipft,:));
                  elseif ipft == 5
                     out.G.(savname)(fnum) = out.G.(savname)(fnum) + sum(tempVar(ipft,:));
                  end
               end
            else
               out.T.(savname)(fnum) = out.raw.(varname){fnum};
            end
         end
      end
   end
        
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Here a bunch of derivative variables get created...
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   % Everywhere below a 365 is featured, a leap year is being ignored.
   % This is obvious maybe, but good to keep track of.
   
   %-------------------------------------------------------------------------------------%
   % Process 'Tower' File Data.                                                          %
   %-------------------------------------------------------------------------------------%
   if strcmp(out.nl.out_type,'T')
      night_msk = logical([]);
      [first_yr,~,~,~,~,~] = tokenize_time(out.nl.start,'ED','num');
      for fnum = 1:nfiles
         %-------------------------------------------------------------------------------------%
         % Way up at the top of this routine we decided to ignore the first year if it wasn't  %
         % full, because it would be complicated to deal with and we only want to optimize     %
         % against full year data anyway. So the curr_yr is actually the first + 1.            %
         %-------------------------------------------------------------------------------------%
         curr_yr = first_yr + fnum;                         % See comment above.
         mo_days = yrfrac(1:12,curr_yr,'-days')';           % Get days in each month this year.
         for imo = 1:12
            night_hrs = get_night_hours(imo);
            night_msk = [night_msk, repmat(night_hrs,1,mo_days(imo))];
         end
      end
      out.X.FMEAN_NEE                     = -1*out.T.FMEAN_NEP_PY * KgperSqm2TperHa /365/24;
      out.X.FMEAN_NEE_Night               = -1*out.T.FMEAN_NEP_PY * KgperSqm2TperHa /365/24;
      out.X.FMEAN_NEE_Day                 = -1*out.T.FMEAN_NEP_PY * KgperSqm2TperHa /365/24;
      out.X.FMEAN_NEE_Night(:,~night_msk) = NaN;
      out.X.FMEAN_NEE_Day(:,night_msk)    = NaN;
      
      out.X.FMEAN_VAPOR_CA_PY           = -1*out.T.FMEAN_VAPOR_AC_PY * 1000 * 2.260;
   end
   %-------------------------------------------------------------------------------------%

   
   
   %-------------------------------------------------------------------------------------%
   % Process Some Daily Data
   %-------------------------------------------------------------------------------------%
   if strcmp(out.nl.out_type,'D')
      out.X.DMEAN_NEE =  -1*out.T.DMEAN_NEP_PY * KgperSqm2TperHa /365;
   end
   %-------------------------------------------------------------------------------------%

   
   
   
   %-------------------------------------------------------------------------------------%
   % Create some monthly and yearly variables.                                           %
   %-------------------------------------------------------------------------------------%
   if sum(strcmp(out.nl.out_type,{'E','Q'}))
      %----------------------------------------------------------------------%
      % Create Reco, Het_Frac, and Soil_Resp fields                          %
      %----------------------------------------------------------------------%
      out.X.Reco       = out.T.MMEAN_PLRESP_CO + out.T.MMEAN_RH_PY;
      out.X.Het_Frac   = out.T.MMEAN_RH_PA    ./ out.X.Reco;
      out.X.Soil_Resp  = out.T.MMEAN_RH_PA     + out.T.MMEAN_ROOT_RESP_CO;

      if out.nl.c13out
         out.X.Reco_C13      = out.T.MMEAN_PLRESP_CO_C13 + out.T.MMEAN_RH_PA_C13;
         out.X.Soil_Resp_C13 = out.T.MMEAN_RH_PA_C13     + out.T.MMEAN_ROOT_RESP_CO_C13;

         out.X.Reco_d13C      = get_d13C(out.X.Reco_C13, out.X.Reco);
         out.X.Soil_Resp_d13C = get_d13C(out.X.Soil_Resp_C13,out.X.Soil_Resp);
      end
      
      %----------------------------------------------------------------------%
      % Create Monthly Mean NEE and NEE_Night
      %----------------------------------------------------------------------%
      % Get NEE and NEE_Night (in kgC/m^2)
      % These are done from cohort vars since 'Night' calc is done from cohort.
      out.X.MMEAN_NEE       = -1*(out.T.MMEAN_NPP_CO       - out.T.MMEAN_RH_PY      );
      out.X.MMEAN_NEE_Night = -1*(out.T.MMEAN_NPP_CO_Night - out.T.MMEAN_RH_PY_Night);
      
      % Convert vapor and sensible heat fluxes, NEEs, and create 'YMEAN' vars
      yrInd = 1;
      [first_yr,first_mo,~,~,~,~] = tokenize_time(out.nl.start,'ED','num');
      for fnum = 1:nfiles
         currMon = mod(first_mo + fnum - 2,12) + 1;
         currYr  = first_yr + floor((fnum + first_mo - 2)/12);
         
         fact1 = KgperSqm2TperHa * yrfrac(currMon,currYr);
         fact2 = KgperS2MJperMonth(currMon) * (-1);
         fact3 = W2MJperMonth(currMon)      * (-1);
      
         out.X.MMEAN_NEE           (fnum) = out.X.MMEAN_NEE           (fnum) *fact1;
         out.X.MMEAN_NEE_Night     (fnum) = out.X.MMEAN_NEE_Night     (fnum) *fact1;
         
         out.X.MMEAN_VAPOR_CA_PY   (fnum) = out.T.MMEAN_VAPOR_AC_PY   (fnum) *fact2;
         out.X.MMEAN_SENSIBLE_CA_PY(fnum) = out.T.MMEAN_SENSIBLE_AC_PY(fnum) *fact3;
         
         if currMon == 12 && fnum >= 12;
            out.X.YMEAN_BA            (yrInd) = sum(out.T.BA_CO(fnum-11:fnum))/12;
            out.X.YMEAN_BA_HW         (yrInd) = sum(out.H.BA_CO(fnum-11:fnum))/12;
            out.X.YMEAN_BA_CO         (yrInd) = sum(out.C.BA_CO(fnum-11:fnum))/12;
            
            out.X.YMEAN_NEE           (yrInd) = sum(out.X.MMEAN_NEE           (fnum-11:fnum));
            out.X.YMEAN_NEE_Night     (yrInd) = sum(out.X.MMEAN_NEE_Night     (fnum-11:fnum));
            out.X.YMEAN_VAPOR_CA_PY   (yrInd) = sum(out.X.MMEAN_VAPOR_CA_PY   (fnum-11:fnum));
            out.X.YMEAN_SENSIBLE_CA_PY(yrInd) = sum(out.X.MMEAN_SENSIBLE_CA_PY(fnum-11:fnum));
            yrInd = yrInd + 1;
         end
      end
   end
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
%======================================================================================%









%======================================================================================%
function [ out ] = init_out_struct(out)

%--------------------------------------------------------------------------
% Create a structure with the names we want
%--------------------------------------------------------------------------
% Patch Level (dim = ncohorts)
% Site  Level (dim = npatches)
% Grid  Level (dim = npolygons) !EXCEPT dim(TRANSLOSS) = (nzg, npoly)

% Var Shorthands:
c13 = out.nl.c13out;
spl = out.nl.splflg;

%---------- Map Flags: -------------------------------------------------------%
% Pa   = patch level
% Si   = site level
% Ed   = grid level
% C13  = has c13 analogue (assumed to be named varname_C13)
% sp   = is a 'splittable' variable (is indexed by pft)
% type = which outputs it's present in.

% Type:
%   Which output files is this var included in?
%   I - Instantaneous ONLY
%   D - Daily
%   E - Monthly
%   Q - Qmeans
%   Y - Yearly
%   T - Tower

%-----------------------------------------------------------------------------------------------
% Variable Name                   Pa , Si , Ed , C13 ,sp, type      h5 units
%-----------------------------------------------------------------------------------------------
map.AREA                      = { 0  , 1  , 0  , 0   , 0, 'YQEDI' };
map.PACO_ID                   = { 0  , 1  , 0  , 0   , 0, 'YQEDI' };
map.AGB_CO                    = { 1  , 0  , 0  , 0   , 1, 'YQED' }; % 
map.BLEAF                     = { 1  , 0  , 0  , 1   , 1, 'YQED' };
map.BROOT                     = { 1  , 0  , 0  , 1   , 1, 'YQED' };
map.BSTORAGE                  = { 1  , 0  , 0  , 1   , 1, 'YQED' };
map.BSAPWOODA                 = { 1  , 0  , 0  , 1   , 1, 'YQED' };
map.BSAPWOODB                 = { 1  , 0  , 0  , 1   , 1, 'YQED' };
map.BALIVE                    = { 1  , 0  , 0  , 1   , 1, 'YQED' };
map.BDEAD                     = { 1  , 0  , 0  , 1   , 1, 'YQED' };
map.LAI_CO                    = { 1  , 0  , 0  , 0   , 1, 'YQED' };
map.NPLANT                    = { 1  , 0  , 0  , 0   , 0, 'YQED' };
map.PFT                       = { 1  , 0  , 0  , 0   , 0, 'YQED' };
 ... %% DAILY: 
map.DMEAN_FS_OPEN_CO          = { 1  , 0  , 0  , 0   , 1, 'D' };
map.DMEAN_LEAF_RESP_CO        = { 1  , 0  , 0  , 1   , 1, 'D' };
%map.DMEAN_LASSIM_RESP_CO      = { 1  , 0  , 0  , 1   , 1, 'D' };
map.DMEAN_ROOT_RESP_CO        = { 1  , 0  , 0  , 1   , 1, 'D' };
map.DMEAN_GROWTH_RESP_CO      = { 1  , 0  , 0  , 1   , 1, 'D' };
map.DMEAN_STORAGE_RESP_CO     = { 1  , 0  , 0  , 1   , 1, 'D' };
map.DMEAN_VLEAF_RESP_CO       = { 1  , 0  , 0  , 1   , 1, 'D' };
map.DMEAN_GPP_CO              = { 1  , 0  , 0  , 1   , 1, 'D' };
map.DMEAN_NPP_CO              = { 1  , 0  , 0  , 1   , 1, 'D' };   % kgC / pl / yr
map.DMEAN_RH_PA               = { 0  , 1  , 0  , 1   , 0, 'D' };
map.DMEAN_CWD_RH_PA           = { 0  , 1  , 0  , 1   , 0, 'D' };
map.LEAF_MAINTENANCE          = { 1  , 0  , 0  , 1   , 1, 'D' };
map.ROOT_MAINTENANCE          = { 1  , 0  , 0  , 1   , 1, 'D' };
map.DMEAN_PLRESP_CO           = { 1  , 0  , 0  , 1   , 1, 'D' };   % kgC / pl / yr
map.DMEAN_NEP_PY              = { 0  , 0  , 1  , 0   , 0, 'D' };   % kgC / pl / yr
 ... %% MONTHLY:
map.BA_CO                     = { 1  , 0  , 0  , 0   , 1, 'QE' };   % cm^2
map.CB                        = { 1  , 0  , 0  , 0   , 1, 'QE' };   % kgC / pl
map.DBH                       = { 1  , 0  , 0  , 0   , 1, 'QE' };   % cm^2
map.HITE                      = { 1  , 0  , 0  , 0   , 1, 'QE' };   % m
map.MMEAN_FS_OPEN_CO          = { 1  , 0  , 0  , 0   , 1, 'QE' };
map.MMEAN_LEAF_DROP_CO        = { 1  , 0  , 0  , 0   , 1, 'QE' };
map.MMEAN_LAI_CO              = { 1  , 0  , 0  , 0   , 1, 'QE' };   % m2l / m2 grnd
map.MMEAN_BLEAF_CO            = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl
map.MMEAN_BROOT_CO            = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl
map.MMEAN_BSTORAGE_CO         = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl
map.MMEAN_LEAF_RESP_CO        = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl / yr
%map.MMEAN_LASSIM_RESP_CO      = { 1  , 0  , 0  , 1   , 1, 'QE' };
map.MMEAN_ROOT_RESP_CO        = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_GROWTH_RESP_CO      = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_STORAGE_RESP_CO     = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_VLEAF_RESP_CO       = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_GPP_CO              = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_NPP_CO              = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_NEP_PY              = { 0  , 0  , 1  , 0   , 0, 'QE' };   % kgC / pl / yr
map.MMEAN_NPPDAILY_CO         = { 1  , 0  , 0  , 0   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_NPPCROOT_CO         = { 1  , 0  , 0  , 0   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_NPPFROOT_CO         = { 1  , 0  , 0  , 0   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_NPPLEAF_CO          = { 1  , 0  , 0  , 0   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_NPPSAPWOOD_CO       = { 1  , 0  , 0  , 0   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_NPPSEEDS_CO         = { 1  , 0  , 0  , 0   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_NPPWOOD_CO          = { 1  , 0  , 0  , 0   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_PLRESP_CO           = { 1  , 0  , 0  , 1   , 1, 'QE' };   % kgC / pl / yr
map.MMEAN_RH_PA               = { 0  , 1  , 0  , 1   , 0, 'QE' };
map.MMEAN_RH_PY               = { 0  , 0  , 1  , 1   , 0, 'QE' };
map.MMEAN_CWD_RH_PA           = { 0  , 1  , 0  , 1   , 0, 'QE' };
map.MMEAN_CWD_RH_PY           = { 0  , 0  , 1  , 1   , 0, 'QE' };
map.MMEAN_FAST_SOIL_C         = { 0  , 1  , 0  , 1   , 0, 'QE' };
map.MMEAN_SLOW_SOIL_C         = { 0  , 1  , 0  , 1   , 0, 'QE' };
map.MMEAN_LEAF_MAINTENANCE_CO = { 1  , 0  , 0  , 1   , 1, 'QE' };
map.MMEAN_ROOT_MAINTENANCE_CO = { 1  , 0  , 0  , 1   , 1, 'QE' };
map.MMEAN_SENSIBLE_AC_PY      = { 0  , 0  , 0  , 0   , 1, 'QE' };   %   W / m^2
map.MMEAN_VAPOR_AC_PY         = { 0  , 0  , 0  , 0   , 1, 'QE' };   %  kg / m^2 / s
%map.MMEAN_MORT_RATE_CO       = { 0  , 0  , 0  , 0   , 1, 'QE' };   %  kg / m^2 / s
%map.BASAL_AREA_PY            = { 0  , 0  , 1  , 0   , 0, 'QE' };
map.QMEAN_NPP_CO              = { 1  , 0  , 0  , 0   , 1, 'Q' };   % kgC / pl / yr
map.QMEAN_NEP_PY              = { 0  , 0  , 1  , 0   , 1, 'Q' };   % kgC / pl / yr
map.QMEAN_PLRESP_CO           = { 1  , 0  , 0  , 0   , 1, 'Q' };   % kgC / pl / yr
map.QMEAN_RH_PY               = { 0  , 0  , 1  , 0   , 1, 'Q' };   % 
 ... %% YEARLY:
map.FAST_SOIL_C               = { 0  , 1  , 0  , 0   , 0, 'Y' };
map.SLOW_SOIL_C               = { 0  , 1  , 0  , 0   , 0, 'Y' };
map.STRUCTURAL_SOIL_C         = { 0  , 1  , 0  , 0   , 0, 'Y' };
map.STRUCTURAL_SOIL_L         = { 0  , 1  , 0  , 0   , 0, 'Y' };
map.BASAL_AREA_GROWTH         = { 0  , 0  , 0  , 0   , 0, 'Y' };   % cm^2/ m^2 / yr
map.BASAL_AREA_MORT           = { 0  , 0  , 0  , 0   , 0, 'Y' };   % cm^2/ m^2 / yr
map.TOTAL_BASAL_AREA          = { 0  , 0  , 1  , 0   , 0, 'Y' };
map.TOTAL_BASAL_AREA_GROWTH   = { 0  , 0  , 1  , 0   , 0, 'Y' };
map.TOTAL_BASAL_AREA_MORT     = { 0  , 0  , 1  , 0   , 0, 'Y' };
map.TOTAL_BASAL_AREA_RECRUIT  = { 0  , 0  , 1  , 0   , 0, 'Y' };
 ... %% TOWER:
map.FMEAN_NEP_PY              = { 0  , 0  , 1  , 0   , 0, 'T' };
map.FMEAN_VAPOR_AC_PY         = { 0  , 0  , 1  , 0   , 0, 'T' };


%% Create the data structure, using map
fields  = fieldnames(map);
nfields = numel(fields);

type = out.nl.out_type;
for i = 1:nfields
   % Only deal with variables of relevant output frequency:
   % If it's of the 'wrong' out type, cycle loop except under certain conditions.
   create_var = 0;
   token_str = map.(fields{i}){6};
   for j = 1:numel(token_str)
      token = token_str(j);
      create_var = create_var + strcmp(type,token);
   end
   
   if create_var == 0; continue; end
   
   
   out.raw.(fields{i}) = { };
   out.T.(fields{i})   = [ ];
   
   if map.(fields{i}){4} && c13 % Create basic C13 and d13C Vars
      if strcmp(fields{i}(end),'C')
         out.raw.([fields{i},'13']) = { };
         out.T.([fields{i},'13'])   = [ ];
      else
         out.raw.([fields{i},'_C13'])  = { };
         out.T.([fields{i},'_C13'])    = [ ];
      end
      out.T.([fields{i},'_d13C']) = [ ];
   end
   
   if map.(fields{i}){5} && spl % Split Variables
      out.C.(fields{i}) = [ ];
      out.H.(fields{i}) = [ ];
      out.G.(fields{i}) = [ ];
      if map.(fields{i}){4} && c13 % Split C13 Variables
         out.T.([fields{i},'_C13']) = [ ];
         out.C.([fields{i},'_C13']) = [ ];
         out.H.([fields{i},'_C13']) = [ ];
         out.G.([fields{i},'_C13']) = [ ];
         
         out.T.([fields{i},'_d13C']) = [ ];
         out.C.([fields{i},'_d13C']) = [ ];
         out.H.([fields{i},'_d13C']) = [ ];
         out.G.([fields{i},'_d13C']) = [ ];
      end
   end
   
   out.map   = map;
   out.thick = [ ];

end
end
%======================================================================================%


function [ tempVar, savname ] = scale_patch_var( out,varname,fnum,plant_intensive )

tables();
tempVar = out.raw.(varname){fnum};
currMon = mod(str2double(out.nl.start(11:12)) + fnum - 2,12) + 1;
savname = varname;

% Generating a "Night" var from a QMEAN?
if sum(strcmp(varname,{'QMEAN_NPP_CO','QMEAN_PLRESP_CO','QMEAN_RH_PY'}))
   savname = ['MMEAN' varname(6:end) '_Night'];
   tempMsk = logical(month_night_hrs{mod(fnum+4,12)+1}');
   tempDiv = sum(tempMsk); 
   tempVar = out.raw.(varname){fnum}(tempMsk,:);
   tempVar = out.raw.NPLANT{fnum}.*sum(tempVar,1)'/tempDiv;
end

if strcmp(varname,'CB')
   tempVar = out.raw.NPLANT{fnum}.*out.raw.(varname){fnum}(currMon,:)';
   plant_intensive = 0;
end

if plant_intensive
   % For plant intensive vars, we need to rescale by NPLANT
   tempVar = out.raw.NPLANT{fnum}.* tempVar;
end

%------------------------------------------------------------------------%
% Associate a patch ID with each cohort, then rescale cohorts in a patch
% by the area of that patch relative to the total. (The sum of AREA{fnum}
% for any fnum is 1.)
%------------------------------------------------------------------------%
larea = length(out.raw.AREA{fnum});
for patch_num = 1:larea-1
   ind1 = out.raw.PACO_ID{fnum}(patch_num);
   ind2 = out.raw.PACO_ID{fnum}(patch_num+1);
   tempVar(ind1:ind2-1) = out.raw.AREA{fnum}(patch_num)*tempVar(ind1:ind2-1);
end

ind               = out.raw.PACO_ID{fnum}(larea);
tempVar(ind:end)  = out.raw.AREA   {fnum}(larea)*tempVar(ind:end);
%------------------------------------------------------------------------%

end

function [ out ] = process_split(out,savname,fnum,tempVar)

out.C.(savname)(fnum) = 0.0;
out.H.(savname)(fnum) = 0.0;
out.G.(savname)(fnum) = 0.0;
for k=1:length(tempVar)
   if sum(out.raw.PFT{fnum}(k) == [6,7,8] > 0)
      out.C.(savname)(fnum) = out.C.(savname)(fnum) + tempVar(k);
   elseif sum(out.raw.PFT{fnum}(k) == [9,10,11] > 0)
      out.H.(savname)(fnum) = out.H.(savname)(fnum) + tempVar(k);
   elseif out.raw.PFT{fnum}(k) == 5
      out.G.(savname)(fnum) = out.G.(savname)(fnum) + tempVar(k);
   end
end

end
