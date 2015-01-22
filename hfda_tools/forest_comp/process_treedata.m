function [ trees ] = process_treedata( trees )
%PROCESS_TREEDATA Processes the 'trees' data structure to include a variety of information.
%   Detailed explanation goes here

dbug      = 1;                               % Debugging output flag.
ignore_us = 1;                               % Ignore understory?

% Some abbreviations used throughout:
% - yr   := 'year'
% - msk  := 'mask' i.e. logical mask
% - xNum := 'x Number' i.e. the number of the current element like 'x' being used in loop.
% - xlst := 'list' of elements of type 'x' 
% - ths  := 'this'

%-----------------------------------------------------------------------------------------------
% Remove 'harv' plts, which have effects of experimental forestry practices.
% Keep only type 'live' for this analysis.
%-----------------------------------------------------------------------------------------------
ems_msk    = strcmp(trees.cell(:,2),'ems');  % Create ems tower footprint mask
trees.cell = trees.cell(ems_msk,:);          % Remove non ems values
trees.mat  = trees.mat (ems_msk,:);          % Remove non ems values

type_msk   = strcmp(trees.cell(:,1),'live'); % Create mask to remove 'rcrt' and 'dead' trees
trees.cell = trees.cell(type_msk,:);         % Remove non 'live' field types
trees.mat  = trees.mat (type_msk,:);         % Remove non 'live' field types

if ignore_us
   dbh_msk = trees.mat(:,4) >= 10.0;         % Create mask to remove things <= 10cm dbh.
   trees.cell = trees.cell(dbh_msk,:);       % Remove rows from cell
   trees.mat  = trees.mat (dbh_msk,:);       % Remove rows from mat
end


%-----------------------------------------------------------------------------------------------
% Set useful information.
%-----------------------------------------------------------------------------------------------
yrs   = unique(trees.mat(:,1));  % Years
plts  = unique(trees.cell(:,3)); % The plts in trees.mat/trees.cell
pRad  = 10;                      % Radius of plots [m].
pArea = pi()*pRad^2;             % Area of plots [m^2].

nyrs  = numel(yrs);              % Number of Years
nplts = numel(plts);             % Number of plots.
nflds = size(trees.mat,1);       % Number of fields are in trees.mat/trees.cell

%-----------------------------------------------------------------------------------------------
% Append a unique 'tree_ID' composed of plot and tag info to each row in cell data.
% Then append as well the catagory the tree is in, Hw, Co, Su, or unknown.
%-----------------------------------------------------------------------------------------------
trees.cell = [trees.cell, cell(nflds,2)]; % Add cells for unique tree IDs and type.
for fld = 1:nflds
   ths_plot = trees.cell{fld,3};          % Extract plot name
   ths_tag  = num2str(trees.mat(fld,3));  % Extract tag name
   ths_tID  = [ths_plot,'-',ths_tag];     % Hyphenate the pair to create unique tree ID
   trees.cell{fld,end-1} = ths_tID;       % Save this tree ID in the datafield.
   
   ths_type = get_spp_type(trees.cell{fld,5});  % Get the type of 'tree'
   trees.cell{fld,end} = ths_type;              % Save the type of tree.
end

%-----------------------------------------------------------------------------------------------
% Get BA, BA In Growth, and BA Mortality for each year.
%-----------------------------------------------------------------------------------------------
BA_list     = NaN(3,nyrs); % Initialize list of every year's BA
BAI_list    = NaN(3,nyrs); % Initialize list of every year's BA Increment

hw_msk      = strcmp(trees.cell(:,7),'hw'); % Create mask for hardwoods. (Gets used w/ yr_msk)
co_msk      = strcmp(trees.cell(:,7),'co'); % Create mask for conifers. (Gets used w/ yr_msk)

