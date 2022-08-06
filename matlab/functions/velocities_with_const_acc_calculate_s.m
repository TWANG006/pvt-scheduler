function [s, sa, sc] = velocities_with_const_acc_calculate_s(...
    v,   ... calculated velocities
    t,   ... dwell time
    amax ... accleration used
)
% @purpose
%   Calculate the displacements for the acceleration or decceleration
%   parts, i.e., sa, the constant-velocity parts, i.e., sc
% @returns
%   sa: displacements for the acc/dcc parts
%   sc: displacements for the constant-velocity parts
%    s: s = sa + sc, is the whole displacements

% determine acc or dcc
a = ones(size(t)) * amax;
a(v(2: end) - v(1: end - 1) < 0) = -amax;

% calculate t1 & s1
ta = (v(2: end) - v(1: end - 1)) ./ a;
sa = (v(2: end).^2 - v(1: end - 1).^2) ./ (2 * a);

% calculate t2 & s2
tc = t - ta;
sc = v(2: end) .* tc;

s = sa + sc;

end