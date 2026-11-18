function out = exp1_cdf(S, nreal)
%EXP1_CDF  Distribution of the per-user uplink SE over many random network drops.
%   400 antennas in every case: 100 APs x 4 (cell-free, small cells) or 4 BSs x 100 (cellular).
if nargin < 1, S = 25; end
if nargin < 2, nreal = 50; end
p = cf_params();  c = palette();  rng(11);
all_se = zeros(p.K*S, 4);
for s = 1:S
    net = drop_network(p);
    all_se((s-1)*p.K + (1:p.K), :) = run_schemes(p, net, nreal);
    if s == 1, first = net; end
end
names = {'cell-free, centralized MMSE', 'cell-free, distributed MR', 'small cells (1 AP per user)', 'cellular massive MIMO, 4 x 100'};
cols = {c.cf, c.mr, c.small, c.cell};
h = figure('visible', 'off', 'position', [0 0 1000 640]);
for j = [4 3 2 1]
    x = sort(all_se(:, j));
    plot(x, (1:numel(x))/numel(x), '-', 'color', cols{j}, 'linewidth', c.lw); hold on;
end
plot([0 12], [0.05 0.05], ':', 'color', c.grey, 'linewidth', 1.5);
text(0.15, 0.085, '5% of users (cell edge)', 'color', c.ink, 'fontsize', 11);
grid on; box on; set(gca, 'fontsize', 13, 'linewidth', 1.1);
xlabel('uplink spectral efficiency per user [bit/s/Hz]'); ylabel('CDF');
title(sprintf('%d users, 400 antennas, %d random drops, %d fading realizations each', p.K, S, nreal));
legend(names([4 3 2 1]), 'location', 'southeast');
xlim([0 max(all_se(:))*1.02]);
save_figure(h, 'fig2_se_cdf');

mean_se = mean(all_se, 1);
p5 = zeros(1,4);
for j = 1:4, x = sort(all_se(:,j)); p5(j) = x(ceil(0.05*numel(x))); end
jain = sum(all_se,1).^2 ./ (size(all_se,1) * sum(all_se.^2,1));
h = figure('visible', 'off', 'position', [0 0 1000 560]);
b = bar([mean_se; p5]', 0.85);
set(b(1), 'facecolor', c.cf, 'edgecolor', 'none');  set(b(2), 'facecolor', c.small, 'edgecolor', 'none');
hold on;
for j = 1:4
    text(j - 0.2, mean_se(j) + 0.12, sprintf('%.2f', mean_se(j)), 'horizontalalignment', 'center', 'fontsize', 11);
    text(j + 0.2, p5(j) + 0.12, sprintf('%.2f', p5(j)), 'horizontalalignment', 'center', 'fontsize', 11);
    text(j, -0.55, sprintf('Jain %.2f', jain(j)), 'horizontalalignment', 'center', 'fontsize', 11, 'color', c.ink);
end
set(gca, 'xtick', 1:4, 'xticklabel', {'cell-free MMSE', 'cell-free MR', 'small cells', 'cellular mMIMO'}, 'fontsize', 12);
ylabel('bit/s/Hz'); grid on; box on;
legend({'average user', '95%-likely (5th percentile) user'}, 'location', 'northeast');
title('Average and cell-edge performance (Jain fairness index below each group)');
ylim([-0.9 max(mean_se)*1.25]);
save_figure(h, 'fig3_mean_vs_edge');

write_csv('exp1_se_samples', 'cf_mmse,cf_mr,small_cells,cellular', all_se);
write_csv('exp1_summary', 'scheme,mean,p5,jain', [(1:4)' mean_se' p5' jain']);
out.mean = mean_se;  out.p5 = p5;  out.jain = jain;  out.net = first;
fprintf('exp1: mean SE %s, 5%% SE %s, Jain %s\n', mat2str(mean_se, 3), mat2str(p5, 3), mat2str(jain, 3));
end