for yrNum = 1:nyrs
   ths_yr = yrs(yrNum);       % This year
   prv_yr_exists = yrNum > 1; % Previus year exists (logical)
   
   % Keep last year's data for later use, if it does.
   if prv_yr_exists
      prv_yr_str  = ths_yr_str;
      
      prv_yr_dat  = ths_yr_dat;
      prv_yr_cel  = ths_yr_cel;
      prv_yr_tIDs = trees.(ths_yr_str).tIDs;
      prv_yr_BA   = BA_list(1,yrNum-1);
      
      prv_yr_dat_hw  = ths_yr_dat;
      prv_yr_cel_hw  = ths_yr_cel;
      prv_yr_tIDs_hw = trees.(ths_yr_str).tIDs_hw;
      prv_yr_BA_hw   = BA_list(2,yrNum-1);
      
      prv_yr_dat_co  = ths_yr_dat_co;
      prv_yr_cel_co  = ths_yr_cel_co;
      prv_yr_tIDs_co = trees.(ths_yr_str).tIDs_co;
      prv_yr_BA_co   = BA_list(3,yrNum-1);
   end

   %-----------------------------------------------------------------------------------
   % Get the total basal area from this year and save it in the basal area list.
   %-----------------------------------------------------------------------------------
   yr_msk     = trees.mat(:,1) == ths_yr; % Create a mask for this year
   ths_yr_dat = trees.mat (yr_msk,:);     % Extract this year's (matrix) data
   ths_yr_cel = trees.cell(yr_msk,:);     % Extract this year's (cell) data
   tIDs       = unique(ths_yr_cel(:,6));  % Get list of unique tree IDs

   BA               = get_BA(ths_yr_cel,ths_yr_dat,tIDs,nplts,pArea);
   BA_list(1,yrNum) = BA;

   %-----------------------------------------------------------------------------------
   % Get the hardwood basal area for this year...
   %-----------------------------------------------------------------------------------
   yr_msk_hw     = and(hw_msk,yr_msk);          % Set a mask for this year's hardwoods
   ths_yr_dat_hw = trees.mat (yr_msk_hw,:);     % Extract this year's (matrix) data
   ths_yr_cel_hw = trees.cell(yr_msk_hw,:);     % Extract this year's  (cell) data
   tIDs_hw       = unique(ths_yr_cel_hw(:,6));  % Get list of unique tree IDs
   
   BA_hw             = get_BA(ths_yr_cel_hw,ths_yr_dat_hw,tIDs_hw,nplts,pArea);
   BA_list(2,yrNum)  = BA_hw;
   %-----------------------------------------------------------------------------------
   % Get the conifer basal area for this year...
   %-----------------------------------------------------------------------------------
   yr_msk_co     = and(co_msk,yr_msk);          % Set a mask for this year's hardwoods
   ths_yr_dat_co = trees.mat (yr_msk_co,:);     % Extract this year's (matrix) data
   ths_yr_cel_co = trees.cell(yr_msk_co,:);     % Extract this year's  (cell) data
   tIDs_co       = unique(ths_yr_cel_co(:,6));  % Get list of unique tree IDs
   
   BA_co             = get_BA(ths_yr_cel_co,ths_yr_dat_co,tIDs_co,nplts,pArea);
   BA_list(3,yrNum)  = BA_co;
   %-----------------------------------------------------------------------------------
   
   ths_yr_str = ['jy',num2str(ths_yr)];   % Generate a string to use as field name 
   
   trees.(ths_yr_str)         = struct;   % Create a sub-structure for this year's data.

   trees.(ths_yr_str).BA      = BA;       % Save this year's BA there.
   trees.(ths_yr_str).tIDs    = tIDs;     % Save this year's tree IDs
 
   trees.(ths_yr_str).BA_hw   = BA_hw;    % Save this year's BA there.
   trees.(ths_yr_str).tIDs_hw = tIDs_hw;  % Save this year's tree IDs
 
   trees.(ths_yr_str).BA_co   = BA_co;    % Save this year's BA there.
   trees.(ths_yr_str).tIDs_co = tIDs_co;  % Save this year's tree IDs
   
   % Calculate increments and growth if we have data from last year.
   if prv_yr_exists
      %-----------------------------------------------------------------------------------
      % Totals...
      %-----------------------------------------------------------------------------------
      pres_tIDs   = intersect(prv_yr_tIDs,tIDs);      % Find tree IDs that exist in both sets
      lost_tIDs   = setdiff(prv_yr_tIDs,pres_tIDs);   % Find tIDs that were lost from last year
      new_tIDs    = setdiff(tIDs,pres_tIDs);          % Find tIDs that are new this time
      
      BA_loss = get_BA(prv_yr_cel,prv_yr_dat,lost_tIDs,nplts,pArea); % Calc lost BA
      BA_new  = get_BA(ths_yr_cel,ths_yr_dat,new_tIDs,nplts,pArea);  % Calc new BA
      BAI     = (BA - BA_new) - (prv_yr_BA - BA_loss);               % Calc BAI

      BAI_list(1,yrNum) = BAI;                  % Save BAI
      BAL_list(1,yrNum) = BA_loss;              % Save BA_loss
      BAN_list(1,yrNum) = BA_new;               % Save BA_new
      
      trees.(ths_yr_str).new_BA   = BA_new;     % Save (to this year) what is tags are new      
      trees.(ths_yr_str).new_tID  = new_tIDs;   % Save (to this year) what is tags are new
      
      trees.(prv_yr_str).lost_BA  = BA_loss;    % Save (to last year) what BA doesn't persist
      trees.(prv_yr_str).lost_tID = lost_tIDs;  % Save (to last year) what tags don't persist
      
      trees.(ths_yr_str).BAI      = BAI;        % Save (to this year) BAI over this last year
      
      %-----------------------------------------------------------------------------------
      % Hardwoods...
      %-----------------------------------------------------------------------------------
      pres_tIDs   = intersect(prv_yr_tIDs_hw,tIDs_hw);   % Find  IDs that exist in both sets
      lost_tIDs   = setdiff(prv_yr_tIDs_hw,pres_tIDs);   % Find those lost from last year
      new_tIDs    = setdiff(tIDs_hw,pres_tIDs);          % Find those that are new this year
      
      BA_loss = get_BA(prv_yr_cel_hw,prv_yr_dat_hw,lost_tIDs,nplts,pArea); % Calc lost BA
      BA_new  = get_BA(ths_yr_cel_hw,ths_yr_dat_hw,new_tIDs,nplts,pArea);  % Calc new BA
      BAI     = (BA_hw - BA_new) - (prv_yr_BA_hw - BA_loss);               % Calc BAI

      BAI_list(2,yrNum) = BAI;                     % Save BAI to BAI list.
      BAL_list(2,yrNum) = BA_loss;                 % Save BA_loss
      BAN_list(2,yrNum) = BA_new;                  % Save BA_new
      
      trees.(ths_yr_str).new_BA_hw   = BA_new;     % Save (to this year) what is tags are new      
      trees.(ths_yr_str).new_tID_hw  = new_tIDs;   % Save (to this year) what is tags are new
      
      trees.(prv_yr_str).lost_BA_hw  = BA_loss;    % Save (to last year) what BA doesn't persist
      trees.(prv_yr_str).lost_tID_hw = lost_tIDs;  % Save (to last year) what tags don't persist
      
      trees.(ths_yr_str).BAI_hw      = BAI;        % Save (to this year) BAI over this last year
      
      %-----------------------------------------------------------------------------------
      % Conifers...
      %-----------------------------------------------------------------------------------
      pres_tIDs   = intersect(prv_yr_tIDs_co,tIDs_co);   % Find  IDs that exist in both sets
      lost_tIDs   = setdiff(prv_yr_tIDs_co,pres_tIDs);   % Find those lost from last year
      new_tIDs    = setdiff(tIDs_co,pres_tIDs);          % Find those that are new this year
      
      BA_loss = get_BA(prv_yr_cel_co,prv_yr_dat_co,lost_tIDs,nplts,pArea); % Calc lost BA
      BA_new  = get_BA(ths_yr_cel_co,ths_yr_dat_co,new_tIDs,nplts,pArea);  % Calc new BA
      BAI     = (BA_co - BA_new) - (prv_yr_BA_co - BA_loss);               % Calc BAI

      BAI_list(3,yrNum) = BAI;                     % Save BAI to BAI list.
      BAL_list(3,yrNum) = BA_loss;                 % Save BA_loss
      BAN_list(3,yrNum) = BA_new;                  % Save BA_new
      
      trees.(ths_yr_str).new_BA_co   = BA_new;     % Save (to this year) what is tags are new      
      trees.(ths_yr_str).new_tID_co  = new_tIDs;   % Save (to this year) what is tags are new
      
      trees.(prv_yr_str).lost_BA_co  = BA_loss;    % Save (to last year) what BA doesn't persist
      trees.(prv_yr_str).lost_tID_co = lost_tIDs;  % Save (to last year) what tags don't persist
      
      trees.(ths_yr_str).BAI_co      = BAI;        % Save (to this year) BAI over this last year
   end
