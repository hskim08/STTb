function signal = collapseSubbands( subbands, filts )
%
% Merges subbands with the given filters.
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
