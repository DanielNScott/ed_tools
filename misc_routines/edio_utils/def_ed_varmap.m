function [ map ] = def_ed_varmap( )
%DEFINE_VARMAP Summary of this function goes here
%   Detailed explanation goes here

% Patch Level (dim = ncohorts)
% Site  Level (dim = npatches)
% Grid  Level (dim = npolygons) !EXCEPT dim(TRANSLOSS) = (nzg, npoly)


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
% Variable Name               = {Type, C13, Split-able, Resolution}   % Out Units
%-----------------------------------------------------------------------------------------------
map.AREA                      = {'si', 0  , 0, 'YQEDI'};
map.PACO_ID                   = {'si', 0  , 0, 'YQEDI'};
map.AGB_CO                    = {'pa', 1  , 1, 'YQED' };
map.BLEAF                     = {'pa', 1  , 1, 'YQED' };
map.BROOT                     = {'pa', 1  , 1, 'YQED' };
map.BSTORAGE                  = {'pa', 1  , 1, 'YQED' };
map.BSAPWOODA                 = {'pa', 1  , 1, 'YQED' };
map.BSAPWOODB                 = {'pa', 1  , 1, 'YQED' };
map.BALIVE                    = {'pa', 1  , 1, 'YQED' };
map.BDEAD                     = {'pa', 1  , 1, 'YQED' };
map.LAI_CO                    = {'pa', 0  , 1, 'YQED' };
map.NPLANT                    = {'pa', 0  , 0, 'YQED' };
map.PFT                       = {'pa', 0  , 0, 'YQED' };
 ... %% DAILY: 
map.DMEAN_FS_OPEN_CO          = {'pa', 0  , 1, 'D' };
map.DMEAN_LEAF_RESP_CO        = {'pa', 1  , 1, 'D' };
%map.DMEAN_LASSIM_RESP_CO     = {'pa', 1  , 1, 'D' };
map.DMEAN_ROOT_RESP_CO        = {'pa', 1  , 1, 'D' };
map.DMEAN_GROWTH_RESP_CO      = {'pa', 1  , 1, 'D' };
map.DMEAN_STORAGE_RESP_CO     = {'pa', 1  , 1, 'D' };
map.DMEAN_VLEAF_RESP_CO       = {'pa', 1  , 1, 'D' };
map.DMEAN_GPP_CO              = {'pa', 1  , 1, 'D' };
map.DMEAN_NPP_CO              = {'pa', 1  , 1, 'D' };   % kgC /pl /yr
map.DMEAN_RH_PA               = {'si', 1  , 0, 'D' };
map.DMEAN_CWD_RH_PA           = {'si', 1  , 0, 'D' };
map.LEAF_MAINTENANCE          = {'pa', 1  , 1, 'D' };
map.ROOT_MAINTENANCE          = {'pa', 1  , 1, 'D' };
map.DMEAN_PLRESP_CO           = {'pa', 1  , 1, 'D' };   % kgC /pl /yr
map.DMEAN_NEP_PY              = {'ed', 0  , 0, 'D' };   % kgC /pl /yr
 ... %% MONTHLY:
