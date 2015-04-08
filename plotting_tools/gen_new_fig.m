function [ ] = gen_new_fig( figname )
% Summary of this function goes here
%   Detailed explanation goes here

figure('Name',figname)
set(gcf,'Position',[1 1 1280 1024]);
set(gcf, 'Color', 'white');

end

