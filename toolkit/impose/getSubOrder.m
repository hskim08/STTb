function subOrder = getSubOrder(startSub, nSubbands)
%
% Decides the subband imposition order
%

subOrder = startSub;
lowSubs = (startSub-1):-1:1; 
l = 1;
highSubs = (startSub+1):nSubbands; 
h = 1;

% add subbands below and above the starting subband
while length(subOrder) < nSubbands,
    if l <= length(lowSubs),
        subOrder = [subOrder lowSubs(l)];
        l = l+1;
    end
    
    if h <= length(highSubs),
        subOrder = [subOrder highSubs(h)];
        h = h+1;
    end
end
