function c1Value = calculateModC1Stats( mod, mods )
% 
% Calculates the between subband modulation statistics for the given subbands.
%
% From McDermott et al.
%

[nFrames, nCorrbands, nModbands] = size(mods);
wi = 1/nFrames;

c1Value = zeros(nCorrbands, nModbands);
for k = 1:nModbands,
    
    dx = mod(:, k); % assumes filters are bandpass, so zero-mean
    sig = sqrt( wi * sum( dx.^2 ) ); 
    
    dy = mods(:, :, k); % assumes filters are bandpass, so zero-mean
    sigy = sqrt( wi * sum( dy.^2 ) ); 
        
    c1Value(:, k) = wi * ( dy' * dx ) ./ (sigy' * sig);
end
