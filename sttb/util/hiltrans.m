function y = hiltrans(x)
%hiltrans    The Hilbert Transform 
% 
% imaginary part of the analytic signal
% Function added to increase legibility
%

y = imag( hilbert( x ) );
