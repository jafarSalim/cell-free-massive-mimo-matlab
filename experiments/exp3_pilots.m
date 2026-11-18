function out = exp3_pilots(S, nreal)
%EXP3_PILOTS  Pilot length tau_p: fewer pilots leave more time for data (pre-log 1 - tau_p/tau_c)
%   but force users to share pilots, and shared pilots contaminate the channel estimates.
if nargin < 1, S = 10; end
if nargin < 2, nreal = 30; end
p0 = cf_params();  c = palette();  rng(31);
taus = [5 10 20 40];
res = zeros(numel(taus), 4);          % mean CF, p5 CF, mean cellular, p5 cellular
for t = 1:numel(taus)
    p = p0;  p.tau_p = taus(t);
    se = [];
    for s = 1:S
        net = drop_network(p);
        pil = assign_pilots(net.beta_ap, p.tau_p, p.p, p.sigma2);
        a = uplink_se(net.beta_ap, p.N, true(p.L, p.K), pil, p, nreal, 'mmse');
        pil_c = assign_pilots(net.beta_bs, p.tau_p, p.p, p.sigma2);
        [~, bbs] = max(net.beta_bs, [], 1);
        oneb = false(p.Lcell, p.K);  oneb(sub2ind(size(oneb), bbs, 1:p.K)) = true;
        b = uplink_se(net.beta_bs, p.Ncell, oneb, pil_c, p, nreal, 'mmse');
        se = [se; a b]; %#ok<AGROW>
    end
    s1 = sort(se(:,1));  s2 = sort(se(:,2));
    res(t,:) = [mean(se(:,1)) s1(ceil(0.05*end)) mean(se(:,2)) s2(ceil(0.05*end))];
end
h = figure('visible', 'off', 'position', [0 0 1400 540]);
ttl = {'average user', '95%-likely user (5th percentile)'};
for s = 1:2
    subplot(1, 2, s);
    plot(taus, res(:, s), '-o', 'color', c.cf, 'linewidth', c.lw, 'markerfacecolor', c.cf, 'markersize', 9); hold on;
    plot(taus, res(:, s+2), '-s', 'color', c.cell, 'linewidth', c.lw, 'markerfacecolor', c.cell, 'markersize', 9);
    grid on; box on; set(gca, 'fontsize', 13, 'xtick', taus, 'linewidth', 1.1);
    xlabel('orthogonal pilots \tau_p  (40 users, \tau_c = 200)'); ylabel('SE [bit/s/Hz]');
    title(ttl{s});
    legend({'cell-free, centralized MMSE', 'cellular massive MIMO'}, 'location', 'southeast');
end
save_figure(h, 'fig5_pilot_length');
write_csv('exp3_pilots', 'tau_p,cf_mean,cf_p5,cell_mean,cell_p5', [taus' res]);
out.taus = taus;  out.res = res;
fprintf('exp3: %s\n', mat2str(res, 3));
end
