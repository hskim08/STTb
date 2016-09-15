function subbands = generateSubbands( signal, filts )
%generateSubbands    Generate subbands from signal with the given filters.
%
% Parameters:
% signal - A single channel signal
% filt - The audio filterbank
%
% Returns:
% subband - The subband signal. 
% 
% For a filterbank with nSubbands and a signal of length nSamples, the output
% subband has a size of [nSamples, nSubbands]
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