function subbands = adjustSubbands( subbands, subbandVars )
%adjustSubbands    Imposes the subband variance to each subband.
%
% Parameters:
% subbands - A multiband signal.
% subbandVars - The variance (power) for each subband.
%
% Returns:
% subbands - The adjusted multiband signal.
%
%
% Imposes the subband variance to each subband
%

num_subbands = size(subbands, 2);

for k = 1:num_subbands,
    subbands(:,k) = subbands(:,k) * sqrt( subbandVars(k) / var(subbands(:,k)) ); 
end