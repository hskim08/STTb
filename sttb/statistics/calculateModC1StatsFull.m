function c1Value = calculateModC1StatsFull( mods )
% 
% Calculates the between subband modulation statistics for all subbands.
%
% From McDermott et al.
%

[nFrames, nSubbands, nModbands] = size(mods);
wi = 1/nFrames;

% get C1 correlation
c1Value = zeros(nSubbands, nSubbands, nModbands);
for k = 1:nModbands, % for each modulation band
    dx = mods(:, :, k); % assumes filters are bandpass, so zero-mean
    m2 = wi * sum( dx.^2 );
    sig = sqrt( m2 ); % standard devs
        
    c1Value(:, :, k) = wi * ( dx' * dx ) ./ (sig' * sig);
end