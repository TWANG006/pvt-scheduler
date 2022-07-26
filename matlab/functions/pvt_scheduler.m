function [v, a, c] = pvt_scheduler(...
    p, ...
    t, ...
    a_max, ...
    v_max, ...
    is_c1_smooth ...
    )

v0 = 0;  a0 = 0;
vt = 0;  at = 0;

n_positions = length(t) - 1;

[C, d] = build_Cd(p, t, a0, v0, at, vt);
[lb, ub] = build_lbub(length(t) - 1, v_max, a_max);
if is_c1_smooth == true
    [Aeq, beq] = build_Aeqbeq(t);
end


options =  optimoptions('lsqlin', 'Display', 'off');
if is_c1_smooth == true
    res = lsqlin(C, d, [], [], Aeq, beq, lb, ub, [], options);
else
    res = lsqlin(C, d, [], [], [], [], lb, ub, [], options);
end


v = res(5: 6: end);
a = res(6: 6: end);

v0 = v(1); a0 = a(1);
vt = v(end);  at = a(end);

[C, d] = build_Cd(p, t, a0, v0, at, vt);
if is_c1_smooth == true
    res = lsqlin(C, d, [], [], Aeq, beq, lb, ub, [], options);
else
    res = lsqlin(C, d, [], [], [], [], lb, ub, [], options);
end


v = [v0; res(5: 6: end)];
a = [a0; res(6: 6: end)];
c = zeros(n_positions, 4);

for n = 1: n_positions
    c(n, :) = pvt_coefficients(...
        p(n), p(n + 1), ...
        v(n), v(n + 1), ...
        t(n), t(n + 1) ...
    );    
end

% res_0 = res * 0;
% 
% for n = 1: n_positions
%     %     c(n, :) = res((1: 4) + (n - 1) * 6);
%     c(n, :) = pvt_coefficients(...
%         p(n), p(n + 1), ...
%         v(n), v(n + 1), ...
%         t(n), t(n + 1) ...
%     );
%     
%     res_0((n - 1)*6 + 1: (n - 1)*6 + 6) = [c(n, :)'; v(n); a(n);];
% end
% 
% % solve again using res_0
% % if is_c1_smooth == true
% %     res = lsqlin(C, d, [], [], Aeq, beq, lb, ub, res_0, options);
% % else
%     res = lsqlin(C, d, [], [], [], [], lb, ub, res_0, options);
% % end
% 
% for n = 1: n_positions
%     c(n, :) = res((1: 4) + (n - 1) * 6);
% end

end


