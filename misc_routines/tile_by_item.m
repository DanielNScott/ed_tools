function [out_vec] = tile_by_item(col_vec, n_tiles)

orig_len = length(col_vec);
out_vec  = reshape(repmat(col_vec', n_tiles, 1), orig_len * n_tiles, 1);

end

