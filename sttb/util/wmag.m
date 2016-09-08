function m = wmag(x, y)
%
% Calculates a weighted magnitude.
%

m = sqrt(sum(x.^2)/y);