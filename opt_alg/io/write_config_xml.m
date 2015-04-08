function [ ] = write_config_xml( prop_state, labels, pfts)
%WRITE_CONFIG_XML Writes a parameter configuration file 'config.xml' for ED2.1
%   Detailed explanation goes here
%   prop_state : The set of parameters for the next run
%   labels     : Sorted (by pft) array with rows: param name, pft

dbug = 0;                                          % Debugging output for this function?

% Just assume there are pft parameters.
npft         = numel(pfts);                        % Get the number of pft tags to create 
pft_msk      = strcmp('pft',labels(:,2));          % Create a mask to get just pft params
pft_labels   = labels(pft_msk,:);                  % Get pft parameter names
n_pft_labels = size(pft_labels,1);                 % Get # of pft parameter names

% There may be other types of params too...
param_types  = unique(labels(~pft_msk,2));         % Are there? What are they?

% Create document node and root element 'config':
docNode = com.mathworks.xml.XMLUtils.createDocument('config'); 

%Identify the root element, and set the version attribute:
cnfgNode = docNode.getDocumentElement;
%cnfgNode.setAttribute('version','1.0');

%-------------------------------------------------------------------------------------%
% Loop 1 creates the pft and number nodes, i.e. the part of the XML that looks like:
% <pft>
%   <num>
%     6
%   </num>
%   ... 
% </pft>
% Loop 2 fills in the ellipsis
%-------------------------------------------------------------------------------------%

% Loop 1: Create pft & number nodes.
for ipft = 1:npft
   num_str       = [' ' num2str(pfts(ipft)) ' '];     % Get the pft number
   pftNode{ipft} = docNode.createElement('pft');      % Create <pft> tag for each pft number
   numNode{ipft} = docNode.createElement('num');      % Create <num> tag for each pft number
   txtNode{ipft} = docNode.createTextNode(num_str);   % Create textual element to hold the #

   cnfgNode.appendChild(pftNode{ipft});               % Insert <pft> tag for each pft number
   pftNode{ipft}.appendChild(numNode{ipft});          % Insert <num> tag for each pft number
   numNode{ipft}.appendChild(txtNode{ipft});          % Insert number as a str
end

% Loop 2: Fill them with the parameters.
param_nodes = {};                                     % Initialize set of nodes for parameters
counter     = 1;                                      % We want a param node 4each label & pft
pft_p_vals  = prop_state(pft_msk);                    % Get the list of states that apply
for irow = 1:n_pft_labels
   param_name = pft_labels{irow,1};                   % Get the name of the parameter
   param_pfts = pft_labels{irow,3};                   % Get the pfts we want to apply param to

   param_val  = [' ' num2str(pft_p_vals(irow)) ' '];  % Get the value of the parameter
   for i = 1:numel(param_pfts)
      valNode = docNode.createTextNode(param_val);                % Create text el. for value
      ipft    = pft_labels{irow,3}(i);                            % Get the current pft number
      param_nodes{counter} = docNode.createElement(param_name);   % Create <param> </param>
      param_nodes{counter}.appendChild(valNode);                  % Put param val btwn them
      pftNode{pfts == ipft}.appendChild(param_nodes{counter});    % Put it all in the document
      counter = counter + 1;                                      % ?
   end
end
valNode = {};
% These loops deal with non-pft params.
for itype = 1:numel(param_types)
   curr_type = param_types{itype};                       % Take note of current type
   type_msk  = strcmp(labels(:,2),curr_type);            % Create a mask for this type
   curr_labs = labels(type_msk,:);                       % Apply it to get params of curr_type
   p_vals    = prop_state(type_msk);                     % Get the list of states that apply
   
   typeNode = docNode.createElement(curr_type);          % Create a node for this type
   cnfgNode.appendChild(typeNode);                       % Append the type node to the document
   for irow = 1:numel(curr_labs(:,1))                    % Cycle through params w/ this type
      param_name = curr_labs{irow,1};
      param_val  = [' ' num2str(p_vals(irow)) ' '];      % Get the value of the parameter
      pNode   = docNode.createElement(param_name);       % Create a node for this parameter
      valNode = docNode.createTextNode(param_val);       % Create textual element to hold val
      pNode.appendChild(valNode);                        % Put param val btwn them
      typeNode.appendChild(pNode);                       % Insert <pft> tag for each pft number
   end
end
   
% Export the DOM node to config.xml, and view the file with the type function if debugging:
xmlwrite('config.xml',docNode);
if dbug;
   disp('--- Displaying config.xml... ----------------')
   type('config.xml');
end

end

% parameter name, pft
