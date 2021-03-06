function decompEnvs = decompressEnvelopes( envs, compressionOptions )
%decompressEnvelopes    Decompresses envelopes.
%
% Parameters:
% envs - Compressed subband envelopes
% compressionOptions - Compression options
%
% Returns:
% compEnvs - The decompresed subband envelopes.  
%

if compressionOptions.type == 1, % power compression
    envs(envs < 0) = 0; % must be positive
    decompEnvs = envs .^ (1/compressionOptions.exponent);
elseif compressionOptions.type == 2, % log compression
    decompEnvs = 10.^envs - compression_options.log_constant;
end