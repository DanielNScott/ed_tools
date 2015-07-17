function [ map ] = def_ed_varmap( )
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
map.AREA                      = {'si', 0  , 0, 'YQEDI',  ''       , ''        };
map.PACO_ID                   = {'si', 0  , 0, 'YQEDI',  ''       , ''        };
map.AGB_CO                    = {'pa', 0  , 1, 'YQED' ,  'kgC/pl' , 'kgC/m2'  };
map.BLEAF                     = {'pa', 1  , 1, 'YQED' ,  'kgC/pl' , 'kgC/m2'  };
map.BROOT                     = {'pa', 1  , 1, 'YQED' ,  'kgC/pl' , 'kgC/m2'  };
map.BSTORAGE                  = {'pa', 1  , 1, 'YQED' ,  'kgC/pl' , 'kgC/m2'  };
map.BSAPWOODA                 = {'pa', 1  , 1, 'QED'  ,  'kgC/pl' , 'kgC/m2'  }; %**
map.BSAPWOODB                 = {'pa', 1  , 1, 'QED'  ,  'kgC/pl' , 'kgC/m2'  }; %**
map.BALIVE                    = {'pa', 1  , 1, 'QED'  ,  'kgC/pl' , 'kgC/m2'  }; %**
map.BDEAD                     = {'pa', 1  , 1, 'QED'  ,  'kgC/pl' , 'kgC/m2'  }; %**
map.LAI_CO                    = {'pa', 0  , 1, 'YQED' ,  ''       , ''        };
map.NPLANT                    = {'pa', 0  , 0, 'YQEDI',  ''       , ''        };
map.PFT                       = {'pa', 0  , 0, 'YQED' ,  ''       , ''        };
 ... %% DAILY: 
map.DMEAN_FS_OPEN_CO          = {'pa', 0  , 1, 'D',   ''          , ''           };
map.DMEAN_LEAF_RESP_CO        = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
%map.DMEAN_LASSIM_RESP_CO     = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_ROOT_RESP_CO        = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_GROWTH_RESP_CO      = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_STORAGE_RESP_CO     = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_VLEAF_RESP_CO       = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_GPP_CO              = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_NPP_CO              = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.DMEAN_PLRESP_CO           = {'pa', 1  , 1, 'D',   'kgC/pl/yr' , 'kgC/m2'     };
map.DMEAN_RH_PA               = {'si', 1  , 0, 'D',   ''          , ''           };
map.DMEAN_CWD_RH_PA           = {'si', 1  , 0, 'D',   ''          , ''           };
map.LEAF_MAINTENANCE          = {'pa', 1  , 1, 'D',   'kgC/pl'    , 'kgC/m2'     };
map.ROOT_MAINTENANCE          = {'pa', 1  , 1, 'D',   'kgC/pl'    , 'kgC/m2'     };
map.DMEAN_NEP_PY              = {'ed', 0  , 0, 'D',   'kgC/m2/yr' , 'kgC/m2/yr'  };
 ... %% MONTHLY:
