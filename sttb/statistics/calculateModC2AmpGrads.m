function grad_mn = calculateModC2AmpGrads( bm, bn, hm, hn, bm_hat, bn_hat, ...
    am_amp, an_amp, sig_m, sig_n, hbm, hbn, c2_amps )
%
% Calculate the C2 amplitude correlation gradient for the given bands. 
%

nFrames = length(bm);
wi = 1/nFrames;

% am = hilbert(bm);
% bm_hat = imag(am);
% am_amp = abs(am);
% sig_m = sqrt( wi*sum(bm.^2) );

% an = hilbert(bn);
% bn_hat = imag(an);
% an_amp = abs(an);
% sig_n = sqrt( wi*sum(bn.^2) );

alpha = sig_m * sig_n;

f1 = am_amp./an_amp .* bn;
f2 = am_amp./an_amp .* bn_hat;
f3 = an_amp./am_amp .* bm;
f4 = an_amp./am_amp .* bm_hat;

grad_mn = wi / alpha * ( applyFilter( f1, hn ) ...
    - hiltrans( applyFilter( f2, hn ) ) ...
    + applyFilter( f3, hm ) ...
    - hiltrans( applyFilter( f4, hm ) ) ...
    - c2_amps * ( (sig_n/sig_m)*hbm + (sig_m/sig_n)*hbn ) );

% %
% % The Hilbert Transform 
% % imaginary part of the analytic signal
% % Function added to increase legibility
% %
% function y = hiltrans(x)
%     y = imag( hilbert( x ) );
