function [ bai, mort ] = get_incs( trees )
%GET_INCS Summary of this function goes here
%   Detailed explanation goes here

midyear_mask = and(trees.mat(:,2) >= 170, trees.mat(:,2) <= 175);

processed = [];
for i=1:length(midyear_mask)
    if sum(midyear_mask(i,:)) > 0
        processed = [processed; trees.mat(i,:)];
    end
end

disp(processed)

% Compile list of tree tags.
tags = [];
for i = 1:length(processed)
    if processed(i,1) == 1999
        if sum(processed(i,3) == tags) > 0
            continue
        else
            tags(end+1) = processed(i,3);
        end
    end
    if processed(i,1) > 1999
       if sum(processed(i,3)) == tags) > 0
           continue
       else
           
       end
    end
end

disp(tags')



end