map.BA_CO                     = {'pa', 0  , 1, 'QE',  'cm2'       , 'cm2'        };
map.CB                        = {'pa', 0  , 1, 'QE',  'kgC/pl'    , 'kgC/m2'     };
map.DBH                       = {'pa', 0  , 1, 'QE',  'cm2'       , 'cm2'        };
map.HITE                      = {'pa', 0  , 1, 'QE',  'm'         , 'm'          };
map.MMEAN_FS_OPEN_CO          = {'pa', 0  , 1, 'QE',  ''          , ''           };
map.MMEAN_LEAF_DROP_CO        = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_LAI_CO              = {'pa', 0  , 1, 'QE',  'm2l/m2'    , 'm2l/m2'     };
map.MMEAN_BLEAF_CO            = {'pa', 1  , 1, 'QE',  'kgC/pl'    , 'kgC/m2'     };
map.MMEAN_BROOT_CO            = {'pa', 1  , 1, 'QE',  'kgC/pl'    , 'kgC/m2'     };
map.MMEAN_BSTORAGE_CO         = {'pa', 1  , 1, 'QE',  'kgC/pl'    , 'kgC/m2'     };
map.MMEAN_LEAF_RESP_CO        = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
%map.MMEAN_LASSIM_RESP_CO     = {'pa', 1  , 1, 'QE'};
map.MMEAN_ROOT_RESP_CO        = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_GROWTH_RESP_CO      = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_LEAF_GROWTH_RESP_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_ROOT_GROWTH_RESP_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_SAPA_GROWTH_RESP_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_SAPB_GROWTH_RESP_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_STORAGE_RESP_CO     = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_VLEAF_RESP_CO       = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_GPP_CO              = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPP_CO              = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NEP_PY              = {'ed', 0  , 0, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPDAILY_CO         = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPCROOT_CO         = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPFROOT_CO         = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPLEAF_CO          = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPSAPWOOD_CO       = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPSEEDS_CO         = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_NPPWOOD_CO          = {'pa', 0  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_PLRESP_CO           = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_RH_PA               = {'si', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_RH_PY               = {'ed', 0  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_CWD_RH_PA           = {'si', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_CWD_RH_PY           = {'ed', 0  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_FAST_SOIL_C         = {'si', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_SLOW_SOIL_C         = {'si', 1  , 0, 'QE',  'kgC/m2'    , 'kgC/m2'     };
map.MMEAN_LEAF_MAINTENANCE_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_ROOT_MAINTENANCE_CO = {'pa', 1  , 1, 'QE',  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.MMEAN_SENSIBLE_AC_PY      = {'un', 0  , 1, 'QE',  'W/m2'      , 'W/m2'       };
map.MMEAN_VAPOR_AC_PY         = {'un', 0  , 1, 'QE',  'kgH2O/m2/s', 'kgH2O/m2/s' };
%map.MMEAN_MORT_RATE_CO       = {'un', 0  , 1, 'QE'};
%map.BASAL_AREA_PY            = {'ed', 0  , 0, 'QE'};
...
map.QMEAN_NPP_CO              = {'pa', 0  , 1, 'Q' ,  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.QMEAN_NEP_PY              = {'ed', 0  , 1, 'Q' ,  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.QMEAN_PLRESP_CO           = {'pa', 0  , 1, 'Q' ,  'kgC/pl/yr' , 'kgC/m2/yr'  };
map.QMEAN_RH_PY               = {'ed', 0  , 1, 'Q' ,  'kgC/m2'    , 'kgC/m2'     };
 ... %% YEARLY:
map.FAST_SOIL_C               = {'si', 0  , 0, 'Y' ,  'kgC/m2'    , 'kgC/m2'     };
map.SLOW_SOIL_C               = {'si', 0  , 0, 'Y' ,  'kgC/m2'    , 'kgC/m2'     };
map.STRUCTURAL_SOIL_C         = {'si', 0  , 0, 'Y' ,  'kgC/m2'    , 'kgC/m2'     };
map.STRUCTURAL_SOIL_L         = {'si', 0  , 0, 'Y' ,  'kgL/m2'    , 'kgL/m2'     };
map.BASAL_AREA_GROWTH         = {'un', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.BASAL_AREA_MORT           = {'un', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.TOTAL_BASAL_AREA          = {'ed', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.TOTAL_BASAL_AREA_GROWTH   = {'ed', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.TOTAL_BASAL_AREA_MORT     = {'ed', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
map.TOTAL_BASAL_AREA_RECRUIT  = {'ed', 0  , 0, 'Y' ,  'cm2/m2/yr' , 'cm2/m2/yr'  };
... %% TOWER:
map.FMEAN_NEP_PY              = {'ed', 1  , 0, 'TI' ,  'kgC/m2/yr' , 'kgC/m2/yr'  };
map.FMEAN_VAPOR_AC_PY         = {'ed', 0  , 0, 'TI' };
map.FMEAN_SENSIBLE_AC_PY      = {'ed', 0  , 0, 'TI' };
%map.FMEAN_RH_PA              = {'si', 1  , 0, 'TI' };
map.FMEAN_RH_PY               = {'ed', 1  , 0, 'TI' };
map.FMEAN_ROOT_RESP_PY        = {'ed', 1  , 0, 'TI' };
 ... %% Fast:
map.FMEAN_LEAF_RESP_CO        = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
%map.FMEAN_LASSIM_RESP_CO     = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_ROOT_RESP_CO        = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_GROWTH_RESP_CO      = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_STORAGE_RESP_CO     = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_VLEAF_RESP_CO       = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_GPP_CO              = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_NPP_CO              = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2/yr'  };
map.FMEAN_PLRESP_CO           = {'pa', 1  , 0, 'I',   'kgC/pl/yr' , 'kgC/m2'     };
...
%map.FMEAN_RH_PA               = {'si', 1  , 0, 'TI',   ''          , ''           };
%map.FMEAN_CWD_RH_PA           = {'si', 1  , 0, 'TI',   ''          , ''           };
map.FMEAN_CSTAR_PA            = {'si', 1  , 0, 'TI',  'umol/mol'  , 'umol/mol'   };
map.FMEAN_CAN_CO2_PA          = {'si', 1  , 0, 'TI',  'umol/mol'  , 'umol/mol'   };
map.FMEAN_CARBON_AC_PA        = {'si', 1  , 0, 'TI',  'umol/mol'  , 'umol/mol'   };
map.FMEAN_CARBON_ST_PA        = {'si', 1  , 0, 'TI',  'umol/mol'  , 'umol/mol'   };
...
map.FMEAN_ATM_CO2_PY          = {'ed', 1  , 0, 'I',   'umol/mol'  , 'umol/mol'   };

%**These are in yearly output, but don't want to overwrite them when reading everything
end

