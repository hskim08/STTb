function c1Value = calculateModC1AnalyticStats( mod, mods )
% 
% Calculates the C1 correlation of the analytic signals.
%

[nFrames, nCorrbands, nModbands] = size(mods);
wi = 1/nFrames;

c1Complex = zeros(nCorrbands, nModbands);
for k = 1:nModbands,
    
    bs = mod(:, k);
    as = hilbert(bs);
    sig_s = sqrt( wi * sum( bs.^2 ) );
    
    br = mods(:, :, k); % assumes filters are bandpass, so zero-mean
    sig_r = sqrt( wi * sum( br.^2 ) );
    ar = hilbert(br);
    
    c1Complex(:, k) = wi * ( ar' * as ) ./ (sig_r' * sig_s); % NOTE: the first transpose is a conjugate transpose
end

c1Value = zeros(nCorrbands, nModbands, 2);
c1Value(:,:,1) = real(c1Complex);
c1Value(:,:,2) = imag(c1Complex);