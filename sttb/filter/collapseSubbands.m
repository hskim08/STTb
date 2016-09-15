function signal = collapseSubbands( subbands, filts )
%collapseSubbands    Merges subbands with the given filters.
%
% Parameters:
% subbands - A multiband signal
% filt - The filterbank
%
% Returns:
% signal - The single channel signal. 
% 
% From McDermott et al.
%

% FFT
fft_all = fft(subbands);

% Filter
fft_subbands = filts .* fft_all;

% IFFT
subbands = real(ifft(fft_subbands));

% Merge
signal = sum(subbands, 2);
