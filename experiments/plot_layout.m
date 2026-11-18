function plot_layout(net)
%PLOT_LAYOUT  The two deployments with the same 400 antennas and 40 users.
p = cf_params();  c = palette();
h = figure('visible', 'off', 'position', [0 0 1400 640]);
for k = 1:2
    subplot(1, 2, k); hold on;
    if k == 1
        [~, best] = max(net.beta_ap, [], 1);
        for u = 1:p.K
            [~, srt] = sort(net.beta_ap(:,u), 'descend');
            for a = srt(1:4)'
                v = wrapvec(net.ap(a,:) - net.ue(u,:), p.side);
                plot(net.ue(u,1) + [0 v(1)], net.ue(u,2) + [0 v(2)], '-', 'color', 0.3*c.cf + 0.7*[1 1 1], 'linewidth', 1);
            end
        end
        plot(net.ap(:,1), net.ap(:,2), 's', 'markersize', 7, 'markerfacecolor', c.cf, 'markeredgecolor', 'none');
        title('cell-free: 100 APs x 4 antennas (lines: 4 strongest APs per user)');
    else
        [~, bbs] = max(net.beta_bs, [], 1);
        for u = 1:p.K
            v = wrapvec(net.bs(bbs(u), :) - net.ue(u,:), p.side);
            plot(net.ue(u,1) + [0 v(1)], net.ue(u,2) + [0 v(2)], '-', 'color', 0.4*c.cell + 0.6*[1 1 1], 'linewidth', 1);
        end
        plot(net.bs(:,1), net.bs(:,2), '^', 'markersize', 16, 'markerfacecolor', c.cell, 'markeredgecolor', c.ink, 'linewidth', 1.2);
        title('cellular massive MIMO: 4 BSs x 100 antennas (lines: serving BS)');
    end
    plot(net.ue(:,1), net.ue(:,2), 'o', 'markersize', 7, 'markerfacecolor', c.small, 'markeredgecolor', c.ink);
    axis([0 p.side 0 p.side]); axis square; box on; grid on; set(gca, 'fontsize', 12, 'clipping', 'on');
    xlabel('x [m]'); ylabel('y [m]');
end
save_figure(h, 'fig1_layouts');
end
function v = wrapvec(v, side)
% shortest displacement on the wrap-around area (lines may leave the square and re-enter)
v = mod(v + side/2, side) - side/2;
end
