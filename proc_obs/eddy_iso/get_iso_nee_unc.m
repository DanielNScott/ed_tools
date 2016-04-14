function [ NEE_d13C_sd ] = get_iso_nee_unc( NEE )
%GET_ISO_NEE_UNC Uses an unpublished formula (associated with Rick's 2013 paper) to produce
%uncertainty estimates for NEE_d13C data from NEE data. NEE must be in umol/m2/s

NEE_d13C_sd = 0.21495 + 14.204*NEE^(-0.95502);

end

