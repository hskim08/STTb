function subbands = adjustSubbands( subbands, subbandVars )
%
% Imposes the subband variance to each subband
%

num_subbands = size(subbands, 2);

for k = 1:num_subbands,
    subbands(:,k) = subbands(:,k) * sqrt( subbandVars(k) / var(subbands(:,k)) ); 
end