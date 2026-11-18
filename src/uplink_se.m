function se = uplink_se(beta, Nant, serve, pilot, p, nreal, scheme)
%UPLINK_SE  Uplink spectral efficiency of every user, by Monte Carlo over small-scale fading.
%
%   beta:  L-by-K large-scale gains (linear), one row per AP or BS
%   Nant:  antennas per AP/BS
%   serve: L-by-K logical, serve(l,k) = AP l decodes user k
%   pilot: K-by-1 pilot index (pilots are reused when K > tau_p)
%   scheme:
%     'mmse' - MMSE combining over all antennas serving the user, using the channel
%              estimates of every user at those antennas (centralized cell-free when
%              serve is all-true; small cells / cellular when each user has one AP/BS)
%     'mr'   - local maximum-ratio combining at each AP, summed at the CPU, evaluated
%              with the use-and-then-forget bound (the original cell-free scheme)
%
%   Channels: h_kl ~ CN(0, beta_kl I), MMSE estimates from tau_p orthogonal pilots.
[L, K] = size(beta);
pre = 1 - p.tau_p / p.tau_c;
tp = p.tau_p;
% estimate statistics per AP and user (uncorrelated fading -> scalars per AP)
psi = zeros(L, K);             % 1 / (sum over co-pilot users of p tau_p beta + sigma2)
for k = 1:K
    same = pilot == pilot(k);
    psi(:, k) = 1 ./ (p.p*tp*sum(beta(:, same), 2) + p.sigma2);
end
gam = p.p*tp*beta.^2 .* psi;   % variance of the estimate  E|hhat|^2 per antenna
err = beta - gam;              % variance of the estimation error
idx = @(l) (l-1)*Nant + (1:Nant);

if strcmp(scheme, 'mr')
    % use-and-then-forget bound, Monte Carlo expectations
    num = zeros(K,1);  den_i = zeros(K,K);  nrm = zeros(K,1);
    for r = 1:nreal
        [H, Hh] = draw(beta, gam, psi, pilot, p, L, K, Nant);
        for k = 1:K
            v = Hh(:, k) .* kron(serve(:,k), ones(Nant,1));
            num(k) = num(k) + (v' * H(:,k)) / nreal;
            den_i(k,:) = den_i(k,:) + abs(v' * H).^2 / nreal;
            nrm(k) = nrm(k) + norm(v)^2 / nreal;
        end
    end
    sinr = p.p*abs(num).^2 ./ (p.p*sum(den_i, 2) - p.p*abs(num).^2 + p.sigma2*nrm);
    se = pre * log2(1 + real(sinr));
    return;
end

se = zeros(K, 1);
groups = unique(serve', 'rows');            % users with the same serving set share one inverse
for r = 1:nreal
    [~, Hh] = draw(beta, gam, psi, pilot, p, L, K, Nant);
    for gI = 1:size(groups, 1)
        set_l = find(groups(gI, :));
        users = find(ismember(serve', groups(gI,:), 'rows'));
        rows = cell2mat(arrayfun(idx, set_l, 'UniformOutput', false));
        Hs = Hh(rows, :);
        Cs = sum(p.p * kron(err(set_l, :), ones(Nant, 1)), 2);      % diagonal error covariance
        A = p.p * (Hs * Hs') + diag(Cs + p.sigma2);
        V = A \ Hs(:, users);                                       % MMSE combiners (up to a scalar)
        for j = 1:numel(users)
            k = users(j);  v = V(:, j);
            sig = p.p * abs(v' * Hs(:, k))^2;
            intf = p.p * sum(abs(v' * Hs).^2) - sig + v' * (Cs .* v) + p.sigma2 * (v' * v);
            se(k) = se(k) + pre * log2(1 + sig / real(intf)) / nreal;
        end
    end
end
end

function [H, Hh] = draw(beta, gam, psi, pilot, p, L, K, Nant)
% true channels H and their MMSE estimates Hh, stacked over all APs (L*Nant rows)
M = L * Nant;
W = (randn(M, K) + 1j*randn(M, K)) / sqrt(2);
H = kron(sqrt(beta), ones(Nant, 1)) .* W;
Hh = zeros(M, K);
noise = sqrt(p.sigma2/2) * (randn(M, p.tau_p) + 1j*randn(M, p.tau_p));
for t = 1:p.tau_p
    same = find(pilot == t);
    if isempty(same), continue; end
    Yp = sqrt(p.p*p.tau_p) * sum(H(:, same), 2) + noise(:, t);   % received pilot after despreading
    for k = same(:)'
        w = kron(sqrt(p.p*p.tau_p) * beta(:, k) .* psi(:, k), ones(Nant, 1));
        Hh(:, k) = w .* Yp;
    end
end
end
