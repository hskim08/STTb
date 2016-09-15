function out = applyFilter( signal, filt )
%applyFilter    Applies filter to signal.
%
% Parameters:
% signal - A single channel signal
% filt - A single filter in the frequency domain
%
% Returns:
% out - The filtered signal. 
%

s = signal(:); % turn into column vector

fftFilt = filt .* fft(s); % fft and filter
out = real( ifft(fftFilt) ); % ifft, remove noise

