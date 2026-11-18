function net = drop_network(p, ue_xy)
%DROP_NETWORK  Random AP positions, a fixed 2x2 grid of cellular BSs, and users.
%   Returns positions and large-scale gains (linear) for both architectures.
%   ue_xy (optional): K-by-2 user positions; random if omitted.
if nargin < 2 || isempty(ue_xy)
    ue_xy = p.side * rand(p.K, 2);
end
net.ap  = p.side * rand(p.L, 2);
g = p.side/4 + (0:1)*p.side/2;
[bx, by] = meshgrid(g, g);
net.bs  = [bx(:) by(:)];
net.ue  = ue_xy;
K = size(ue_xy, 1);
d_ap = sqrt(wrap_distance(net.ap, ue_xy, p.side).^2 + p.h_diff^2);
d_bs = sqrt(wrap_distance(net.bs, ue_xy, p.side).^2 + p.h_diff^2);
net.beta_ap = 10.^(pathloss_db(d_ap, p.sf_dB*randn(p.L, K))/10);
net.beta_bs = 10.^(pathloss_db(d_bs, p.sf_dB*randn(p.Lcell, K))/10);
end
