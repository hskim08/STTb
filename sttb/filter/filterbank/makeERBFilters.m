function [filts, cutoffs, freqs] = makeERBFilters( signalLength, sampleRate, ...
    nFilters, cutoffLow, cutoffHigh, figNum )
%makeERBFilters    Makes an Equivalent Rectangular Bandwidth (ERB) spaced 
% filterbank.
%
% Parameters:
% signalLength - The length of the signal to filter.
% sampleRate - The sampling rate.
% nFilters - The number of filters.
% cutoffLow - The low cutoff frequency.
% cutoffHigh - The high cutoff frequency.
% figNum - (Optional) When specified, it will create plots of the filter
%   with the figure number set to figNum.
%
% Returns:
% filts - The filterbank in the frequency domain.
% cutoffs - The cutoff frequencies.
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

% make cutoffs evenly spaced on an erb scale
lo = freq2erb( cutoffLow );
hi = freq2erb( cutoffHigh );
step = (hi-lo) / (nFilters+1);
cutoffERBs = lo:step:hi;
cutoffs = erb2freq( cutoffERBs );

% create filters
filts = zeros(nFreqs+1, nFilters+2);
for iFilter = 1:nFilters,
    l = cutoffs(iFilter);
    h = cutoffs(iFilter + 2); % adjacent filters overlap by 50%
    l_ind = find( freqs > l, 1 );
    h_ind = find( freqs < h, 1, 'last' );
    
    avg = (cutoffERBs(iFilter) + cutoffERBs(iFilter+2))/2;
    rnge = cutoffERBs(iFilter+2) - cutoffERBs(iFilter);
    filts(l_ind:h_ind, iFilter+1) = cos( (freq2erb( freqs(l_ind:h_ind) ) - avg) ...
       * pi / rnge ); % map cutoffs to -pi/2, pi/2 interval
end

% add lowpass and highpass to get perfect reconstruction
% LPF - lowpass filter goes up to peak of first cos filter
h_ind = find( freqs < cutoffs(2), 1, 'last' ); % max(find(freqs<cutoffs(2))); 
filts(1:h_ind, 1) = sqrt(1 - filts(1:h_ind, 2).^2);

% HPF - highpass filter goes down to peak of last cos filter
l_ind = find( freqs > cutoffs(nFilters+1), 1 ); % min(find(freqs>cutoffs(nFilters+1))); 
filts(l_ind:nFreqs+1, nFilters+2) = sqrt(1 - filts(l_ind:nFreqs+1, nFilters+1).^2);


% plot filters
if exist('figNum', 'var'),
    figure(figNum);
    set(gcf, 'Name', 'ERB Filterbank');
    
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