function [ps, vs, ts, as] = velocities_with_const_acc_sampler(...
    p, ... positions on the tool path
    v, ... calculated velocities
    t, ... time points
    a, ... constant acceleration
    tau ...time interval for the sampling
)
% @purpose
%   Sample the calculate velocities to a denser grid to prepare for the
%   velocity-based simulation.
% @returns
%   ps: sampled potision
%   vs: sampled velocities
%   ts: sampled t
%   as: sampled as, which will be either a or 0

%% 1. calculate ta points
p = p(:);
v = v(:);
t = t(:);
a = a(:);

ta = abs((v(2: end) - v(1: end - 1)) / a) + t(1: end - 1);
an = ones(length(t) - 1, 1) * a;
an(v(2: end) - v(1: end - 1) < 0) = -a;


%% 2. Sampling
ps = [];
vs = [];
ts = [];
as = [];

for n = 1: length(p) - 1
    % generate t's for each segment
    if n == 1
        t0 = t(n);
    else
        t0 = t(n) + tau;
    end
    t1 = t(n + 1);
    t02t1 = linspace(t0, t1, ceil((t1 - t0) / tau))';
    ts = [ts; t02t1(:)];
    
    % first id where t02t1(id) > ta(n)
    i = find(t02t1 >= ta(n), 1);    
    if isempty(i)
        if abs(v(n + 1) - v(n)) > 1e-15 % vk3, only acc/dcc part
            v02v1 = v(n) + an(n) * (t02t1 - t(n));
            p02p1 = p(n) + 0.5 * (v02v1 + v(n)) .* (t02t1 - t(n));
            a02a1 = an(n);            
        else % const velocity
            v02v1 = v(n + 1) * ones(size(t02t1));
            p02p1 = p(n) + v02v1 .* (t02t1 - t(n));
            a02a1 = 0;
        end
    else
        % divide t02t1 at i
        t02ti = t02t1(1: i - 1);  % acc/dcc part
        ti2t1 = t02t1(i: end  );  % const a part
        
        % handle the case where tau overlapped with both parts
        t2 = t02t1(i) - ta(n);     % const a initial time
        
        % calculation
        v02vi = v(n) + an(n) * (t02ti(:) - t(n));
        p02pi = p(n) + 0.5 * (v02vi + v(n)) .* (t02ti - t(n));
        a02ai = an(n);
        sa = (v(n + 1).^2 - v(n).^2) / (2 * an(n));
        
        vi = v(n + 1);
        pi = p(n) + sa + t2 * vi;
        ai = 0;
        
        vi2v1 = v(n + 1) * ones(length(ti2t1), 1);
        pi2p1 = p(n) + sa + vi2v1 .* (ti2t1 - ta(n));
        ai2a1 = 0;
        
        v02v1 = [v02vi(:); vi; vi2v1(:)];
        p02p1 = [p02pi(:); pi; pi2p1(:)];
        a02a1 = [a02ai(:); ai; ai2a1(:)];       
    end
    
    ps = [ps; p02p1(:)];
    vs = [vs; v02v1(:)];
    as = [as; a02a1(:)];
    
%     % calculation for the acc/dcc segment
%     if ~isempty(t02ti)
%         v02vi = v(n) + an(n) * (t02ti - t(n));
%         p02pi = p(n) + 0.5 * (v02vi + v(n)) .* (t02ti - t(n));
%         a02ai = an(n);
%         sa = (v(n + 1).^2 - v(n).^2) / (2 * a);
%         
%         ps = [ps; p02pi(:)];
%         vs = [vs; v02vi(:)];
%         as = [as; a02ai(:)];
%         ts = [ts; t02ti(:)];
%     else
%         sa = 0;
%     end
%     
%     
%     % calculation for the const v segment
%     if ~isempty(ti2t1)
%         v02v1 = v(n + 1) * ones(size(ti2t1));
%         p02p1 = p(n) + sa + v02v1.*(ti2t1 - ta(n));
%         a02a1 = 0;
%         
%         ps = [ps; p02p1(:)];
%         vs = [vs; v02v1(:)];
%         as = [as; a02a1(:)];
%         ts = [ts; ti2t1(:)];
%     end
end

end