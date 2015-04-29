function [ ] = vdisp( msg, min_verbosity, actual_verbosity )
%VDISP(message,min_verbosity,verbosity) Displays "message" if verbosity >= min_verbosity

if actual_verbosity >= min_verbosity
   disp(msg)
end


end

