function subband = applyFilterParallel( signals, filts )
%applyFilterParallel    Applies the filters in parallel
% 
% Applies a filterbank to each signal.
% 
% Parameters:
% signals - A multiband signal. Usually processed by filts using applyFilter().
% filt - The filterbank
%
% Returns:
% subband - The parallel filtered subband signal. 
% 
% For a filterbank with nSubbands and multiband signal of length nSamples, the output
% subband has a size of [nSamples, nSubbands].
% 
% This is used to generate the double filtered signal used in gradient
% calculations.
% 
% % Example:
% % Create a double filtered signal
% 
% subband = generateSubbands(signal, filts);
% filtSubband = applyFilterParallel(subband, filts);
% 

fft_s = fft(signals);

fft_subband = filts .* fft_s; % multiply by fft_s

subband = real( ifft(fft_subband) ); % ifft works on columns