%======================================================================================%
function [ out ] = import_poly( varargin )
%IMPORT_POLY reads HDF5 files, either with information given in the input in the form of a
%directory plus timeframe info or with information set below as a default.
%   Detailed explanation goes here
   
   dbug = 0;
   if nargin >= 1
      out.nl = varargin{1};
         if nargin == 2
            dbug = varargin{2};
         end
   else
      out.nl.f_type   = 'hf_caf1';
      out.nl.out_type = 'T';
      out.nl.dir      = 'C:\Users\Dan\Workspace - Matlab\Moorcroft Lab\hf_caf1\';
      out.nl.splflg   = 1;
      out.nl.c13out   = 1;

      % Format        = 'hhmmss-dd-mm-yyyy'
      out.nl.start    = '2010-06-01-000000';
      out.nl.end      = '2013-01-01-000000';
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
   
   map = def_ed_varmap();
   
   disp('Importing model output using import_poly.m...')
   out      = init_out_struct (out,map);
   out.raw  = read_vars       (out.raw,fnames,out.nl.out_type,dbug);
   out      = process_vars    (out,fnames,out.nl.out_type,map,dbug);
   out.desc = 'Created with import_poly using nl in (this).nl';

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
        if strcmp(flds{ifld},'SLZ'   ); continue            ; end
        if strcmp(flds{ifld},'nl'    ); continue            ; end
        if strcmp(flds{ifld},'map'   ); continue            ; end
        if strcmp(flds{ifld},'T'     ); continue            ; end
        if strcmp(flds{ifld},'Co'    ); continue            ; end
        if strcmp(flds{ifld},'Hw'    ); continue            ; end
        if strcmp(flds{ifld},'Gr'    ); continue            ; end
        if strcmp(flds{ifld},'thick' ); continue            ; end
        if strcmp(flds{ifld},'raw'   ); continue            ; end
        
        if dbug > 1; disp([' - Reading Var: ',flds{ifld}])  ; end
        dset_id = H5D.open(f_id,flds{ifld});
        ofld.(flds{ifld}){ifile} = H5D.read(dset_id,mem_type_id,mem_space_id,file_space_id,dxpl);
        H5D.close(dset_id)
    end
end
end
%======================================================================================%


