function s = velocities_with_const_acc_calculate_s(...
    v,   ... calculated velocities
    t,   ... dwell time
    amax ... accleration used
)

% calculate t1 & s1
t1 = (v(2: end) - v(1: end - 1)) / amax;
s1 = (v(2: end).^2 - v(1: end - 1).^2) / (2 * amax);

% calculate t2 & s2
t2 = t - t1;
s2 = v(2: end) .* t2;

s = s1 + s2;

end