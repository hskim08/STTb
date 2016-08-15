function [grad_r, grad_i] = calculateModC2Grads( mods, filts, mods2 )
%
% Full calculation of the C2 correlations
%

nFrames = size(mods, 1);
wi = 1/nFrames;

% make analytic subbands
analytic_subbands = hilbert(mods);

% lower band
a_m = analytic_subbands(:, 1);
b_m = mods(:, 1); % real( a_m );
b_m_hat = imag( a_m );

% higher band
a_n = analytic_subbands(:, 2);
b_n = mods(:, 2); % real( a_n );
b_n_hat = imag( a_n );

% sigmas
sig_m = sqrt( wi * sum( b_m.^2 ) );
sig_n = sqrt( wi * sum( b_n.^2 ) );
alpha = sig_m * sig_n;

% d_sm related
a_m_abs = abs( a_m );
beta_mR = b_m ./ a_m_abs;
beta_mI = b_m_hat ./ a_m_abs;

d_m = (a_m.^2) ./ a_m_abs;
d_mR = real(d_m);
d_mI = imag(d_m);

% filters
h_m = filts(:, 1);
h_n = filts(:, 2);


%
% calculate gradient
%

% part 1-1
beta_mR2 = beta_mR.^2;

ff1 = (3 - 2*beta_mR2) .* beta_mR;
ff2 = (1 + 2*beta_mR2) .* beta_mI; % = (3 - 2*beta_mI.^2) .* beta_mI;

f1 = ff1 .* b_n;
f2 = ff2 .* b_n;
f3 = ff1 .* b_n_hat;
f4 = ff2 .* b_n_hat;

real_dv11 = applyFilter( h_m, f1 ) ... % 
    + hiltrans( applyFilter( h_m, f2 ) );
imag_dv11 = applyFilter( h_m, f3 ) ... % 
    + hiltrans( applyFilter( h_m, f4 ) );

% part 1-2
dmRhn = applyFilter( h_n, d_mR ); 
real_dv12 = dmRhn; 
imag_dv12 = -hiltrans( dmRhn ); 

real_dv1 = real_dv11 + real_dv12;
imag_dv1 = imag_dv11 + imag_dv12;

% part 3
hbm = mods2(:, 1); 
hbn = mods2(:, 2); 
alpha_p = wi * ( sig_n/sig_m*hbm + sig_m/sig_n*hbn );

real_dv3R = sum(d_mR .* b_n);
imag_dv3R = sum(d_mR .* b_n_hat);

% % previous implementation
% grad_r = 2*wi*( real_dv1 - real_dv3R*alpha_p/alpha ) / alpha;
% grad_i = 2*wi*( imag_dv1 - imag_dv3R*alpha_p/alpha ) / alpha;


% part 2-1
gg1 = beta_mI.^3;
gg2 = beta_mR.^3;

g1 = gg1 .* b_n_hat;
g2 = gg2 .* b_n_hat;
g3 = gg1 .* b_n;
g4 = gg1 .* b_n;

real_dv21 = applyFilter( h_m, g1 )... % 
    + hiltrans( applyFilter( h_m, g2 ) );
imag_dv21 = applyFilter( h_m, g3 ) ... % 
    + hiltrans( applyFilter( h_m, g4 ) );

% part 2-2
dmIhn = applyFilter( h_n, d_mI ); 
real_dv22 = -hiltrans( dmIhn ); 
imag_dv22 = dmIhn;

real_dv2 = real_dv21 + 2*real_dv22;
imag_dv2 = imag_dv21 + 2*imag_dv22;

% part 3
real_dv3I = sum(d_mI .* b_n_hat);
imag_dv3I = sum(d_mI .* b_n);


% final value
grad_r = wi*( real_dv1 + real_dv2 - (real_dv3R + real_dv3I)*alpha_p/alpha ) / alpha;
grad_i = wi*( imag_dv1 - imag_dv2 - (imag_dv3R - imag_dv3I)*alpha_p/alpha ) / alpha;



% %
% % The Hilbert Transform 
% % imaginary part of the analytic signal
% % Function added to increase legibility
% %
% function y = hiltrans(x)
%     y = imag( hilbert( x ) );

