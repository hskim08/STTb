function grad = calculateModC1Grads( bs, br, hbs, hbr, current_cbc )
% 
% Calculates the between subband modulation gradient for the given subbands.
%
% From McDermott et al.
%

nFrames = length(bs);
wi = 1/nFrames;

sigx = sqrt( wi * sum( bs.^2 ) ); % assumes filters are bandpass, so zero-mean
sigy = sqrt( wi * sum( br.^2 ) ); % assumes filters are bandpass, so zero-mean

grad = wi/sigx * ( hbr/sigy - hbs/sigx * current_cbc );