%======================================================================================%
function [ out ] = process_vars(out,fnames,res,map,dbug)

   %----------------------------------------------------------------------%
   % Some set up...                                                       %
   %----------------------------------------------------------------------%
   nfiles   = length(fnames);          %
   flds     = fieldnames(out.raw);     % 
   read_c13 = out.nl.c13out;
   splt_flg = out.nl.splflg;
   tables();                           % Import tables for QMEAN night time mask

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
      
      %--- Cycle through vars -----------------------------------------------
      for varnum = 1:numel(flds)
         varname = flds{varnum};       % Load & save most vars by their names...
         savname = varname;            % ...but save vars we manipulate alot w/ different names.
         
         % This var flags output vars which are scaled (in the HDF5) by nplant.
         % Currently, there is only one other kind of variable (LAI) that we process
         % differently; Its output is m2/m2, which we want to keep, take weighted avg.
         plant_intensive = 1;
         
         % Exceptions: For these vars either skip this entire block or
         % skip some portion of it.
         if strcmp(varname,'NPLANT'       ); continue; end
         if strcmp(varname,'PFT'          ); continue; end
         if strcmp(varname,'SLZ'          ); continue; end
         if strcmp(varname,'AREA'         ); continue; end
         if strcmp(varname,'PACO_ID'      ); continue; end
         if strcmp(varname,'nl'           ); continue; end
         if strcmp(varname,'map'          ); continue; end
         if strcmp(varname,'T'            ); continue; end
         if strcmp(varname,'Co'           ); continue; end
         if strcmp(varname,'Hw'           ); continue; end
         if strcmp(varname,'Gr'           ); continue; end
         if strcmp(varname,'thick'        ); continue; end
         if strcmp(varname,'raw'          ); continue; end
         if any(strfind(varname,'C13')    ); continue; end
         if any(strfind(varname,'13C')    ); continue; end
         if any(strfind(varname,'ARBON13')); continue; end
         
         if strcmp(varname,'LAI_CO'       ); plant_intensive = 0  ; end
         if strcmp(varname,'MMEAN_LAI_CO' ); plant_intensive = 0  ; end
         
         vartype    = map.(varname){1};         % Variable type, ie patch up to grid.
         anlg_exist = map.(varname){2};         % C13 version exists? Boolean
         splt_poss  = map.(varname){3};         % Split-By-PFT is possible? Boolean
         
         %Process Patch Vars -----------------------------------------------
         if strcmp(vartype,'pa')
            if dbug > 1; disp([' - Processing Pa Var: ', varname]); end

            % Scale the patch var...
            [std_var,savname] = scale_patch_var(out,varname,fnum,plant_intensive);

            % Sum the rescaled variables to get the total.
            out.T.(savname)(fnum) = sum(std_var);

            % PROCESS SPLIT -----------------------------------------------
            if splt_flg && splt_poss
               if dbug > 2; disp('    - Processing Split'); end
               out = process_split(out,savname,fnum,std_var,'sum');
            end
            
            % DETERMINE R AND DELTA, but only if c13out == 1 -----------------%
            if read_c13 && anlg_exist
               [c13name, delname] = get_iso_name(varname);
               [c13_var, c13name] = scale_patch_var(out,c13name,fnum,plant_intensive);
               
               del_var = get_d13C(c13_var,std_var);

               out.T.(c13name)(fnum) = sum(c13_var);
               out.T.(delname)(fnum) = get_d13C(out.T.(c13name)(fnum),out.T.(varname)(fnum));
               
               % PROCESS SPLIT -----------------------------------------------
               if splt_flg && splt_poss
                  if dbug > 2; disp('    - Processing Split'); end
                  out = process_split(out,c13name,fnum,c13_var,'sum');
                  out = process_split(out,delname,fnum,del_var,'avg');
               end
               
            end
            
         %Process Site Vars -----------------------------------------------
         elseif strcmp(vartype,'si')
            if dbug > 1; disp([' - Processing Si Var: ',varname]); end
            out.T.(varname)(fnum) = out.raw.AREA{fnum}'*out.raw.(varname){fnum};
            
            if read_c13 && anlg_exist
               [c13name, delname] = get_iso_name(varname);
               
               var     = out.T.(varname)(fnum);
               var_C13 = out.raw.AREA{fnum}'*out.raw.(c13name){fnum};
               
               out.T.(c13name)(fnum) = var_C13;
               out.T.(delname)(fnum) = get_d13C(var_C13,var);
            end
         
         %Process Ed Vars -----------------------------------------------
         elseif strcmp(vartype,'ed')
            if dbug > 1; disp([' - Processing Ed Var: ',varname]); end
            if any(strcmp(map.(varname){4},'Q'))
               savname = ['MMEAN' varname(6:end) '_Night'];
               tempMsk = logical(month_night_hrs{mod(fnum+4,12)+1}');
               tempDiv = sum(tempMsk); 
               tempVar = out.raw.(varname){fnum}(tempMsk);
               tempVar = sum(tempVar,1)'/tempDiv;
               out.T.(savname)(fnum) = tempVar;
            else
               out.T.(savname) = [out.T.(savname), out.raw.(varname){fnum} ];
               %out.T.(savname)(fnum) = out.raw.(varname){fnum};
               
               if read_c13 && anlg_exist
                  [c13name, delname] = get_iso_name(varname);

                  var     = out.raw.(varname){fnum};
                  var_C13 = out.raw.(c13name){fnum};

                  out.T.(c13name) = [out.T.(c13name), var_C13];
                  out.T.(delname) = [out.T.(delname), get_d13C(var_C13,var)];
               end
            end
            
         %Process Uncatagorized Vars -------------------------------------
         elseif strcmp(vartype,'un')
            if dbug > 1; disp([' - Processing Uncat Var: ',varname]); end
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
      nee_fact = KgperSqm2TperHa /365/24;
     
      out.X.FMEAN_NEE                     = -1*out.T.FMEAN_NEP_PY * nee_fact;
      out.X.FMEAN_NEE_Night               = -1*out.T.FMEAN_NEP_PY * nee_fact;
      out.X.FMEAN_NEE_Day                 = -1*out.T.FMEAN_NEP_PY * nee_fact;
      
      out.X.FMEAN_Soil_Resp  = (out.T.FMEAN_RH_PY + out.T.FMEAN_ROOT_RESP_PY) * nee_fact;
      
      out.X.FMEAN_NEE_Night(:,~night_msk) = NaN;
      out.X.FMEAN_NEE_Day(:,night_msk)    = NaN;

      if read_c13
         out.X.FMEAN_NEE_ISOFLX       = out.X.FMEAN_NEE       .*out.T.FMEAN_NEP_d13C_PY;
         out.X.FMEAN_NEE_ISOFLX_Night = out.X.FMEAN_NEE_Night .*out.T.FMEAN_NEP_d13C_PY;
         out.X.FMEAN_NEE_ISOFLX_Day   = out.X.FMEAN_NEE_Day   .*out.T.FMEAN_NEP_d13C_PY;

         out.X.FMEAN_NEE_ISOFLX_Night(:,~night_msk) = NaN;
         out.X.FMEAN_NEE_ISOFLX_Day(:,night_msk)    = NaN;
         
         out.X.FMEAN_NEE_d13C       = out.T.FMEAN_NEP_d13C_PY;
         out.X.FMEAN_NEE_d13C_Night = out.T.FMEAN_NEP_d13C_PY;
         out.X.FMEAN_NEE_d13C_Day   = out.T.FMEAN_NEP_d13C_PY;

         out.X.FMEAN_NEE_d13C_Night(:,~night_msk) = NaN;
         out.X.FMEAN_NEE_d13C_Day(:,night_msk)    = NaN;
         
         out.X.FMEAN_Soil_Resp_C13  = (out.T.FMEAN_RH_C13_PY ...
                                    +  out.T.FMEAN_ROOT_RESP_C13_PY) * nee_fact;
         out.X.FMEAN_Soil_Resp_d13C = get_d13C(out.X.FMEAN_Soil_Resp_C13,...
                                               out.X.FMEAN_Soil_Resp);
      end
      
      out.X.FMEAN_VAPOR_CA_PY           = -1*out.T.FMEAN_VAPOR_AC_PY * 1000 * 2.260;

   end
   %-------------------------------------------------------------------------------------%
   
   
   %-------------------------------------------------------------------------------------%
   % Process Some Daily Data
   %-------------------------------------------------------------------------------------%
   if strcmp(out.nl.out_type,'D')
      nee_fact = KgperSqm2TperHa /365;
      out.X.DMEAN_Soil_Resp  = (out.T.DMEAN_RH_PA + out.T.DMEAN_ROOT_RESP_CO) * nee_fact;
      out.X.DMEAN_NEE =  -1*out.T.DMEAN_NEP_PY * nee_fact;
      
      if read_c13
         out.X.DMEAN_Soil_Resp_C13  = (out.T.DMEAN_RH_C13_PA ...
                                    +  out.T.DMEAN_ROOT_RESP_C13_CO) * nee_fact;
         out.X.DMEAN_Soil_Resp_d13C = get_d13C(out.X.DMEAN_Soil_Resp_C13,...
                                               out.X.DMEAN_Soil_Resp);
      end
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

      if read_c13
         out.X.Reco_C13      = out.T.MMEAN_PLRESP_C13_CO + out.T.MMEAN_RH_C13_PA;
         out.X.Soil_Resp_C13 = out.T.MMEAN_RH_C13_PA     + out.T.MMEAN_ROOT_RESP_C13_CO;

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
function [ out ] = init_out_struct(out,map)
% Creates a structure 'out' with the fields we want it to have, based on 'map'

read_c13  = out.nl.c13out;
splt_flg  = out.nl.splflg;
fields    = fieldnames(map);
nfields   = numel(fields);
type      = out.nl.out_type;
out.thick = [ ];

for i = 1:nfields
   %-------------------------------------------------------------------------------------------%
   % Initialize some things...                                                                 %
   %-------------------------------------------------------------------------------------------%
   vname      = fields{i};                                  % Short-hand the variable name
   anlg_exist = map.(vname){2};                             % Boolean, "c13 analog exists" 
   splt_poss  = map.(vname){3};                             % Boolean, var can be split by pft?
   %-------------------------------------------------------------------------------------------%

   
   %-------------------------------------------------------------------------------------------%
   % Only deal with variables of relevant output frequency:
   % If it's of the 'wrong' out type, cycle loop except under certain conditions.
   %-------------------------------------------------------------------------------------------%
   create_var = 0;
   token_str  = map.(vname){4};
   for j = 1:numel(token_str)
      token      = token_str(j);
      create_var = create_var + strcmp(type,token);
   end
   
   if create_var == 0; continue; end
   %-------------------------------------------------------------------------------------------%

   
   %-------------------------------------------------------------------------------------------%
   % Create basic C13 and d13C Vars                                                            %
   %-------------------------------------------------------------------------------------------%
   out.raw.(vname) = { };                                   % Flds for raw hdf5 reads
   out.T.(vname)   = [ ];                                   % Vars with no pft splitting done
   
   if anlg_exist && read_c13
      % Get the fieldnames for C-13 and Del-13C vars.
      [c13_name, d13C_name] = get_iso_name(vname);

      % Create the fields.
      out.raw.(c13_name) = { };
      out.T.(c13_name)   = [ ];
      out.T.(d13C_name)  = [ ];
   end
   %-------------------------------------------------------------------------------------------%
   

   
   %-------------------------------------------------------------------------------------------%
   % Create by-pft-class split fields.                                                         % 
   %-------------------------------------------------------------------------------------------%
   if splt_poss && splt_flg
      out.C.(vname) = [ ];
      out.H.(vname) = [ ];
      out.G.(vname) = [ ];
      
      if anlg_exist && read_c13
         out.T.(c13_name) = [ ];
         out.C.(c13_name) = [ ];
         out.H.(c13_name) = [ ];
         out.G.(c13_name) = [ ];
         
         out.T.(d13C_name) = [ ];
         out.C.(d13C_name) = [ ];
         out.H.(d13C_name) = [ ];
         out.G.(d13C_name) = [ ];
      end
   end
   %-------------------------------------------------------------------------------------------%

end
end
%==============================================================================================%





%==============================================================================================%
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
%==============================================================================================%






%==============================================================================================%
function [ out ] = process_split(out,savname,fnum,tempVar,norm_cond)

co_cnt = 0;
hw_cnt = 0;
gr_cnt = 0;

out.C.(savname)(fnum) = 0.0;
out.H.(savname)(fnum) = 0.0;
out.G.(savname)(fnum) = 0.0;
for k=1:length(tempVar)
   if sum(out.raw.PFT{fnum}(k) == [6,7,8] > 0)
      out.C.(savname)(fnum) = out.C.(savname)(fnum) + tempVar(k);
      co_cnt = co_cnt + 1;
   elseif sum(out.raw.PFT{fnum}(k) == [9,10,11] > 0)
      out.H.(savname)(fnum) = out.H.(savname)(fnum) + tempVar(k);
      hw_cnt = hw_cnt + 1;
   elseif out.raw.PFT{fnum}(k) == 5
      out.G.(savname)(fnum) = out.G.(savname)(fnum) + tempVar(k);
      gr_cnt = gr_cnt + 1;
   end
end

if  strcmp(norm_cond,'avg')
   out.C.(savname)(fnum) = out.C.(savname)(fnum)/co_cnt;
   out.H.(savname)(fnum) = out.H.(savname)(fnum)/hw_cnt;
   out.G.(savname)(fnum) = out.G.(savname)(fnum)/gr_cnt;
end

end
%==============================================================================================%
