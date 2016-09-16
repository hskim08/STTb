function m = wmag(x, y)
%
% Calculates a weighted magnitude.
%
% 
%   Author(s): H.S. Kim, 9-15-16


m = sqrt(sum(x.^2)/y);