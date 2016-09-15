function compEnvs = compressEnvelopes( envs, compressionOptions )
%compressEnvelopes    Compresses envelopes.
%
% Parameters:
% envs - Subband envelopes
% compressionOptions - Compression options
%
% Returns:
% compEnvs - The compresed envelopes.  
%

if compressionOptions.type == 1, % power compression
    compEnvs = envs .^ compressionOptions.exponent;
elseif compressionOptions.type == 2, % log compression
    compEnvs = log10(envs + compressionOptions.logConstant);
else % no compression
    compEnvs = envs;
end