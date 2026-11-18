function se = run_schemes(p, net, nreal)
%RUN_SCHEMES  SE of every user under the four architectures for one network drop.
%   Columns: 1 cell-free centralized MMSE, 2 cell-free distributed MR,
%            3 small cells (best AP, local MMSE), 4 cellular massive MIMO (best BS, MMSE).
K = size(net.ue, 1);
se = zeros(K, 4);
pil = assign_pilots(net.beta_ap, p.tau_p, p.p, p.sigma2);
all_serve = true(p.L, K);
se(:,1) = uplink_se(net.beta_ap, p.N, all_serve, pil, p, nreal, 'mmse');
se(:,2) = uplink_se(net.beta_ap, p.N, all_serve, pil, p, nreal, 'mr');
[~, best] = max(net.beta_ap, [], 1);
one = false(p.L, K);  one(sub2ind(size(one), best, 1:K)) = true;
se(:,3) = uplink_se(net.beta_ap, p.N, one, pil, p, nreal, 'mmse');
pil_c = assign_pilots(net.beta_bs, p.tau_p, p.p, p.sigma2);
[~, bbs] = max(net.beta_bs, [], 1);
oneb = false(p.Lcell, K);  oneb(sub2ind(size(oneb), bbs, 1:K)) = true;
se(:,4) = uplink_se(net.beta_bs, p.Ncell, oneb, pil_c, p, nreal, 'mmse');
end
