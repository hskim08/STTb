function c1Values = calculateModC1AnalyticStatsFull( mods )
% 
% Calculates the C1 correlation of the analytic signals.
%

[nFrames, nSubbands, nModbands] = size(mods);
wi = 1/nFrames;

% get C1 correlation
c1_complex = zeros(nSubbands, nSubbands, nModbands);

for k = 1:nModbands, % for each modulation band
    bk = mods(:, :, k); % assumes filters are bandpass, so zero-mean
    sig = sqrt( wi * sum( bk.^2 ) ); % standard devs
    
    ak = hilbert(bk);
        
    c1_complex(:, :, k) = wi * ( ak' * ak ) ./ (sig' * sig); % NOTE: the first transpose is a conjugate transpose
end

c1Values = zeros(nSubbands, nSubbands, nModbands, 2);
c1Values(:,:,:,1) = real(c1_complex);
c1Values(:,:,:,2) = -imag(c1_complex); % minus is to match with the values of calculateModC1AnalyticStats

