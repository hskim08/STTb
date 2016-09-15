function [filts, centerFreqs, freqs] = makeCQTFilters( signalLength, sampleRate, ...
    nFilters, cutoffLow, cutoffHigh, Qfactor, figNum )
%makeCQTFilters    Makes a Constant Qfactor Transform filterbank.
%
% Parameters:
% signalLength - The length of the signal to filter.
% sampleRate - The sampling rate.
% nFilters - The number of filters.
% cutoffLow - The low cutoff frequency.
% cutoffHigh - The high cutoff frequency.
% Qfactor - The Q-factor of the filters.
% figNum - (Optional) When specified, it will create plots of the filter
%   with the figure number set to figNum.
%
% Returns:
% filts - The filterbank in the frequency domain.
% centerFreqs - The center frequencies.
% freqs - The frequencies for each filter point.
% 
% From McDermott et al.
% 

% linear scale frequencies

if rem(signalLength, 2) == 0, % even length
    nFreqs = signalLength/2; % does not include DC
    maxFreq = sampleRate/2; % go all the way to nyquist
else % odd length
    nFreqs = (signalLength-1)/2;
    maxFreq = sampleRate/2 * (signalLength-1)/signalLength; % max freq is just under nyquist
end 

freqs = 0:(maxFreq/nFreqs):maxFreq;  

if cutoffHigh > sampleRate/2,
    cutoffHigh = maxFreq;
end

% make center frequencies evenly spaced on a log scale
% want highest cos filter to go up to cutoffHigh
lo = log2( cutoffLow );
hi = log2( cutoffHigh );
step = (hi-lo) / (nFilters-1);
centerFreqs = 2.^(lo:step:hi);


% easy-to-implement version: filters are symmetric on linear scale
cos_filts = zeros(nFreqs+1, nFilters);
for iFilter = 1:nFilters,
    bw = centerFreqs(iFilter) / Qfactor;
    l = centerFreqs(iFilter) - bw; % so that half power point is at Cf-bw/2
    h = centerFreqs(iFilter) + bw;
    l_ind = find(freqs>l, 1 );
    h_ind = find(freqs<h, 1, 'last' );
    
    avg = centerFreqs(iFilter); 
    rnge = h - l; % 2*bw
    cos_filts(l_ind:h_ind, iFilter) = cos( (freqs(l_ind:h_ind) - avg) * pi / rnge); % map cutoffs to -pi/2, pi/2 interval
end

temp = sum(cos_filts'.^2);
filts = cos_filts / sqrt(mean( temp( (freqs>=centerFreqs(4)) & (freqs<=centerFreqs(end-3)) ) ));


% plot filters
if exist('figNum', 'var'),
    figure(figNum);
    set(gcf, 'Name', 'CQT Filterbank');

    subplot(3,1,1); 
    plot(freqs, filts.^2);
    title('Linear Frequency Scale');
    ylim([-0.1 1.1]);

    subplot(3,1,2); 
    semilogx(freqs, filts.^2);
    title('Log Frequency Scale');
    ylim([-0.1 1.1]);
    xlim([0 max(freqs)]);

    subplot(3,1,3); 
    plot(freqs, sum(filts.^2, 2));
    title('Filterbank Sum');
    ylim([-0.1 1.1]);
end