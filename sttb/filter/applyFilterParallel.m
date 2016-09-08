function subband = applyFilterParallel(signals, filts)
%
% Generates h*h*x signal
%

fft_s = fft(signals);

fft_subband = filts .* fft_s; % multiply by fft_s

subband = real( ifft(fft_subband) ); % ifft works on columns