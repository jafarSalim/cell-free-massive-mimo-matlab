function d = wrap_distance(A, U, side)
%WRAP_DISTANCE  Horizontal distances between points A (n-by-2) and U (m-by-2) on a torus.
%   Wrap-around makes every user see the same kind of neighbourhood: no cell-edge artefacts.
d = inf(size(A,1), size(U,1));
for sx = [-side 0 side]
    for sy = [-side 0 side]
        dx = A(:,1) - (U(:,1)' + sx);
        dy = A(:,2) - (U(:,2)' + sy);
        d = min(d, sqrt(dx.^2 + dy.^2));
    end
end
end
