function subband = applyFilter( filt, s )
%
% Applies filter to signal
%

s = s(:); % turn into column vector

fft_subband = filt .* fft(s); % fft and filter
subband = real( ifft(fft_subband) ); % ifft, remove noise

