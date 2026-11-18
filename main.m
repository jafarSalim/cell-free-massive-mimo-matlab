%MAIN  Cell-free massive MIMO against small cells and cellular massive MIMO.
%   Works in MATLAB (R2016b or newer, no toolboxes) and GNU Octave (6 or newer).
%   Takes a few minutes; the SE landscape (exp2) is the slowest part.
clear; close all;
here = fileparts(mfilename('fullpath'));
if isempty(here), here = pwd; end
addpath(fullfile(here, 'src'), fullfile(here, 'experiments'));
t0 = tic;
r1 = exp1_cdf(25, 50);
plot_layout(r1.net);
r2 = exp2_se_map(r1.net, 26, 12);
r3 = exp3_pilots(10, 30);
make_frames(r2, r1.net);
names = {'cell-free centralized MMSE', 'cell-free distributed MR', 'small cells', 'cellular massive MIMO'};
fid = fopen(fullfile(here, 'results', 'summary.txt'), 'w');
for j = 1:4
    fprintf(fid, '%-28s mean %.2f  5th percentile %.2f  Jain %.2f bit/s/Hz\n', names{j}, r1.mean(j), r1.p5(j), r1.jain(j));
end
fprintf(fid, 'Test-user landscape: min %.2f vs %.2f, median %.2f vs %.2f (cell-free vs cellular)\n', r2.min, r2.median);
for t = 1:numel(r3.taus)
    fprintf(fid, 'tau_p = %2d: cell-free mean %.2f / 5%% %.2f, cellular mean %.2f / 5%% %.2f\n', r3.taus(t), r3.res(t,:));
end
fprintf(fid, 'Run time: %.0f s\n', toc(t0));
fclose(fid);
type(fullfile(here, 'results', 'summary.txt'));
