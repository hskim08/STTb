function [filts,centerFreqs,freqs] = makeOctaveBandFilters( signalLength, sampleRate, ...
    cutoffLow, cutoffHigh, figNum )
%makeOctaveBandFilters    Makes an Octave spaced filterbank.
%
% Parameters:
% signalLength - The length of the signal to filter.
% sampleRate - The sampling rate.
% cutoffLow - The low cutoff frequency.
% cutoffHigh - The high cutoff frequency.
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
if rem( signalLength, 2 ) == 0, % even length
    nFreqs = signalLength/2; % does not include DC
    maxFreq = sampleRate/2; % go all the way to nyquist
else % odd length
    nFreqs = (signalLength - 1)/2;
    maxFreq = sampleRate/2 * (signalLength - 1)/signalLength; % max freq is just under nyquist
end 
freqs = 0:(maxFreq/nFreqs):maxFreq; 

if cutoffHigh > sampleRate/2,
    cutoffHigh = maxFreq;
end

% make cutoffs octave spaced
cutoffs = cutoffHigh ./ (2.^(0:20)); % NOTE: is 20 a large enough number?
cutoffs = fliplr( cutoffs(cutoffs > cutoffLow) ); 
centerFreqs = cutoffs(1:end-1);
nFilters = length(centerFreqs);

filts = zeros(nFreqs+1, nFilters+1);
for iFilter = 1:nFilters,
    l = centerFreqs(iFilter) / 2;
    h = centerFreqs(iFilter) * 2; % adjacent filters overlap by 50%
    l_ind = find( freqs>l, 1 );
    h_ind = find( freqs<h, 1, 'last' );
    
    avg = (log2(l) + log2(h)) / 2;
    rnge = log2(h) - log2(l);
    filts(l_ind:h_ind,iFilter) = cos( (log2( freqs(l_ind:h_ind) ) - avg)...
        * pi / rnge ); % map cutoffs to -pi/2, pi/2 interval
end

% Add hi-pass
l = cutoffHigh / 2;
h = cutoffHigh * 2; % adjacent filters overlap by 50%
l_ind = find(freqs>l, 1 );
h_ind = nFreqs+1; % find(freqs<cutoffHigh, 1, 'last' );

avg = (log2(l) + log2(h)) / 2;
rnge = log2(h) - log2(l);
filts(l_ind:h_ind, nFilters+1) = cos( (log2( freqs(l_ind:h_ind) ) - avg)...
    * pi / rnge ); % map cutoffs to -pi/2, pi/2 interval


% plot filters
if exist('figNum', 'var'),
    figure(figNum);
    set(gcf, 'Name', 'Octave-band Filterbank');
    
    subplot(3,1,1); 
    plot(filts.^2); 
    title('Linear Frequency Scale');
    ylim([-0.1 1.1]);
    
    subplot(3,1,2); 
    semilogx(filts.^2);
    title('Log Frequency Scale');
    ylim([-0.1 1.1]);

    % verify flat spectrum
    subplot(3,1,3); 
    plot(sum(filts.^2,2));
    title('Filterbank Sum');
    ylim([-0.1 1.1]);
end