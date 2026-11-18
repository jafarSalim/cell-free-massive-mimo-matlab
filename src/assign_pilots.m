function pilot = assign_pilots(beta, tau_p, p, sigma2)
%ASSIGN_PILOTS  Greedy pilot assignment (Bjornson & Sanguinetti 2020, Section V-A).
%   The first tau_p users get one pilot each. Every later user picks the pilot that
%   causes the least contamination at its strongest ("master") AP.
%   beta: L-by-K large-scale gains (linear).
K = size(beta, 2);
pilot = zeros(K, 1);
pilot(1:min(tau_p, K)) = 1:min(tau_p, K);
for k = tau_p+1:K
    [~, master] = max(beta(:, k));
    load = zeros(tau_p, 1);
    for t = 1:tau_p
        load(t) = sum(beta(master, pilot(1:k-1) == t));
    end
    [~, pilot(k)] = min(load);
end
end
