function [n, step] = getOLALengthAndStep( nw, count, overlap )
%
% Returns the length and step size
%
% 
%   Author(s): H.S. Kim, 9-15-16

if ~exist('overlap', 'var'),
    overlap = 0.5;
end

step = floor( nw*(1-overlap) );
n = (count-1)*step + nw; % length of output