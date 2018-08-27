function [params] = short_pnames(params)

% Name replacement dictionary
old = {'vmfact', 'growth_resp_factor', 'storage_turnover_rate', ...
    'root_resp_factor', 'root_turnover_rate','root_respiration_factor', '_co', '_hw'};
new = {'vmf', 'grf', 'str', 'rrf', 'rtr','rrf', '_c_o', '_h_w'};

% Short name conversion
for i = 1:length(new)
    params = strrep(params, old{i}, new{i});
end

% Don't let identical pairs get by
for i = 2:length(params)
    same_ind = strcmp(params{i}, params(1:(i-1)));
    if any(same_ind)
        params{same_ind} = [params{same_ind}, '_c_o'];
        params{i}        = [params{i}       , '_h_w'];
    end
end

end