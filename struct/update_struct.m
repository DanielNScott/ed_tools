function [ recvr ] = update_struct( donor, recvr )
%UPDATE_STRUCT Appends data in fields from donor to corrosponding ones in a reciever.
%   For huge data this will be slow...

rflds = fieldnames(recvr);
dflds = fieldnames(donor);

if ~isempty(setdiff(rflds,dflds))
   error('At this time you cannot use update_struct with structs having different field names.')
end

for fld_num = 1:numel(dflds)                    % Want to access all flds, so loop
   dfld = dflds{fld_num};                       % Get field name for easy access
   if isstruct(donor.(dfld))                    % Check to see if the field is a structure...
      % If it is, recurse!
      if ~isfield(recvr,dfld)
         recvr.(dfld) = struct();
      end
      recvr.(dfld) = update_struct(donor.(dfld),recvr.(dfld));
   else
      if ~isfield(recvr,dfld)
         recvr.(dfld) = [];
      end
      recvr.(dfld)(:,end+1) = donor.(dfld);    % Otherwise append fld from stats to history.
   end
end

end
