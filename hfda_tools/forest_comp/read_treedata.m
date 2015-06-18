function [ trees ] = read_treedata()
%READ_TREEDATA Reads a csv (identified in the file) from HF data archive giving tree data.
%   That file read should be 'hf069-11-trees.csv'. The output is a structure, to be saved.

% Data, uncomment truncated or severe for testing:
hfa_path = 'C:\Users\Dan\Moorcroft_Lab\data\harvard forest archive\';
filename = [hfa_path 'hf-069-trees, Evan Goldman\hf069-11-trees.csv'];
%filename = 'C:\Users\Dan\Moorcroft Lab\data\harvard forest archive\hf069-11-trees.csv';
%filename = '.\Altered HF DSets\hf069-11-trees-truncated.csv';
%filename = '.\Altered HF DSets\hf069-11-trees-severe.csv';
%filename = '.\Altered HF DSets\hf069-11-trees-fake.csv';
%filename = '.\Altered HF DSets\hf069-11-trees-2009-2011.csv';
%filename = '.\Altered HF DSets\hf069-11-trees-ems-2002-2013.csv';

trees.all = readtext(filename); % Tree data from file
nrows = size(trees.all,1) - 1;  % Number of rows of actual data in file (first is headers)

%----------------------------------------------------------------------------------------------
% Create a matrix storing the numeric data with rows formatted
% Year, Julian Day, Tag, DBH
%----------------------------------------------------------------------------------------------
trees.mat = zeros(nrows,4); % Initialize Matrix
rowel = zeros(1,4);         % Set a vector to contain the elements of each row.

for row = 1:nrows    % Iterate through rows to fill trees.mat
    matcol = 0;      % For every new row, reset the trees.mat column number
  
    % For every numeric column in trees.raw, load that column's info into
    % the curent trees.mat row's corrosponding column.
    for rawcol = [1,2,7,9]
        matcol = matcol + 1; % trees.mat has contiguous columns, so cycle through them normally.

        % extract curr. entry so it doesn't have to be looked up over and over.
        curentry = cell2mat(trees.all(1+row,rawcol));
        
        % Get rid of 'Na' entries and turn them into NaNs
        if ischar(curentry)
            rowel(matcol) = NaN;
            % Indicate what has been turned into a NaN, if it is not what
            % we expect to turn into NaNs, i.e. if it is not 'NA'
            if ~strcmp(curentry,'NA')
                disp(['Characters found in row, column ',num2str(row),num2str(rawcol),':'])
                disp(curentry)
            end
        elseif isfloat(curentry)
            % No issue, just copy the number.
            rowel(matcol) = curentry;            
        else
            % Something unanticipated has happened, indicate what.
            disp(['Uncharacterized row element at ', num2str(row),num2str(matcol),' : '])
            disp(curentry)
            throw('See prev. message.')
        
        end
        
        % Copy the row elements into the appropriate trees.mat row.
        trees.mat(row,:) = rowel;
    end
end

%----------------------------------------------------------------------------------------------
% Create a cell with the rest of the data in format
% Status, Site, Plot, NIndivs, Species Abbrev.
%----------------------------------------------------------------------------------------------
trees.cell = [trees.all(2:end,3), ...
              trees.all(2:end,4), ...
              trees.all(2:end,5), ...
              trees.all(2:end,6), ...
              trees.all(2:end,8) ];

% Check that the number of rows in each of these is now the number of rows
% from the raw readtext output, then get rid of the redudant original data
% structure.
if size(trees.mat,1) ~= size(trees.all,1)-1
    disp('Error! Rows lost in trees.mat!')
end

if size(trees.cell,1) ~= size(trees.all,1)-1
    disp('Error! Rows lost in trees.cell!')
end

trees = rmfield(trees,'all');

% Put a description in the structure.
trees.desc = 'Mat/Cell Cols: Yr, Jday, Tag, DBH / Status, Site, Plot, NIndivs, SPP';



end

