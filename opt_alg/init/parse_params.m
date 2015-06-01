function [ nfo, ui ] = parse_params( nfo, ui )
%PARSE_METADATA Summary of this function goes here
%   Detailed explanation goes here

%----------------------------------------------------------------------------------------------%
% Throughout this optimization program p_means is used as the set of parameter means, p_sdevs as
% their standard deviations, and labels is used to identify these vars by name and to determine
% which pfts each 'version' of the parameter should be applied to. See settings_ed_opt for more
% information.
%----------------------------------------------------------------------------------------------%


nfo.simres = '';
% Extract some information from the parameter matrix.
if nfo.is_test
   label_rng = 1;
   means_ind = 2;
   sdevs_ind = 3;
   bnd_ind   = 4;
   mask_ind  = 5;
else
   label_rng = 1:3;
   means_ind = 4;
   sdevs_ind = 5;
   bnd_ind   = 6;
   mask_ind  = 7;
end
row_msk     = cell2mat(ui.params(:,mask_ind)) == 1;

ui.means    = cell2mat(ui.params(row_msk, means_ind)) *ui.multiplier;
ui.sdevs    = cell2mat(ui.params(row_msk, sdevs_ind)) *ui.multiplier;
ui.bounds   = cell2mat(ui.params(row_msk,   bnd_ind)) *ui.multiplier;
ui.labels   = ui.params(row_msk, label_rng);

nfo.simres  = get_simres(ui.opt_metadata);

% Tell the user what's up
if any(strcmp(ui.model,{'ED2.1','read_dir'}))
   disp(['ED Parameter matrix loaded with multiplier ', num2str(ui.multiplier)])
   disp(ui.params(cell2mat(ui.params(:,end)) == 1,1:end-1));
end

end

