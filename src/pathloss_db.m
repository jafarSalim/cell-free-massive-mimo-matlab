function g = pathloss_db(d3, sf)
%PATHLOSS_DB  3GPP urban-microcell channel gain [dB] at 3D distance d3 [m], plus shadowing sf [dB].
%   g = -30.5 - 36.7 log10(d3) + sf   (3GPP TR 38.901 UMi, used in Bjornson & Sanguinetti 2020)
g = -30.5 - 36.7*log10(d3) + sf;
end
