function [ recvr ] = merge_struct( donor, recvr )
%UPDATE_STRUCT Appends data in fields from donor to corrosponding ones in a reciever.
%   For huge data this will be slow...

rflds = fieldnames(recvr);
dflds = fieldnames(donor);


for fld_num = 1:numel(dflds)                    % Want to access all flds, so loop
   dfld = dflds{fld_num};                       % Get field name for easy access
   if isstruct(donor.(dfld))                    % Check to see if the field is a structure...
      if sum(strcmp(dfld,rflds))
         recvr.(dfld) = merge_struct(donor.(dfld),recvr.(dfld));
      else
         recvr.(dfld) = donor.(dfld);
      end
   else
      recvr.(dfld) = donor.(dfld);              % Otherwise append fld from stats to history.
      if strcmp(dfld,rflds);
         disp([dfld ' was overwritten in merge_struct...'])
      end
   end
end

end
