function [] = process_output(poly_names, call_loc)
% This function is called by mpost.sh and is intended to interface the
% shell with the matlab post processing scripts.
%  Inputs: poly_names - Names of polygon folders found.
%          call_loc - The dir. this script was called from.


%----------- Setup some basics -----------------------------------------------------------%
% Tell the user what this script sees. 
disp(['Mpost_interface sees poly_names variable as: ' , poly_names])

% Reformat the poly_names variable to be more easily used in Matlab scripts. 
poly_names     = textscan(poly_names,'%s','Delimiter',',');    % Returns 1x1 cell w/ a 
poly_names     = poly_names{1};                                % cell in it.

% Tell the user what 
disp(['Now as ' , poly_names{1}])

% Get the number of polygons and the run lengths (start/fin times)
npolygons = length(poly_names);
runlen    = read_joborder(npolygons,call_loc);



%----------- Import Runs ----------------------------------------------------------------%
for polynum = 1:npolygons
   
   import_nl.(poly_names{polynum}).f_type   = poly_names{polynum};
   import_nl.(poly_names{polynum}).out_type = 'Q';
   import_nl.(poly_names{polynum}).start    = [ runlen.(poly_names{polynum}).itimea ,'-', ...
                                                runlen.(poly_names{polynum}).idatea ,'-', ...
                                                runlen.(poly_names{polynum}).imontha,'-', ...
                                                runlen.(poly_names{polynum}).iyeara        ];

   import_nl.(poly_names{polynum}).end      = [ runlen.(poly_names{polynum}).itimez ,'-', ...
                                                runlen.(poly_names{polynum}).idatez ,'-', ...
                                                runlen.(poly_names{polynum}).imonthz,'-', ...
                                                runlen.(poly_names{polynum}).iyearz        ];
   import_nl.(poly_names{polynum}).inc      = '000000';
   import_nl.(poly_names{polynum}).dir      = [call_loc,'/',poly_names{polynum},'/analy/'];
   import_nl.(poly_names{polynum}).splflg   = 1;
   import_nl.(poly_names{polynum}).c13out   = not(strcmp(runlen.(poly_names{polynum}).c13af,'0'));
   
   disp(' ')
   disp('==================================================================')
   disp(['Opening directory: ',import_nl.(poly_names{polynum}).dir])
   disp('==================================================================')
   disp('Import_poly.m "believes" the following about this polygon:')   
   disp(['file type: ' import_nl.(poly_names{polynum}).f_type           ])
   disp(['out. type: ' import_nl.(poly_names{polynum}).out_type         ])
   disp(['    start: ' import_nl.(poly_names{polynum}).start            ])
   disp(['      end: ' import_nl.(poly_names{polynum}).end              ])
   disp(['increment: ' import_nl.(poly_names{polynum}).inc              ])
   disp(['directory: ' import_nl.(poly_names{polynum}).dir              ])
   disp(['split flg: ' num2str(import_nl.(poly_names{polynum}).splflg)  ])
   disp(['      c13: ' num2str(import_nl.(poly_names{polynum}).c13out)  ])
   disp(' ')
   

%    try
   % Call import_poly to actually read in HDF5 info. This is the main function of this program.
   data.(poly_names{polynum}) = import_poly(import_nl.(poly_names{polynum}));
%    catch ME
%         mythrow(ME,'(this is a filler string)')
%    end
   % Yearly Read...
   import_nl.(poly_names{polynum}).out_type = 'Y';
   yrout = import_poly(import_nl.(poly_names{polynum}));

   %-------------------------------------------------------------------------------------------
   % Merge the yearly and monthly cell structures.
   %-------------------------------------------------------------------------------------------
   yroutflds = fieldnames(yrout.T);
   for ifld = 1:numel(yroutflds)
      data.(poly_names{polynum}).T.(yroutflds{ifld}) = yrout.T.(yroutflds{ifld});
   end
   %-------------------------------------------------------------------------------------------
end



%----------- Save the Data to a .mat file ------------------------------------%
write_time = clock;
write_time = strcat(num2str(write_time(1)),'_',num2str(write_time(2)),'_', ... 
                    num2str(write_time(3)),'_',num2str(write_time(4)),'_', ...
                    num2str(write_time(5)));

mpost.import_nl = import_nl;
mpost.data      = data;
mpost.poly_nls  = runlen;

disp('==================================================================')
disp(['Saving mpost_',write_time,'.mat ...'])
save(['mpost_',write_time],'mpost')

disp(' ')
disp('mpost_interface has finished!')
end


function [] = mythrow(ME,type)
disp('--------------------------------------------------------------------')
disp(['MATLAB has encountered an ',type,' error! Error messages will be displayed below.'])
disp('')
disp('ME Identifier:')
disp(ME.identifier)
disp('ME Message:')
disp(ME.message)
disp('ME Stack:')
disp(ME.stack(1))
disp('ME Cause:')
disp(ME.cause)
disp('')
disp('MATLAB will now continue execution.')
end
