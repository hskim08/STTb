function idx_bundle = getSigSubs( target_stats, offsets, snr_params )
%
% Returns a struct containing indices of channels to include
%

% compute error including only subbands with significant power
sub_power = 10*log10( max(target_stats.subband_var) ./ target_stats.subband_var );
% sub_power = 10*log10( max(target_stats.dc_env_mean) ./ target_stats.dc_env_mean );
sig_subs = find(sub_power < snr_params.sig_sub_cutoff_db);

nChannels = length(sub_power);

% mark channels to include
% env_C_to_include = zeros(nChannels, nChannels);
% env_C_to_include_full = zeros(nChannels, nChannels);
mod_C1_to_include = zeros(nChannels, nChannels);
mod_C1_to_include_full = zeros(nChannels, nChannels);
for iChannel = 1:nChannels,
    if ismember(iChannel, sig_subs)

%         tmp = iChannel + offsets.C;
%         env_C_to_include(iChannel, tmp( (tmp > 0) & (tmp <= nChannels) ) ) = 1;
%         env_C_to_include_full(iChannel, (iChannel+1):end) = 1;

        tmp = iChannel + offsets;
        mod_C1_to_include(iChannel, tmp( (tmp > 0) & (tmp <= nChannels) ) ) = 1;
        mod_C1_to_include_full(iChannel, (iChannel+1):end) = 1;
    end
end

% pack results
idx_bundle.sig_subs = sig_subs;
% idx_bundle.env_C_idx = find(env_C_to_include == 1);
% idx_bundle.env_C_full_idx = find(env_C_to_include_full == 1);
idx_bundle.mod_C1_idx = find(mod_C1_to_include == 1);
idx_bundle.mod_C1_full_idx = find(mod_C1_to_include_full == 1);
