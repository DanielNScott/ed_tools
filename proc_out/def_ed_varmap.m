function [ map ] = def_ed_varmap(ml_vars)
%DEFINE_VARMAP Summary of this function goes here
%   Detailed explanation goes here

%---------- Map Field Elements: ---------------------------------------------------------------%
% type          = Is this a patch, site, polygon, or grid var?
% C13           = has c13 analogue (assumed to be named varname_C13)
% sp            = is a 'splittable' variable (is indexed by pft)
% res           = which outputs it's present in.
% h5units       = the units as the variable comes from an h5 file
% process units = the units to give it in it's processed state

% Res flags:
%   Which output files is this var included in?
%   I - Instantaneous ONLY
%   D - Daily
%   E - Monthly
%   Q - Qmeans
%   Y - Yearly
%   T - Tower

%-----------------------------------------------------------------------------------------------
% Variable Name               = {Type, C13, Split-able, Resolution, h5units, process units}
%-----------------------------------------------------------------------------------------------
map.AGB_CO                    = {'pa', 0  , 1, 'YQED' ,  'kgC/pl' , 'kgC/m2'  };
map.NPLANT                    = {'pa', 0  , 0, 'YQEDI',  ''       , ''        };
map.PFT                       = {'pa', 0  , 0, 'YQEDI',  ''       , ''        };
map.AREA                      = {'si', 0  , 0, 'YQEDI',  ''       , ''        };
map.PACO_ID                   = {'si', 0  , 0, 'YQEDI',  ''       , ''        };
map.LAI_CO                 = {'pa', 0  , 1, 'YQEDI' ,  ''       , ''        };
%map.BLEAF_PY               = {'ed', 1  , 0, 'DI'   ,  'kgC/pl' , 'kgC/m2'  };
%map.BROOT_PY               = {'ed', 1  , 0, 'DI'   ,  'kgC/pl' , 'kgC/m2'  };
%map.BSTORAGE_PY            = {'ed', 1  , 0, 'DI'   ,  'kgC/pl' , 'kgC/m2'  };
map.FAST_SOIL_C_PY         = {'ed', 1  , 0, 'DI'   ,  'kgC/m2' , 'kgC/m2'  };
map.SLOW_SOIL_C_PY         = {'ed', 1  , 0, 'DI'   ,  'kgC/m2' , 'kgC/m2'  };
map.STRUCTURAL_SOIL_C_PY   = {'ed', 1  , 0, 'DI'   ,  'kgC/m2' , 'kgC/m2'  };
...
... %%------------ TOWER: -----------------%%
map.FMEAN_RH_PA                = {'si', 1  , 0, 'TI' };
map.FMEAN_CWD_RH_PA            = {'si', 1  , 0, 'TI',   ''          , ''           };
map.FMEAN_CSTAR_PA             = {'si', 1  , 0, 'TI',  'umol/mol'  , 'umol/mol'   };
map.FMEAN_CAN_CO2_PA           = {'si', 1  , 0, 'TI',  'umol/mol'  , 'umol/mol'   };
map.FMEAN_CARBON_AC_PA         = {'si', 1  , 0, 'TI',  'umol/mol'  , 'umol/mol'   };
map.FMEAN_CARBON_ST_PA         = {'si', 1  , 0, 'TI',  'umol/mol'  , 'umol/mol'   };
...
map.FMEAN_GPP_PY               = {'ed', 1  , 0, 'TI',  'kgC/m2/yr' , 'kgC/m2/yr'  };
map.FMEAN_NEP_PY               = {'ed', 1  , 0, 'TI',  'kgC/m2/yr' , 'kgC/m2/yr'  };
map.FMEAN_NPP_PY               = {'ed', 1  , 0, 'TI',  'kgC/m2/yr' , 'kgC/m2/yr'  };
map.FMEAN_VAPOR_AC_PY          = {'ed', 0  , 0, 'TI' };
map.FMEAN_SENSIBLE_AC_PY       = {'ed', 0  , 0, 'TI' };
map.FMEAN_RH_PY                = {'ed', 1  , 0, 'TI' };
map.FMEAN_LEAF_RESP_PY         = {'ed', 1  , 0, 'TI' };
map.FMEAN_ROOT_RESP_PY         = {'ed', 1  , 0, 'TI' };

