function [p, v, a] = calculate_const_acc_pva(...
    pt,   ... t02t1
    s, ... potision
    sa,   ... s1
    ta,   ... t1
    acc, ... acc
    v0, ... v_(k-1)
    vk ... v_k
)

dx = median(diff(pt(1, :)));
na = floor(ta / dx);
va = v0 + (1 : na) * dx * acc;
aa = acc * ones(1, na);
pa = (va.^2 - v0^2)/(2 * acc);

nc = size(pt, 2) -1 - na;
vc = vk * ones(1, nc);
ac = 0 * ones(1, nc);
delta_pc = 0 * ones(1, nc);
delta_pc(1) = ((na + 1) * dx - ta) * vc(1);
delta_pc(2: end) = vc(2: end) * dx;
pc = sa + cumsum(delta_pc);

p = [pa, pc] + s;
v = [va, vc];
a = [aa, ac];

end