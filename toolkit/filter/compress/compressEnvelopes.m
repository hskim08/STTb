function compEnvs = compressEnvelopes( envs, compressionOptions )
%
% compresses envelopes
%

if compressionOptions.type == 1, % power compression
    compEnvs = envs .^ compressionOptions.exponent;
elseif compressionOptions.type == 2, % log compression
    compEnvs = log10(envs + compressionOptions.logConstant);
else % no compression
    compEnvs = envs;
end