function subbands = generateSubbands( signal, filts )
%
% Generate subbands from signal with the given filters.
% 
% From McDermott et al.
%

signal = signal(:); % turn into column vector

% FFT
fft_signal = fft(signal);

% Filter
fft_subbands = filts .* ( fft_signal * ones(1, size(filts, 2)) );  % multiply by array of column replicas of fft_sample

% IFFT
subbands = real( ifft(fft_subbands) ); % ifft works on columns; imag part is small, probably discretization error?