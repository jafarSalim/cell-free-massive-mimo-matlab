function make_frames(map, net)
%MAKE_FRAMES  Frames of a user walking across the area, with its SE in both networks
%   read from the maps of exp2. Assembled into assets/walk.gif outside MATLAB.
p = cf_params();  c = palette();
here = fileparts(mfilename('fullpath'));
fdir = fullfile(here, '..', 'figures', 'frames');
if ~exist(fdir, 'dir'), mkdir(fdir); end
t = linspace(0, 1, 60);
path = [60 + 880*t; 500 + 380*sin(2*pi*t)]';
se_cf = interp2(map.X, map.Y, map.cf, path(:,1), path(:,2));
se_ce = interp2(map.X, map.Y, map.cell, path(:,1), path(:,2));
bg = [0.06 0.04 0.13];
for f = 1:numel(t)
    h = figure('visible', 'off', 'position', [0 0 980 460], 'color', bg, 'inverthardcopy', 'off');
    ax1 = axes('position', [0.04 0.1 0.42 0.82], 'color', bg, 'xcolor', [0.6 0.6 0.75], 'ycolor', [0.6 0.6 0.75]); hold on;
    plot(net.ap(:,1), net.ap(:,2), 's', 'markersize', 5, 'markerfacecolor', c.cf, 'markeredgecolor', 'none');
    plot(net.bs(:,1), net.bs(:,2), '^', 'markersize', 13, 'markerfacecolor', c.cell, 'markeredgecolor', 'w');
    plot(path(:,1), path(:,2), ':', 'color', [0.7 0.7 0.85], 'linewidth', 1.2);
    plot(path(f,1), path(f,2), 'o', 'markersize', 13, 'markerfacecolor', c.small, 'markeredgecolor', 'w', 'linewidth', 1.5);
    axis([0 p.side 0 p.side]); axis square; box on; set(ax1, 'fontsize', 10);
    title('user walking through the network', 'color', [0.92 0.9 1]);
    ax2 = axes('position', [0.55 0.14 0.41 0.74], 'color', bg, 'xcolor', [0.6 0.6 0.75], 'ycolor', [0.6 0.6 0.75]); hold on;
    plot(1:f, se_cf(1:f), '-', 'color', c.cf, 'linewidth', 3);
    plot(1:f, se_ce(1:f), '-', 'color', c.cell, 'linewidth', 3);
    plot(f, se_cf(f), 'o', 'markersize', 9, 'markerfacecolor', c.cf, 'markeredgecolor', 'w');
    plot(f, se_ce(f), 'o', 'markersize', 9, 'markerfacecolor', c.cell, 'markeredgecolor', 'w');
    xlim([1 numel(t)]); ylim([0 max([se_cf; se_ce])*1.1]); grid on; box on; set(ax2, 'fontsize', 11, 'gridcolor', [0.5 0.5 0.6]);
    xlabel('time step'); ylabel('SE [bit/s/Hz]');
    title(sprintf('cell-free %.1f   |   cellular %.1f  bit/s/Hz', se_cf(f), se_ce(f)), 'color', [0.92 0.9 1]);
    legend({'cell-free', 'cellular'}, 'textcolor', [0.92 0.9 1], 'color', 'none', 'location', 'southwest');
    set(h, 'PaperPositionMode', 'auto');
    print(h, fullfile(fdir, sprintf('f%03d.png', f)), '-dpng', '-r100');
    close(h);
end
end
