function data = read_namelist(filename,namelist)
%READ_NAMELIST(filename,namelist) Returns values from FORTRAN namelist
%   This function reads a FORTRAN input namelist and returns the values as
%   the fields of a structure.  Multidimensional arrays have their indicies
%   scaled and shifted to fit the matlab numbering scheme.

% Open a text file
fid = fopen(filename,'r');

% Find the namelist section
line = fgetl(fid);
while ~feof(fid) && isempty(strfind(line,namelist))
    line=fgetl(fid);
end
if feof(fid)
    disp(['ERROR: Namelist: ' namelist ' not found!']);
    data = -1;
    return
end

% Initialize namelist reading vars.
line       = fgetl(fid);
total_line = line;
data.tmp   = -1;
i          = 1;

% Now read the namelist
while ischar(line) && ~strcmp(strtrim(line),'/')
   total_line = [total_line line];
   line       = fgetl(fid);
   
   line = remove_lws(line);
       
   % Save lines containing namelist vars.
   if numel(line) > 3
      if strcmp(line(1:3),'NL%');
         %Find index for '='
         eq_ind = strfind(line,'=');
         eq_ind = eq_ind(1);
         
         % Set name and trim trailing spaces
         name = line(4:eq_ind-1);
         name(name == ' ') = '';

         % Set val as everything after first non ws char.
         val = remove_lws(line(eq_ind+1:end));
         
         data.(name) = val;
      end
   end
end

% Close the text file
fclose(fid);

data = rmfield(data,'tmp');
end

% Function for removing leading white space
function [out_str] = remove_lws(in_str)
   wsind = in_str == ' ';
   j = 1;
   if ~isempty(wsind) && wsind(1) == 1;
      isws = 1;
      while isws
         j = j + 1;
         isws = wsind(j) == 1;
      end   
   end
   out_str = in_str(j:end);
end

