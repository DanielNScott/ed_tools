function [ input ] = char_sub( input,str_from,str_to )
%UND_TO_SPACE Takes a cell array with character entries and turns underscores into spaces.


if iscell(input)
   num_items = numel(input);
   for item_num = 1:num_items
      cur_item = input{item_num};
      cur_item(cur_item == str_from) = str_to;
      input{item_num} = cur_item;
   end
else
   input(input == str_from) = str_to;
end
   
   
end

