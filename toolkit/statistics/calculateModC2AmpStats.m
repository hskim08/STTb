function c2Value = calculateModC2AmpStats( am_amp, an_amp, sig_m, sig_n )
% 
% Calculate the C2 amplitude correlation for the given bands.
%

[nFrames, ~] = size( am_amp );
wi = 1/nFrames;

% sig_m = sqrt(wi * sum( bm.^2 )); % assumes filters are bandpass, so zero-mean
% sig_n = sqrt(wi * sum( bn.^2 )); % assumes filters are bandpass, so zero-mean

c2Value = wi * sum( am_amp .* an_amp ) / (sig_m * sig_n);