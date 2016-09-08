function [step, count] = getOLAStepAndCount(n, nw, overlap)
%
% Returns the step size and frame count
%

% TODO: display error if overlap > nw

if overlap > 1, % in samples
    step = overlap;
else
    step = floor( nw*(1-overlap) );
end

count = ceil( (n-nw)/step ) + 1;
% count = floor( (n-nw)/step ) + 1;