function [C, d] = build_Cd(...
    p, ...
    t, ...
    a0, ...
    v0, ...
    at, ...
    vt ...
)
n = length(t) - 1;  % total v to be calculated

% 6n equations of unknowns + 4 equations of knowns for v0, l0 and vt, lt
C = zeros(6 * n + 4, 6 * n);
d = zeros(6 * n + 4, 1);

for j = 1: n
    i = j + 1;
    id = (j - 1) * 6;
    
    % build C
    C(id + 1, id + 1) = t(i - 1).^3;
    C(id + 1, id + 2) = t(i - 1).^2;
    C(id + 1, id + 3) = t(i - 1);
    C(id + 1, id + 4) = 1;
    
    C(id + 2, id + 1) = t(i).^3;
    C(id + 2, id + 2) = t(i).^2;
    C(id + 2, id + 3) = t(i);
    C(id + 2, id + 4) = 1;
    
    C(id + 3, id + 1) = 3 * t(i - 1).^2;
    C(id + 3, id + 2) = 2 * t(i - 1);
    C(id + 3, id + 3) = 1;
    
    C(id + 4, id + 1) = 3 * t(i).^2;
    C(id + 4, id + 2) = 2 * t(i);
    C(id + 4, id + 3) = 1;
    C(id + 4, id + 5) = -1;
    
    C(id + 5, id + 1) = 6 * t(i - 1);
    C(id + 5, id + 2) = 2;
    
    C(id + 6, id + 1) = 6 * t(i);
    C(id + 6, id + 2) = 2;
    C(id + 6, id + 6) = -1;
    
    
    if j > 1
        C(id + 3, id - 1) = -1;
        C(id + 5, id) = -1;
    end
    
    % build d
    d(id + 1) = p(i - 1);
    d(id + 2) = p(i);
end

% feed the initial and final conditions
d(end - 3: end) = [v0; a0; vt; at];
C(end - 3, 5) = 1;
C(end - 2, 6) = 1;
C(end - 1, end - 1) = 1;
C(end, end) = 1;

end