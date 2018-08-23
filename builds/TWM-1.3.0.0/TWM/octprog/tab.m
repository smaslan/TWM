clear all;

vars = {'f','a'};
second = 'r';
data = {[1;2],[1 2 3],[1 2 3;4 5 6]};

tbl = correction_load_table(data,second,vars)

tbl = correction_interp_table(tbl,[2 2],[1 2],'f',1)