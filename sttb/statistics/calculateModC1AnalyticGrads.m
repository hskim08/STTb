function [grad_r, grad_i] = calculateModC1AnalyticGrads( bs, br, hbs, hbr, ...
    hbr_hat, current_cbc )
%
% Calculates the gradient for C1 correlation using analytic signals
%
% See also getCostAndGradient

nFrames = length(bs);
wi = 1/nFrames;

sig_s = sqrt( wi * sum( bs.^2 ) ); % assumes filters are bandpass, so zero-mean
sig_r = sqrt( wi * sum( br.^2 ) ); % assumes filters are bandpass, so zero-mean

% brh_hat = imag(hilbert(brh)); % pre-computed!

grad_r = wi/sig_s * ( 2*hbr/sig_r - hbs/sig_s * current_cbc(1) );
grad_i = -wi/sig_s * ( 2*hbr_hat/sig_r + hbs/sig_s * current_cbc(2) );