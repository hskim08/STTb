function tfStack = stackOLA2(tf, nClipSamples, nStep)
%
% OLA stacking for time-frequency representations.
% Note: this function will zero pad the ends if necessary.
% 
%   Author(s): H.S. Kim, 9-15-16

[nSamples, nSubbands] = size(tf);

nClips = ceil((nSamples-nClipSamples)/nStep+1);
tfStack = zeros(nClipSamples, nSubbands, nClips);

for iClip = 1:nClips,
    startIdx = (iClip-1)*nStep + 1;
    endIdx = min((iClip-1)*nStep + nClipSamples, nSamples);
    l = endIdx-startIdx+1;
    
    tfStack(1:l,:,iClip) = tf(startIdx:endIdx, :);
end