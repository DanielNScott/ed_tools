function [ polys ] = read_joborder(numPolys,joborder_dir)

% Notify user of caveat.
disp(' ')
disp('Message from read_joborder.m:')
disp('Please note that if the joborder.txt file contains whitespace at the end')
disp('of its lines this script will not run correctly. Also please note that if')
disp('this script cannot find a timea or timez field it will assume they are 0.')
RawData = readtext([joborder_dir,'/joborder.txt'],'\s+');

%disp(RawData)

% Get indices of itime, idate, imonth, iyear.
timeNames = {'itimea', 'idatea', 'imontha', 'iyeara', 'itimez', 'idatez', 'imonthz', 'iyearz', 'c13af'};
minChars  = [       6,        2,         2,        4,        6,        2,         2,        4,       1];
for col = 1:length(RawData(2,:))
   for i=1:length(timeNames)
      if strcmp(RawData{2,col},timeNames{i})
         index.(timeNames{i}) = col;
      end
   end
end

% Sometimes itimea and itimez will not be specified, so set them if that's the case.
if not(isfield(index,'itimea'))
   index.itimea = '000000';
end
if not(isfield(index,'itimez'))
   index.itimez = '000000';
end

%--- Make contents into user friendly structure from awkward cell --------%
for row=4:numPolys+3
   for i = 1:length(timeNames)
      name = timeNames{i};
      chars = minChars(i);
      str = num2str(RawData{row,index.(name)});
      polys.(RawData{row,1}).(name) = pad_str(str,chars,name);
      %disp([name,': '])
      %disp(polys.(RawData{row,1}).(name))
   end
end

end




function [ outstr ] = pad_str(instr,properlen,varname)
      if length(instr) < properlen
         outstr = [repmat('0',1,properlen-length(instr)),instr];
      elseif length(instr) > properlen
         error([varname,' doesn''','t make sense.'])
      else
         outstr = instr;
      end
end