function [ ed_output ] = get_isoflux( ed_output )
%GET_ISOFLUX Takes an ed output datastructure and appends the hourly isoflux.

ed_output.T.FMEAN_NEP_ISOFLUX = ed_output.T.FMEAN_NEP_PY .* ed_output.T.FMEAN_NEP_d13C_PY;

end

