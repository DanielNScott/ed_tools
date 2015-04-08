function [ ] = graph_BA( trees, years, plots )
%GRAPH_TREE_PLOTS Graphs basal area data from 'trees' structure.
%   trees - Data structure from read_treedata.m
%   years - Cell of year names e.g. {'yr1999'}
%   plots - Cell of plots to include, if empty, all.

%--------------------------------------------------------------------%
% Set some flags for this script.                                    %
%--------------------------------------------------------------------%
dbug      = 1; % Print debugging output?
normalize = 0; % Normalize the plots by area?

types  = {'hw','co'};
nyears = numel(years);
ntypes = numel(types);

close all;
if dbug;
   disp('---------------------------------------------------------')
   disp('- Running graph_tree_plots and printing debug output.   -')
   disp('---------------------------------------------------------')
end

%--------------------------------------------------------------------%
% Immediately trim 'trees' to only the relevant years so that the    %
% masking and other computations run much more quickly.              %
%--------------------------------------------------------------------%
if dbug
   disp('Before trimming:')
   disp('Lengths of trees.mat and trees.cell:');
   disp([mat2str(length(trees.mat)),' and ',mat2str(length(trees.cell))]);
   disp(' ');
   disp('First index of each year:');
   for iyr = 1:numel(years)
      disp(mat2str(trees.inds.years.(years{iyr})(1)));
   end
   disp('---------------------------------------------------------');
end


lower_ind  = trees.inds.years.(years{1  })(1  );
upper_ind  = trees.inds.years.(years{end})(end);

trees.mat  = trees.mat (lower_ind:upper_ind,:);
trees.cell = trees.cell(lower_ind:upper_ind,:);

tags = fieldnames(trees.inds.tags);
ntags = numel(tags);
for itag = 1:ntags
   trees.inds.tags.(tags{itag}) = trees.inds.tags.(tags{itag}) - lower_ind + 1;
end
for iplot = 1:numel(plots)
   trees.inds.(plots{iplot}) = trees.inds.(plots{iplot}) - lower_ind + 1;
end
for iyr = 1:nyears
   trees.inds.years.(years{iyr}) = trees.inds.years.(years{iyr}) - lower_ind + 1;
end


if dbug;
   disp('After trimming:')
   disp('Lengths of trees.mat, trees.cell:');
   disp([mat2str(length(trees.mat)),' ',mat2str(length(trees.cell))]);
   disp('First index of each year:');
   for iyr = 1:numel(years)
      disp(mat2str(trees.inds.years.(years{iyr})(1)));
   end
   disp('---------------------------------------------------------');
end


%--------------------------------------------------------------------%
% Determine which plots exist across all years being looked at.      %
%--------------------------------------------------------------------%
if isempty(plots);
   tmp = trees.cell(trees.inds.years.(years{1}),3);
   plots = {''};
   for i = 1:numel(tmp)
      if sum(strcmp(plots,tmp{i})) == 0;
         plots{end+1} = tmp{i};
      end
   end
	plots = plots(2:end);
   plots{end+1} = 'all';
end
disp(['Plots :',num2str(numel(plots))])
disp(plots)
nplots = numel(plots);

% Get type/plot/year split
BA = zeros(ntypes,nyears,nplots);
for itype = 1:ntypes
  for iyear = 1:nyears
     for iplot = 1:nplots
        BA(itype,iyear,iplot) = get_BA(trees,plots,iplot,years{iyear},types{itype},normalize,1);
     end
  end
end



%--------------------------------------------------------------------%
% Plot
%--------------------------------------------------------------------%

