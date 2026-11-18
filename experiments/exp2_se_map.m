function out = exp2_se_map(net, G, nreal)
%EXP2_SE_MAP  SE of one test user moved over the whole area, the other users fixed.
%   Shows where each architecture serves users well: cellular massive MIMO has peaks
%   around its four base stations and deep valleys between them; cell-free is flat.
%   The test user has no shadow fading, so the maps show geometry only.
if nargin < 2, G = 26; end
if nargin < 3, nreal = 12; end
p = cf_params();  c = palette();  rng(21);
g = linspace(10, p.side - 10, G);
[X, Y] = meshgrid(g, g);
map_cf = zeros(G);  map_cell = zeros(G);
others = net.ue(2:end, :);
for i = 1:G
    for j = 1:G
        u = [X(i,j) Y(i,j)];
        n2 = net;  n2.ue = [u; others];
        d_ap = sqrt(wrap_distance(net.ap, u, p.side).^2 + p.h_diff^2);
        d_bs = sqrt(wrap_distance(net.bs, u, p.side).^2 + p.h_diff^2);
        n2.beta_ap = [10.^(pathloss_db(d_ap, 0)/10) net.beta_ap(:, 2:end)];
        n2.beta_bs = [10.^(pathloss_db(d_bs, 0)/10) net.beta_bs(:, 2:end)];
        pil = assign_pilots(n2.beta_ap, p.tau_p, p.p, p.sigma2);
        s1 = uplink_se(n2.beta_ap, p.N, true(p.L, p.K), pil, p, nreal, 'mmse');
        pil_c = assign_pilots(n2.beta_bs, p.tau_p, p.p, p.sigma2);
        [~, bbs] = max(n2.beta_bs, [], 1);
        oneb = false(p.Lcell, p.K);  oneb(sub2ind(size(oneb), bbs, 1:p.K)) = true;
        s4 = uplink_se(n2.beta_bs, p.Ncell, oneb, pil_c, p, nreal, 'mmse');
        map_cf(i,j) = s1(1);  map_cell(i,j) = s4(1);
    end
end
zl = [0 max([map_cf(:); map_cell(:)])];
h = figure('visible', 'off', 'position', [0 0 1500 600]);
ttl = {'cell-free: 100 APs x 4 antennas', 'cellular: 4 BSs x 100 antennas'};
maps = {map_cf, map_cell};
for k = 1:2
    subplot(1, 2, k);
    surf(X, Y, maps{k}, 'edgecolor', 'none'); hold on;
    shading interp; colormap(gca, aurora(256)); caxis(zl); zlim(zl);
    if k == 1
        plot3(net.ap(:,1), net.ap(:,2), zl(2)*ones(p.L,1)*1.0, 'o', 'markersize', 4, 'markerfacecolor', [1 1 1], 'markeredgecolor', c.ink);
    else
        plot3(net.bs(:,1), net.bs(:,2), zl(2)*ones(p.Lcell,1), '^', 'markersize', 12, 'markerfacecolor', [1 1 1], 'markeredgecolor', c.ink, 'linewidth', 1.5);
    end
    view(-35, 42); grid on; box on; set(gca, 'fontsize', 12);
    xlabel('x [m]'); ylabel('y [m]'); zlabel('SE [bit/s/Hz]');
    title(sprintf('%s:  min %.2f, median %.2f', ttl{k}, min(maps{k}(:)), median(maps{k}(:))));
end
save_figure(h, 'fig4_se_landscape');
write_csv('exp2_map_cellfree', 'rows=y,cols=x', map_cf);
write_csv('exp2_map_cellular', 'rows=y,cols=x', map_cell);
out.X = X;  out.Y = Y;  out.cf = map_cf;  out.cell = map_cell;
out.min = [min(map_cf(:)) min(map_cell(:))];  out.median = [median(map_cf(:)) median(map_cell(:))];
fprintf('exp2: test-user SE min %.2f vs %.2f, median %.2f vs %.2f (cell-free vs cellular)\n', out.min, out.median);
end

function m = aurora(n)
k = [0.06 0.04 0.20; 0.29 0.09 0.55; 0.49 0.23 0.93; 0.93 0.28 0.60; 0.99 0.55 0.00; 0.99 0.90 0.35];
xi = linspace(0, 1, size(k,1));  t = linspace(0, 1, n);
m = [interp1(xi, k(:,1), t)' interp1(xi, k(:,2), t)' interp1(xi, k(:,3), t)'];
end