end

trees.BA    = BA_list;  % Save the list of basal areas
trees.BAInc = BAI_list; % Save the list of basal area increments
trees.BANew = BAN_list; % Save the list of new basal area increments
trees.BALos = BAL_list; % Save the list of lost basal area increments

end

function [ BA ] = get_BA(ths_cel,ths_dat,tIDs,nplts,pArea)

   ntIDs = numel(tIDs);    % Number of tree IDs
   g8tor = zeros(ntIDs,1); % Initialize an aggregator (see below)

   % Cycle through tags, add row index of first instance of each to the aggregator
   for tIDNum = 1:ntIDs
      ths_tID       = tIDs(tIDNum);                         % Save this tree ID
      find_result   = find(strcmp(ths_cel(:,6),ths_tID));   % Get row indices with this tID 
      g8tor(tIDNum) = find_result(1);                       % Save each first instance index
   end
   
   ths_dat = ths_dat (g8tor,:);           % Mask out the first instances of the tIDs
   
   BA = (ths_dat(:,4)/100).^2 *pi()/4;    % Compute this year's BA for each row;
   BA = sum(BA)/(nplts*pArea);            % Sum to total BA and normalize by plot area.
   BA = BA*10000;                         % Convert from m^2/m^2 to m^2/ha
   
end


