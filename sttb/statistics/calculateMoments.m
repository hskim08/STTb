function moments = calculateMoments( x )
% 
% Calculates the moments and returns them in a struct
% 

nFrames = size(x, 1);
moments.wi = 1/nFrames;

moments.m1 = moments.wi * sum(x);
moments.dx = x - moments.m1; % zero mean

moments.m2 = moments.wi * sum( moments.dx.^2 );
moments.sig = sqrt( moments.m2 );

moments.m3 = moments.wi * sum( moments.dx.^3 ); 
moments.m4 = moments.wi * sum( moments.dx.^4 ); 
