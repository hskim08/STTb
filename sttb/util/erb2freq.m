function freq_Hz = erb2freq(n_erb)
% FUNCTION FREQ_HZ = ERB2FREQ(N_ERB)
%
% Converts ERBs to Hz, using the formula of Glasberg and Moore.


freq_Hz = 24.7*9.265*(exp(n_erb/9.265)-1);

