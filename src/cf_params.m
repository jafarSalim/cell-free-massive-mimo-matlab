function p = cf_params()
%CF_PARAMS  Network and propagation parameters (uplink, sub-6 GHz, urban micro).
%   The layout follows the comparison in Bjornson & Sanguinetti, "Making Cell-Free
%   Massive MIMO Competitive With MMSE Processing and Centralized Implementation",
%   IEEE Trans. Wireless Commun., 2020, simplified to uncorrelated Rayleigh fading.
p.side     = 1000;      % square area [m], with wrap-around (no edge effects)
p.L        = 100;       % cell-free access points (APs)
p.N        = 4;         % antennas per AP  -> 400 antennas in total
p.Lcell    = 4;         % cellular massive MIMO base stations
p.Ncell    = 100;       % antennas per base station -> also 400 in total
p.K        = 40;        % users
p.tau_c    = 200;       % samples per coherence block
p.tau_p    = 10;        % orthogonal pilots (so pilots are reused 4 times)
p.p        = 100e-3;    % user transmit power [W]
p.B        = 20e6;      % bandwidth [Hz]
p.NF_dB    = 7;
p.sigma2   = 10^((-174 + 10*log10(p.B) + p.NF_dB)/10) / 1000;   % noise power [W], -94 dBm
p.h_diff   = 10;        % AP height above the users [m]
p.sf_dB    = 4;         % shadow fading standard deviation [dB]
end
