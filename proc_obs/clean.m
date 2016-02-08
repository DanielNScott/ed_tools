function [ proc ] = clean( raw, numerics, verb )
%[clean_data] = CLEAN( data ) takes data a cell from readtext and make sure colums which should
%be numeric are, and columns which should only contain text do.

% Clean data:
nrows   = size(raw,1);
ncols   = size(raw,2);
rem_msk = zeros(nrows,1);

% Unfortunately some of the check operations don't have vectorized matlab implementations...
for irow = 1:nrows
   for icol = 1:ncols
      % First check cell isn't empty, which messes up logicals and other things.
      if isempty(raw{irow,icol})
         rem_msk(irow) = 1;
         vdisp(['Removing: ' raw(irow,:)],1,verb)
         continue;
      end
      
      % Remove non-numerics and mask out treatment, i.e. trenched plots.
      if any(icol == numerics && ischar(raw{irow,icol}))
         rem_msk(irow) = 1;
         vdisp(['Removing: ' raw(irow,:)],1,verb)
         continue
      end
   end
end
proc = raw(~rem_msk,:);

% Say how much got removed:
disp(['Data points total   : ' num2str(nrows)])
disp(['Data points removed : ' num2str(sum(rem_msk))])
disp(['As fraction of total: ' num2str(sum(rem_msk)/nrows)])


end

