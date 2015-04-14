function [c13_name, d13C_name] = get_iso_name(vname)
% GET_ISO_NAME applies the naming conventions used for isotope accounting in the model to output
%   names and returns the corrosponding C-13 and Del-13C names.

%-------------------------------------------------------------------------------------------%
% There are a few naming conventions:                                                       %
% - Vars like FAST_SOIL_C become FAST_SOIL_C13.                                             %
% - Vars with _PA, _PY, _SI, or _CO get _C13 inserted before the std prefixes...            %
%   for example, vars like MMEAN_GPP_CO become MMEAN_GPP_C13_CO                             %
% - Other things get _C13 tacked onto the end.                                              %
%-------------------------------------------------------------------------------------------%   
if length(vname) > 2 && strcmp(vname(end-1:end),'_C')
   c13_name  = [vname,'13'];
   d13C_name = [vname(1:end-2),'_d13C'];
elseif length(vname) > 3 && any(strcmp(vname(end-2:end),{'_CO','_PA','_SI','_PY'}))
   c13_name  = [vname(1:end-3),'_C13',vname(end-2:end)];
   d13C_name = [vname(1:end-3),'_d13C',vname(end-2:end)];
else
   c13_name  = [vname,'_C13'];
   d13C_name = [vname,'_d13C'];
end

if strcmp(vname,'FMEAN_CARBON_AC_PA')
   c13_name  = 'FMEAN_CARBON13_AC_PA';
   d13C_name = 'FMEAN_CARBON_AC_d13C_PA';
elseif strcmp(vname,'FMEAN_CARBON_ST_PA')
   c13_name  = 'FMEAN_CARBON13_ST_PA';
   d13C_name = 'FMEAN_CARBON_ST_d13C_PA';
elseif strcmp(vname,'FMEAN_CSTAR_PA')
   c13_name  = 'FMEAN_C13STAR_PA';
   d13C_name = 'FMEAN_CSTAR_d13C_PA';
end

%-------------------------------------------------------------------------------------------%

end


