function [n, step] = getOLALengthAndStep( nw, count, overlap )
%
% Returns the length and step size
%

if ~exist('overlap', 'var'),
    overlap = 0.5;
end

step = floor( nw*(1-overlap) );
n = (count-1)*step + nw; % length of output