map.FMEAN_LEAF_GROWTH_RESP_PY  = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_ROOT_GROWTH_RESP_PY  = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_SAPA_GROWTH_RESP_PY  = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_SAPB_GROWTH_RESP_PY  = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_LEAF_STORAGE_RESP_PY = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_ROOT_STORAGE_RESP_PY = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_SAPA_STORAGE_RESP_PY = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_SAPB_STORAGE_RESP_PY = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_STORAGE_RESP_PY      = {'ed', 1  , 1, 'TI',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_SOIL_WATER_PY        = {'ed', 0  , 0, 'TI',   'm3/m3'     , 'm3/m3'     };
...
... %%------------ Fast not Tower: ------------%%
map.FMEAN_FS_OPEN_CO           = {'pa', 0  , 0, 'I',   'None'      , 'None'       };
map.FMEAN_LEAF_RESP_CO         = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_ROOT_RESP_CO         = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_GPP_CO               = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_NPP_CO               = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_PLRESP_CO            = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2'     };
map.FMEAN_ATM_CO2_PY           = {'ed', 1  , 0, 'I',   'umol/mol'  , 'umol/mol'   };
...
... %%------------ DAILY: ------------%%
map.DMEAN_FS_OPEN_CO           = {'pa', 0  , 1, 'D',   ''          , ''           };
map.DMEAN_LEAF_RESP_CO         = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_ROOT_RESP_CO         = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_GROWTH_RESP_CO       = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_LEAF_GROWTH_RESP_CO  = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_ROOT_GROWTH_RESP_CO  = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_SAPA_GROWTH_RESP_CO  = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_SAPB_GROWTH_RESP_CO  = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_LEAF_STORAGE_RESP_CO = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_ROOT_STORAGE_RESP_CO = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_SAPA_STORAGE_RESP_CO = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_SAPB_STORAGE_RESP_CO = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_STORAGE_RESP_CO      = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_GPP_CO               = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_NPP_CO               = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
...
map.DMEAN_NPPDAILY_CO          = {'pa', 0  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_NPPCROOT_CO          = {'pa', 0  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_NPPFROOT_CO          = {'pa', 0  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_NPPLEAF_CO           = {'pa', 0  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_NPPSAPWOOD_CO        = {'pa', 0  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_NPPSEEDS_CO          = {'pa', 0  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_NPPWOOD_CO           = {'pa', 0  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_PLRESP_CO            = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2'     };
...
map.AVG_DAILY_TEMP             = {'si', 0  , 0, 'D',   ''          , ''           };
map.DMEAN_RH_PA                = {'si', 1  , 0, 'D',   ''          , ''           };
map.DMEAN_CWD_RH_PA            = {'si', 1  , 0, 'D',   ''          , ''           };
...
map.DMEAN_NEP_PY               = {'ed', 1  , 0, 'D',   'kgC/m2/yr' , 'kgC/m2/yr'  };
...
... %%------------ MONTHLY: ------------%%
map.BA_CO                      = {'pa', 0  , 1, 'QE',  'cm2'       , 'cm2'        };
map.CB                         = {'pa', 0  , 1, 'QE',  'kgC/pl'    , 'kgC/m2'     };
map.DBH                        = {'pa', 0  , 1, 'QE',  'cm2'       , 'cm2'        };
map.HITE                       = {'pa', 0  , 1, 'QE',  'm'         , 'm'          };
map.MMEAN_FS_OPEN_CO           = {'pa', 0  , 1, 'QE',  ''          , ''           };
map.MMEAN_LEAF_DROP_CO         = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_LAI_CO               = {'pa', 0  , 1, 'QE',  'm2l/m2'    , 'm2l/m2'     };
map.MMEAN_BLEAF_CO             = {'pa', 1  , 1, 'QE',  'kgC/pl'    , 'kgC/m2'     };
map.MMEAN_BROOT_CO             = {'pa', 1  , 1, 'QE',  'kgC/pl'    , 'kgC/m2'     };
map.MMEAN_BSTORAGE_CO          = {'pa', 1  , 1, 'QE',  'kgC/pl'    , 'kgC/m2'     };
map.MMEAN_LEAF_RESP_CO         = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_LEAF_MAINTENANCE_CO  = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_ROOT_MAINTENANCE_CO  = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_ROOT_RESP_CO         = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_GROWTH_RESP_CO       = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_LEAF_GROWTH_RESP_CO  = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_ROOT_GROWTH_RESP_CO  = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_SAPA_GROWTH_RESP_CO  = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_SAPB_GROWTH_RESP_CO  = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_LEAF_STORAGE_RESP_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_ROOT_STORAGE_RESP_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_SAPA_STORAGE_RESP_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_SAPB_STORAGE_RESP_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_STORAGE_RESP_CO      = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_FSN_CO               = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_GPP_CO               = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPP_CO               = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPDAILY_CO          = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPCROOT_CO          = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPFROOT_CO          = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPLEAF_CO           = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPSAPWOOD_CO        = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPSEEDS_CO          = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPWOOD_CO           = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_PLRESP_CO            = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
...
map.MMEAN_RH_PA                = {'si', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_CWD_RH_PA            = {'si', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_FAST_SOIL_N          = {'si', 0  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_FAST_SOIL_C          = {'si', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_SLOW_SOIL_C          = {'si', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
...
map.MMEAN_SENSIBLE_AC_PY       = {'un', 0  , 1, 'QE',  'W/m2'      , 'W/m2'       };
map.MMEAN_VAPOR_AC_PY          = {'un', 0  , 1, 'QE',  'kgH2O/m2/s', 'kgH2O/m2/s' };
%map.MMEAN_MORT_RATE_CO         = {'pa', 0  , 1, 'QE'};
...
map.BASAL_AREA_PY              = {'ed', 0  , 0, 'QE'};
map.MMEAN_NEP_PY               = {'ed', 1  , 0, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_RH_PY                = {'ed', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_CWD_RH_PY            = {'ed', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_MINERAL_SOIL_N_PY    = {'ed', 0  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
...
... %%------------ QMEANS: ------------%%
map.QMEAN_NPP_CO               = {'pa', 0  , 1, 'Q' ,  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.QMEAN_PLRESP_CO            = {'pa', 0  , 1, 'Q' ,  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.QMEAN_NEP_PY               = {'ed', 0  , 1, 'Q' ,  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.QMEAN_RH_PY                = {'ed', 0  , 1, 'Q' ,  'kgC/m2'    , 'kgC/m2'     };
...
... %%------------ YEARLY: ------------%%
map.STRUCTURAL_SOIL_L          = {'si', 0  , 0, 'Y' ,  'kgL/m2'    , 'kgL/m2'     };
map.BASAL_AREA_GROWTH          = {'un', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.BASAL_AREA_MORT            = {'un', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.TOTAL_BASAL_AREA           = {'ed', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.TOTAL_BASAL_AREA_GROWTH    = {'ed', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.TOTAL_BASAL_AREA_MORT      = {'ed', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.TOTAL_BASAL_AREA_RECRUIT   = {'ed', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
%**These are in yearly output, but don't want to overwrite them when reading everything


%%----------- Vars that differ between the mainline and ED-ISO ----------%%
if ml_vars
   map.BLEAF                  = {'pa', 1  , 1, 'YQEDI' ,  'kgC/pl' , 'kgC/m2'  };
   map.BROOT                  = {'pa', 1  , 1, 'YQEDI' ,  'kgC/pl' , 'kgC/m2'  };
   map.BSTORAGE               = {'pa', 1  , 1, 'YQEDI' ,  'kgC/pl' , 'kgC/m2'  };
   map.BSAPWOODA              = {'pa', 1  , 1, 'YQEDI' ,  'kgC/pl' , 'kgC/m2'  }; %**
   map.BSAPWOODB              = {'pa', 1  , 1, 'YQEDI' ,  'kgC/pl' , 'kgC/m2'  }; %**
   map.BALIVE                 = {'pa', 1  , 1, 'YQEDI' ,  'kgC/pl' , 'kgC/m2'  }; %**
   map.BDEAD                  = {'pa', 1  , 1, 'YQEDI' ,  'kgC/pl' , 'kgC/m2'  }; %**
   
   map.LEAF_MAINTENANCE        = {'pa', 1  , 1, 'DI',   'kgC/pl'    , 'kgC/m2'     };
   map.ROOT_MAINTENANCE        = {'pa', 1  , 1, 'DI',   'kgC/pl'    , 'kgC/m2'     };
else
   map.FMEAN_LEAF_MAINTENANCE_PY  = {'ed', 1  , 0, 'TI' };
   map.FMEAN_ROOT_MAINTENANCE_PY  = {'ed', 1  , 0, 'TI' };
   
   map.FMEAN_BLEAF_CO          = {'pa', 1  , 1, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
   map.FMEAN_BROOT_CO          = {'pa', 1  , 1, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
   map.FMEAN_BSAPWOODA_CO      = {'pa', 1  , 1, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
   map.FMEAN_BSAPWOODB_CO      = {'pa', 1  , 1, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
   map.FMEAN_BSTORAGE_CO       = {'pa', 1  , 1, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
   
   map.DMEAN_BLEAF_CO             = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
   map.DMEAN_BROOT_CO             = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
   map.DMEAN_BSTORAGE_CO          = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
   map.DMEAN_LEAF_MAINTENANCE_CO  = {'pa', 1  , 1, 'D',   'kgC/pl'    , 'kgC/m2'     };
   map.DMEAN_ROOT_MAINTENANCE_CO  = {'pa', 1  , 1, 'D',   'kgC/pl'    , 'kgC/m2'     };
   
   map.DMEAN_FAST_SOIL_C_PY       = {'ed', 1  , 0, 'D',   'kgC/m2'    , 'kgC/m2'  };
   map.DMEAN_SLOW_SOIL_C_PY       = {'ed', 1  , 0, 'D',   'kgC/m2'    , 'kgC/m2'  };
   %map.DMEAN_STRUCTURAL_SOIL_C_PY = {'ed', 1  , 0, 'DI'   ,  'kgC/m2' , 'kgC/m2'  };

end



end

% NEED TO CREATE:
% Error reading BLEAF_C13_PY                   from 720 files...
% Error reading BROOT_C13_PY                   from 720 files...
% Error reading BSTORAGE_C13_PY                from 720 files...
% GROWTH_RESP_CO
% STORAGE_RESP_CO

% AND THESE SHOULD BE IN MAINLINE
% Error reading STRUCTURAL_SOIL_C_PY           from 720 files...
% Error reading STRUCTURAL_SOIL_C13_PY         from 720 files...

%Error reading FMEAN_STORAGE_RESP_PY          from 720 files...
%Error reading FMEAN_STORAGE_RESP_C13_PY      from 720 files...