map.BA_CO                     = {'pa', 0  , 1, 'QE'};   % cm^2
map.CB                        = {'pa', 0  , 1, 'QE'};   % kgC /pl
map.DBH                       = {'pa', 0  , 1, 'QE'};   % cm^2
map.HITE                      = {'pa', 0  , 1, 'QE'};   % m
map.MMEAN_FS_OPEN_CO          = {'pa', 0  , 1, 'QE'};
map.MMEAN_LEAF_DROP_CO        = {'pa', 0  , 1, 'QE'};
map.MMEAN_LAI_CO              = {'pa', 0  , 1, 'QE'};   % m2l /m2 grnd
map.MMEAN_BLEAF_CO            = {'pa', 1  , 1, 'QE'};   % kgC /pl
map.MMEAN_BROOT_CO            = {'pa', 1  , 1, 'QE'};   % kgC /pl
map.MMEAN_BSTORAGE_CO         = {'pa', 1  , 1, 'QE'};   % kgC /pl
map.MMEAN_LEAF_RESP_CO        = {'pa', 1  , 1, 'QE'};   % kgC /pl /yr
%map.MMEAN_LASSIM_RESP_CO     = {'pa', 1  , 1, 'QE'};
map.MMEAN_ROOT_RESP_CO        = {'pa', 1  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_GROWTH_RESP_CO      = {'pa', 1  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_STORAGE_RESP_CO     = {'pa', 1  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_VLEAF_RESP_CO       = {'pa', 1  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_GPP_CO              = {'pa', 1  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_NPP_CO              = {'pa', 1  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_NEP_PY              = {'ed', 0  , 0, 'QE'};   % kgC /pl /yr
map.MMEAN_NPPDAILY_CO         = {'pa', 0  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_NPPCROOT_CO         = {'pa', 0  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_NPPFROOT_CO         = {'pa', 0  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_NPPLEAF_CO          = {'pa', 0  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_NPPSAPWOOD_CO       = {'pa', 0  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_NPPSEEDS_CO         = {'pa', 0  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_NPPWOOD_CO          = {'pa', 0  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_PLRESP_CO           = {'pa', 1  , 1, 'QE'};   % kgC /pl /yr
map.MMEAN_RH_PA               = {'si', 1  , 0, 'QE'};
map.MMEAN_RH_PY               = {'ed', 0  , 0, 'QE'};
map.MMEAN_CWD_RH_PA           = {'si', 1  , 0, 'QE'};
map.MMEAN_CWD_RH_PY           = {'ed', 0  , 0, 'QE'};
map.MMEAN_FAST_SOIL_C         = {'si', 1  , 0, 'QE'};
map.MMEAN_SLOW_SOIL_C         = {'si', 1  , 0, 'QE'};
map.MMEAN_LEAF_MAINTENANCE_CO = {'pa', 1  , 1, 'QE'};
map.MMEAN_ROOT_MAINTENANCE_CO = {'pa', 1  , 1, 'QE'};
map.MMEAN_SENSIBLE_AC_PY      = {'un', 0  , 1, 'QE'};   %   W /m^2
map.MMEAN_VAPOR_AC_PY         = {'un', 0  , 1, 'QE'};   %  kg /m^2 /s
%map.MMEAN_MORT_RATE_CO       = {'un', 0  , 1, 'QE'};   %  kg /m^2 /s
%map.BASAL_AREA_PY            = {'ed', 0  , 0, 'QE'};
map.QMEAN_NPP_CO              = {'pa', 0  , 1, 'Q' };   % kgC /pl /yr
map.QMEAN_NEP_PY              = {'ed', 0  , 1, 'Q' };   % kgC /pl /yr
map.QMEAN_PLRESP_CO           = {'pa', 0  , 1, 'Q' };   % kgC /pl /yr
map.QMEAN_RH_PY               = {'ed', 0  , 1, 'Q' };   % 
 ... %% YEARLY:
map.FAST_SOIL_C               = {'si', 0  , 0, 'Y' };
map.SLOW_SOIL_C               = {'si', 0  , 0, 'Y' };
map.STRUCTURAL_SOIL_C         = {'si', 0  , 0, 'Y' };
map.STRUCTURAL_SOIL_L         = {'si', 0  , 0, 'Y' };
map.BASAL_AREA_GROWTH         = {'un', 0  , 0, 'Y' };   % cm^2 /m^2 /yr
map.BASAL_AREA_MORT           = {'un', 0  , 0, 'Y' };   % cm^2 /m^2 /yr
map.TOTAL_BASAL_AREA          = {'ed', 0  , 0, 'Y' };
map.TOTAL_BASAL_AREA_GROWTH   = {'ed', 0  , 0, 'Y' };
map.TOTAL_BASAL_AREA_MORT     = {'ed', 0  , 0, 'Y' };
map.TOTAL_BASAL_AREA_RECRUIT  = {'ed', 0  , 0, 'Y' };
 ... %% TOWER:
map.FMEAN_NEP_PY              = {'ed', 0  , 0, 'T' };
map.FMEAN_VAPOR_AC_PY         = {'ed', 0  , 0, 'T' };

end

