function X = stackOLA(x, nw, overlap, offsets)
%
% Stacks a signal into overlap-add chunks.
%
% x - A single channel signal
% nw - The frame length in samples.
% overlap - If overlap is less than 1, it is the overlap ratio. If overlap 
%           is greater than one, it is the overlap in samples. Default 
%           value is 0.5.
%
% Returns
% X - the unwindowed overlap-add stack
% 
%   Author(s): H.S. Kim, 9-15-16

if ~exist('overlap', 'var'),
    overlap = 0.5;
end

n = length(x);
[step, count] = getOLAStepAndCount(n, nw, overlap);
if ~exist('offsets', 'var'),
    offsets = zeros(count, 1);
end



X = zeros(nw, count);
xx = zeros(nw*count, 1); % zero pad
xx(1:length(x)) = x;
for i = 1:count,
    startIdx = 1 + (i-1)*step + offsets(i);
    endIdx = nw + (i-1)*step + offsets(i);
    
    if startIdx < 1, % zero pad front
        startIdx = 1;
        clipLength = endIdx - startIdx + 1;
        X((end-clipLength+1):end, i) = xx(startIdx:endIdx);
    else
        if endIdx > length(x),  % zero pad back
            endIdx = length(x);
            clipLength = endIdx - startIdx + 1;
            X(1:clipLength, i) = xx(startIdx:endIdx);
        else
            clipLength = endIdx - startIdx + 1;
            X(1:clipLength, i) = xx(startIdx:endIdx);
        end
    end
%     X(1:interval, i) = xx(startIdx:endIdx);
end