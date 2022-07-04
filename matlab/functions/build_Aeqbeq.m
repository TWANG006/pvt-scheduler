function [Aeq, beq] = build_Aeqbeq(...
    pvt_t ... the accumulated time for pvt
)
%
% Build the Aeq x = beq, equality constrained matrices, for the solver.
% This is used to guarantee the C1 smoothness of the feedrate profiles at 
% the inner feedrate control points, i.e., the control points excluding 
% the initial and final locations
%

n = length(pvt_t) - 1;
Aeq = zeros(n - 2, 6 * n);
beq = zeros(n - 2, 1);

for j = 2: n - 1
    i = j + 1;
    id = (j - 1) * 6;
    
    Aeq(j - 1, id - 5) = 6 * pvt_t(i - 1);
    Aeq(j - 1, id + 1) = -6 * pvt_t(i - 1);
    Aeq(j - 1, id - 4) = 2;
    Aeq(j - 1, id + 2) = 2;
end


end