function x = pressOLAStack(X, shift, overlap)
%
% Renders an overlap-add stack into the original signal.
% It assumes the stacked signals are already windowed.
%
% X - a stacked overlap-add
% shift - 1: sum with shift(default), 0: just sum the stack in place
% overlap - the overlap ratio. expected range is 0 to 1. only works when
%           shift is 1.
%
% Returns
% x - the rendered signal
%

% handle input options
if ~exist('shift', 'var'),
    shift = 1;
end

if ~exist('overlap', 'var'),
    overlap = 0.5;
end

[nw, count] = size(X);
if shift, % need step size
    [n, step] = getOLALengthAndStep( nw, count, overlap );
    x = zeros(n, 1);
    for i = 1:count
        x( (1:nw) + step*(i-1) ) = x( (1:nw) + step*(i-1) ) ...
            + X(:, i);
    end
else
    x = sum(X, 2);
end


% %
% % Returns the length and step size
% %
% function [n, step] = getOLALengthAndStep( overlap, nw, count )
% step = floor( nw*(1-overlap) );
% n = (count-1)*step + nw; % length of output