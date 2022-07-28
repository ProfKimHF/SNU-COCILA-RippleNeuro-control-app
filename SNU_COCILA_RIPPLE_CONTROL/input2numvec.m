function [resulting_vect] = input2numvec(input_cell)

resulting_vect = [];
split_tmp1 = split(input_cell, ' ');
index = cellfun(@(x) contains(x,'~'),split_tmp1);
str_tmp1 = split_tmp1(~index);

resulting_vect = [resulting_vect cell2mat(cellfun(@(x) str2num(x), str_tmp1,'UniformOutput',false))];
resulting_vect = resulting_vect(:)';
split_tmp2 = split(split_tmp1(index),'~');

if ~isempty(split_tmp2)
if size(split_tmp2,2) == 1
split_tmp2_mat = cell2mat(split_tmp2);
split_tmp2_num = str2num(split_tmp2_mat);
resulting_vect = [resulting_vect split_tmp2_num(1):split_tmp2_num(2) ];

else 

   num_tmp = cellfun(@(x) str2num(x), split_tmp2);
for i = 1:size(num_tmp,1)
   num = [num_tmp(i,1):1:num_tmp(i,end)];
   resulting_vect = [resulting_vect num];
end
end
end

resulting_vect = unique(resulting_vect); 


