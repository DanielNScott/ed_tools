function [ ] = plot_cb_analy( data )
%GRAPH_CB_ANALY Plots a 6 panel plot outlining carbon use for runinfo input as 'data'
%   Input:
%     data - structure with fields 'T','Hw','Co' etc.
%   Output:
%     Plots of 

nmonths  = length(data.H.CB); % Doesn't matter what monthly variable we use.

Hw(:,1)  = data.H.CB;
Hw(:,2)  = data.H.MMEAN_NPP_CO;
Hw(:,4)  = data.H.MMEAN_PLRESP_CO;
Hw(:,3)  = data.H.MMEAN_GPP_CO;
Hw(:,5)  = data.H.MMEAN_LEAF_DROP_CO;
Hw(:,6)  = data.H.MMEAN_LEAF_MAINTENANCE_CO;
Hw(:,7)  = data.H.MMEAN_ROOT_MAINTENANCE_CO;
Hw(:,8)  = data.H.MMEAN_NPPDAILY_CO;
Hw(:,9)  = data.H.MMEAN_NPPFROOT_CO;
Hw(:,10) = data.H.MMEAN_NPPLEAF_CO;
Hw(:,11) = data.H.MMEAN_NPPCROOT_CO;
Hw(:,12) = data.H.MMEAN_NPPWOOD_CO;
Hw(:,13) = data.H.MMEAN_NPPSAPWOOD_CO;
Hw(:,14) = data.H.MMEAN_NPPSEEDS_CO;

Co(:,1) = data.C.CB;
Co(:,2) = data.C.MMEAN_NPP_CO;
Co(:,4) = data.C.MMEAN_PLRESP_CO;
Co(:,3) = data.C.MMEAN_GPP_CO;
Co(:,5) = data.C.MMEAN_LEAF_DROP_CO;
Co(:,6) = data.C.MMEAN_LEAF_MAINTENANCE_CO;
Co(:,7) = data.C.MMEAN_ROOT_MAINTENANCE_CO;
Co(:,8)  = data.C.MMEAN_NPPDAILY_CO;
Co(:,9)  = data.C.MMEAN_NPPFROOT_CO;
Co(:,10) = data.C.MMEAN_NPPLEAF_CO;
Co(:,11) = data.C.MMEAN_NPPCROOT_CO;
Co(:,12) = data.C.MMEAN_NPPWOOD_CO;
Co(:,13) = data.C.MMEAN_NPPSAPWOOD_CO;
Co(:,14) = data.C.MMEAN_NPPSEEDS_CO;

[~, hw_perm] = sort(sum(Hw(:,8:10),1),'descend');
[~, co_perm] = sort(sum(Co(:,8:10),1),'descend');

Hw_NPP_Vars = Hw(:,8:10);
Co_NPP_Vars = Co(:,8:10);

Hw_NPP_Vars = Hw_NPP_Vars(:,hw_perm);
Co_NPP_Vars = Co_NPP_Vars(:,co_perm);

gen_new_fig('Carbon Use')

% Hardwoods
subaxis(2,3,1, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,Hw(:,1:3)')
   labels = {'CB','NPP','R_h_w'};
   set(gca,'XLim',[1,nmonths])
   legend(labels)
   title('Hardwood Fluxes and C Bal.')
   ylabel('kgC/m^2/yr')
   xlabel('Time')
   
subaxis(2,3,2, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,Hw_NPP_Vars')
   labels = {'NPP Daily','Xfer to Roots','Xfer to Leaves'};
   labels = labels(hw_perm);
   set(gca,'XLim',[1,nmonths])
   legend(labels)
   title('Hardwood C Capture and Use')
   ylabel('kgC/m^2/yr')
   xlabel('Time')
   
subaxis(2,3,3, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,Hw(:,5:7)')
   %labels = {'GPP','Resp','Leaf Drop','Leaf Maint','Root Maint'};
   labels = {'Leaf Drop','Leaf Maint','Root Maint'};
   set(gca,'XLim',[1,nmonths])
   legend(labels)
   title('Hardwood Non-Resp Losses')
   ylabel('kgC/m^2/yr')
   xlabel('Time')
   
% Conifers   
subaxis(2,3,4, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,Co(:,1:3)')
   labels = {'CB','NPP','R_c_o'};
   set(gca,'XLim',[1,nmonths])
   legend(labels)
   title('Conifer Fluxes and C Bal.')
   ylabel('kgC/m^2/yr')
   xlabel('Time')
   
subaxis(2,3,5, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,Co_NPP_Vars')
   labels = {'NPP Daily','Xfer to Roots','Xfer to Leaves'};
   labels = labels(co_perm);
   set(gca,'XLim',[1,nmonths])
   legend(labels)
   title('Conifer C Capture and Use')
   ylabel('kgC/m^2/yr')
   xlabel('Time')

subaxis(2,3,6, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,Co(:,5:7)')
   %labels = {'GPP','Resp','Leaf Drop','Leaf Maint','Root Maint'};
   labels = {'Leaf Drop','Leaf Maint','Root Maint'};
   set(gca,'XLim',[1,nmonths])
   legend(labels)
   title('Conifer Non-Resp Losses')
   ylabel('kgC/m^2/yr')
   xlabel('Time')



end