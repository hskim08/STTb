function y = hiltrans(x)
%
% The Hilbert Transform 
% imaginary part of the analytic signal
% Function added to increase legibility
%

y = imag( hilbert( x ) );