nffigs = floor(nplots/9);
for ifig = 1:nffigs
   %Open a new figure to plot composition and DBH by year.
   figname = ['Plot Composition Fig ',num2str(ifig)];
   gen_new_fig(figname)

   for iplot = 1:9
      subaxis(3,3,iplot, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
          %names = {'Hourly', 'Monthly', 'Yearly'};
          bar(BA(:,:,iplot + 9*(ifig-1))')
          %set(gca,'XLim',[1,iters(end)]);
          legend({'Hardwoods','Confiers'},'Interpreter','None','Location','NorthWest')
          xlabel('Years')
          ylabel('Total Basal Area of All Plots [m^2]')
          title(['Plot ',plots{iplot + 9*(ifig - 1)}],'Interpreter','None')
   end
end
if mod(nplots,9) > 0
   %Open a new figure to plot composition and DBH by year.
   figname = ['Plot Composition Fig ',num2str(nffigs + 1)];
   gen_new_fig(figname)
   for iplot = 1:mod(nplots,9)
      subaxis(3,3,iplot, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
          %names = {'Hourly', 'Monthly', 'Yearly'};
          bar(BA(:,:,iplot + (nffigs)*9)')
          %set(gca,'XLim',[1,iters(end)]);
          legend({'Hardwoods','Confiers'},'Interpreter','None','Location','NorthWest')
          xlabel('Years')
          ylabel('Total Basal Area of All Plots [m^2]')
          title(['Plot ',plots{iplot + (nffigs)*9}],'Interpreter','None')
   end
end

end






function [BA] = get_BA(trees,plots,iplot,year,type,normalize,dbug)

if dbug; disp('--------------------------------------'); end
if dbug; disp('Call to get_BA, begin output:'); end
if dbug; disp('--------------------------------------'); end
if dbug; disp('size(trees.mat(isnan(trees.mat))):'); end
if dbug; disp( size(trees.mat(isnan(trees.mat)))  ); end
if dbug; disp(['plot, year, type : ', plots{iplot}, ' ', year, ' ', type]); end

%--------------------------------------------------------------------%
% Get/init some important vars.                                      %
%--------------------------------------------------------------------%
tags  = fieldnames(trees.inds.tags);
ntags = numel(tags);
msize = size(trees.mat,1);

plot_mask1D = zeros(msize,1);
year_mask1D = zeros(msize,1);
type_mask1D = zeros(msize,1);
tag_mask1D  = zeros(msize,1);

%--------------------------------------------------------------------%
% Set up simple mask1Ds, then set up derived mask1D for tags.        %
%--------------------------------------------------------------------%
if strcmp(plots{iplot},'all')
   for jplot = 1:numel(plots)-1
      plot_mask1D(trees.inds.plots.(plots{jplot})) = 1;
   end
else
   plot_mask1D(trees.inds.plots.(plots{iplot})) = 1;
end

if strcmp(year,'');
   year_mask1D = ones(msize,1);
else
   year_mask1D(trees.inds.years.(year)) = 1;
end

if strcmp(type,'');
   type_mask1D = ones(msize,1);
else
   type_mask1D(trees.inds.(type)) = 1;
end

skip_check = 0;
%if not(strcmp(tags,''));
   for itag = 1:ntags
      skip_check = skip_check + 1;
      
      tag = tags{itag};
      
      tmp_mask1D  = zeros(msize,1);
      tmp_mask1D(trees.inds.tags.(tag)) = 1;
   
      tmp_mask1D = tmp_mask1D .* year_mask1D;
      tmp = find(tmp_mask1D == 1);
      if numel(tmp) > 0
         first_ind = tmp(1);
         tag_mask1D(first_ind) = 1;
      end
   end
%end

mask1D = plot_mask1D .* year_mask1D .* type_mask1D .* tag_mask1D;
mask2D = [mask1D, mask1D, mask1D, mask1D];


%--------------------------------------------------------------------%
% Apply the mask1Ds to the data to get DBH, then BA                    %
%--------------------------------------------------------------------%
DBH = trees.mat .* mask2D;
BA = (DBH(:,4)/100).^2/4;

if dbug; disp(['size(DBH)                : ', num2str(size(DBH))]); end
%--------------------------------------------------------------------%
% Trim the matrix:                                                   %
% Remove all but first tag data, remove empty rows, and get total.   %
%--------------------------------------------------------------------%
BA(BA == 0)   = [];
BA(isnan(BA)) = [];
ptsize        = size(BA);
BA            = sum(BA);

if dbug; disp(['size(BA) post 0,nan trim : ', num2str(ptsize) ]); end
if dbug; disp([' sum(BA)                 : ', num2str(sum(BA))]); end
if dbug; disp(' '                                              ); end


end


