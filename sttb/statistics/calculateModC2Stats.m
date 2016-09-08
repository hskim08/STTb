function c2value = calculateModC2Stats( mods )
% 
% Calculates the within subband modulation statistics.
%
% From McDermott et al.
%

[nFrames, nModbands] = size(mods);
wi = 1/nFrames;

% make subbands analytic
analyticSubbands = hilbert(mods);

offset = 1;
c2value = zeros(nModbands-offset, 2);
for iModband = 1:nModbands-offset,
    bk = mods(:, iModband);
    ak = analyticSubbands(:, iModband);
    dk = ( ak.^2 ) ./ abs( ak ); % phase adjusted coarse subband, normalized
    sig = sqrt( wi * sum( bk.^2 ) );
    
    bko = mods(:, iModband+offset);
    ako = analyticSubbands(:, iModband+offset);
    sigo = sqrt( wi * sum( bko.^2  ) );
    
    cc = wi * sum( conj(dk) .* ako ) / (sig*sigo);
    
    c2value(iModband, 1) = real(cc);
    c2value(iModband, 2) = imag(cc);
end

