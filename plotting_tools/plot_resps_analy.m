function [ ] = plot_resps_analy( data )
%GEN_BREAKDOWN_GRAPH Summary of this function goes here
%   Detailed explanation goes here

% data.T.
nmonths  = length(data.H.CB); % Doesn't matter what monthly variable we use.

%----------------------------------------------------------------------
% Get Breakdown of Plant Respiration Terms
%----------------------------------------------------------------------
% Assign versions with short names, as column vectors...
Re(:,1) = data.H.MMEAN_PLRESP_CO';
Re(:,2) = data.C.MMEAN_PLRESP_CO';
Re(:,3) = data.T.MMEAN_RH_PA';
Re(:,4) = sum(Re,2);

HW(:,1) = data.H.MMEAN_VLEAF_RESP_CO';
HW(:,2) = data.H.MMEAN_STORAGE_RESP_CO';
HW(:,3) = data.H.MMEAN_LEAF_RESP_CO';
HW(:,4) = data.H.MMEAN_ROOT_RESP_CO';
HW(:,5) = data.H.MMEAN_GROWTH_RESP_CO';
HW(:,6) = data.H.MMEAN_PLRESP_CO';

Co(:,1) = data.C.MMEAN_VLEAF_RESP_CO';
Co(:,2) = data.C.MMEAN_STORAGE_RESP_CO';
Co(:,3) = data.C.MMEAN_LEAF_RESP_CO';
Co(:,4) = data.C.MMEAN_ROOT_RESP_CO';
Co(:,5) = data.C.MMEAN_GROWTH_RESP_CO';
Co(:,6) = data.C.MMEAN_PLRESP_CO';

% Determine how respirations are broken down...
HW_cents = HW ./ repmat(data.H.MMEAN_PLRESP_CO',1,6);
Co_cents = Co ./ repmat(data.C.MMEAN_PLRESP_CO',1,6);
Re_cents = Re ./ repmat(Re(:,4),1,4);

% Plot percentages over time.
gen_new_fig('Ecosystem Respiration Breakdown')
subaxis(3,3,1, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,Re_cents(:,1:3)')
   legend('Hardwood','Conifer','Heterotroph');
   title('R_e_c_o Fractions by Month')
   set(gca,'XLim',[1,nmonths])

subaxis(3,3,4, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,HW_cents(:,1:5)')
   legend('Virtual Leaf','Storage','Leaf','Root','Growth');
   title('R_h_w Fractions by Month')
   set(gca,'XLim',[1,nmonths])

subaxis(3,3,7, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.03)
   plot(1:nmonths,Co_cents(:,1:5)')
   legend('Virtual Leaf','Storage','Leaf','Root','Growth');
   title('R_c_o Fractions by Month')
   set(gca,'XLim',[1,nmonths])

% Plot average by-season and by-year pie charts, assuming run starts in june.
grw_mask = logical([0,0,0,0, 1,1,1,1,1, 0,0,0])';
off_mask = ~grw_mask;

grw_ave_msk = logical([1;1;1;0;0;0;0; repmat(grw_mask,2,1)]);
off_ave_msk = ~grw_ave_msk;

% Ecosystem Stuff
Re_grw_ave      = sum(Re(grw_ave_msk,:),1);
Re_grw_ave_cent = Re_grw_ave ./ repmat(Re_grw_ave(:,4),1,4);

Re_off_ave      = sum(Re(off_ave_msk,:),1);
Re_off_ave_cent = Re_off_ave ./ repmat(Re_off_ave(:,4),1,4);

% Hardwood Stuff
HW_grw_ave      = sum(HW(grw_ave_msk,:),1);
HW_grw_ave_cent = HW_grw_ave ./ repmat(HW_grw_ave(:,6),1,6);

HW_off_ave      = sum(HW(off_ave_msk,:),1);
HW_off_ave_cent = HW_off_ave ./ repmat(HW_off_ave(:,6),1,6);

% Conifer Stuff
Co_grw_ave      = sum(Co(grw_ave_msk,:),1);
Co_grw_ave_cent = Co_grw_ave ./ repmat(Co_grw_ave(:,6),1,6);

Co_off_ave      = sum(Co(off_ave_msk,:),1);
Co_off_ave_cent = Co_off_ave ./ repmat(Co_off_ave(:,6),1,6);

colormap(cool)
% Plotting Eco Stuff
subaxis(3,3,2, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.03)
   labels = {'Hardwood','Conifer','Heterotroph'};
   pieplot(Re_grw_ave_cent(1:3),labels)
   title('Growing Season R_e_c_o')

subaxis(3,3,3, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.03)
   labels = {'Hardwood','Conifer','Heterotroph'};
   pieplot(Re_off_ave_cent(1:3),labels)
   title('Off-Season R_e_c_o')
   
% Plotting Hw Stuff
subaxis(3,3,5, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.03)
   labels = {'Virtual Leaf','Storage','Leaf','Root'};
   pieplot(HW_grw_ave_cent(1:4),labels)
   title('Growing Season R_h_w')

subaxis(3,3,6, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.03)
   labels= {'Virtual Leaf','Storage','Leaf','Root','Growth'};
   pieplot(HW_off_ave_cent(1:5),labels)
   title('Off-Season R_h_w')

% Plotting Co Stuff
subaxis(3,3,8, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.03)
   labels= {'Virtual Leaf','Storage','Leaf','Root','Growth'};
   pieplot(Co_grw_ave_cent(1:5),labels)
   title('Growing Season R_c_o')

   subaxis(3,3,9, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.03)
   labels= {'Virtual Leaf','Storage','Leaf','Root','Growth'};
   pieplot(Co_off_ave_cent(1:5),labels)
   title('Off-Season R_c_o')





end