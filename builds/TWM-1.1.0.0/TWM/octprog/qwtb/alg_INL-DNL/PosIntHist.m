function y = PosIntHist(x)
% @fn PosIntHist
% @brief Creates histogram form positive integer values
% @param x The vector or matrix that conatins the positive integers
% @return y The histogram calculated
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Infromation Systems,
%         Virosztek.Tamas@mit.bme.hu

[s1,s2] = size(x);
if ~isempty(find(x ~= round(x),1)) || (min(x) < 1);
    error('Input values are not positive integers');
end
y = zeros(max(max(x)),1);

for k = 1:s1
    for l = 1:s2
        y(x(k,l)) = y(x(k,l)) + 1;
    end
end

end
