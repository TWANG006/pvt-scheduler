function [lb, ub] = build_lbub(...
    n, ...
    v_max, ... maximum feedrate
    a_max ... maximum acceleration
)
%
% Build the lb and ub constrains for the feedrate and acceleration, 
% where 0 <= v <= v_max and -a_max <= a <= a_max
%
% build the lb
lb = NaN(6 * n, 1);
lb(5: 6: end) = -v_max;
lb(6: 6: end) = -a_max;
lb(isnan(lb)) = -Inf;


% build the ub
ub = NaN(6 * n, 1);
ub(5: 6: end) = v_max;
ub(6: 6: end) = a_max;
ub(isnan(ub)) = Inf;

end