function [ type ] = get_spp_type( spp )

species_index = ...
     ... % Oaks
    {'ro'      , 'Red Oak'            , 'hw';
     'bo'      , 'Black Oak'          , 'hw';
     'wo'      , 'White Oak'          , 'hw';
     ...
     ... % Maples 
     'beech'   , 'Amer. Beech'        , 'hw';
     'rm'      , 'Red Maple'          , 'hw';
     'sm'      , 'Striped Maple'      , 'hw';
     ...
     ... % Conifers
     'rp'      , 'Red Pine'           , 'co';
     'wp'      , 'White Pine'         , 'co';
     'hem'     , 'Eastern Hemlock'    , 'co';
     'eh'      , 'Eastern Hemlock'    , 'co';
     'ws'      , 'White Spruce'       , 'co';
     ...
     ... % Birches
     'bb'      , 'Black Birch'        , 'hw';
     'yb'      , 'Yellow Birch'       , 'hw';
     'pb'      , 'Paper Birch'        , 'hw';
     'wb'      , 'Paper Birch'        , 'hw';
     'gb'      , 'Gray Birch'         , 'hw';
     'bc'      , 'Gray Birch'         , 'hw';
     ...
     ... % Other
     'haw'     , 'Hawthorn'           , 'hw';
     'ab'      , 'American Beech'     , 'hw';
     'ac'      , 'American Chestnut'  , 'hw';
     'chestnut', 'Amer. Chestnut'     , 'hw';
     'cherry'  , 'Cherry'             , 'hw';
     'ash'     , 'White Ash'          , 'hw';
     ...
     ... % Shrub / Understory
     'nwr'     , 'North. Wild Raisin' , 'su';
     'hbb'     , 'High Bush Blueberry', 'su';
     'spi'     , 'Spirea spp.'        , 'su';
     'fpc'     , 'Pin Cherry'         , 'su';
     'ss'      , 'Staghorn Sumac'     , 'su';
     'na'      , ''                   , 'su';
     'wh'      , 'Which Hazel'        , 'su';
     'ht'      , ''                   , '';
     };
  
  type = species_index(strcmp(species_index(:,1),spp),3);
  type = type{1};
end