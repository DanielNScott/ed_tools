function [vname] = inv_iso_name(iso_name)
% INV_ISO_NAME is the inverse of get_iso_names, in the sense that it takes in an isotopic
%    output fieldname and returns the corresponding non-isotopic output fieldname.

substr_index = strfind(iso_name,'_C13');
if substr_index
   vname = [iso_name(1:substr_index-1),iso_name(substr_index+4:end)];
end

end