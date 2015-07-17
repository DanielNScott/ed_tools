function [ cell ] = remove_cell_entry( cell, pos)
%REMOVE_CELL_ENTRY Removes element with index "pos" from the cell vector "cell" producing a new
%cell vector with 1 fewer elements.

npos = numel(cell);
if pos == 1
   cell = cell(2:end);
elseif pos > 1 && pos < npos
   cell = horzcat(cell(1:pos-1),cell(pos+1:end));
elseif pos == npos
   cell = cell(1:end-1);
end

end

