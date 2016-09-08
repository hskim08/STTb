function c2Value = calculateModC2AmpStatsFull( mods )
% 
% Calculate the full C2 amplitude correlation
%

nFrames = size( mods, 1 );
wi = 1/nFrames;

% get C1 correlation

b = mods; % assumes filters are bandpass, so zero-mean
a = hilbert(b);
amps = abs(a);

sig = sqrt(wi * sum( b.^2 )); % standard devs

c2Value = wi * ( amps' * amps ) ./ (sig' * sig);
