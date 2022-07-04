function [p_s, v_s, a_s] = pvt_sampler_raster_path(...
    tau, ... the time interval for the sampling of caculated PVT
    p, ... positions
    t, ... times
    c  ... coefficients
)
% 
% Upsample the PVT for the simulation
%

n_scans = length(p);
p_s = cell(n_scans, 1);
v_s = cell(n_scans, 1);
a_s = cell(n_scans, 1);

% figure;
for m = 1: n_scans
    n_positions = length(p{m, 1});
    
    a_s{m, 1} = [];
    p_s{m, 1} = [];
    v_s{m, 1} = [];
    
    for n = 1: n_positions - 1
        % 1. generate t's for each segment
        if n == 1
            t0 = t{m, 1}(n);
        else
            t0 = t{m, 1}(n) + tau;
        end
        t1 = t{m, 1}(n + 1);        
        t02t1 = linspace(t0, t1, ceil((t1 - t0) / tau));
        
%         plot(t02t1, calculate_pvt_p(t02t1, c{m, 1}(n, :)));
%         plot(t02t1, calculate_pvt_v(t02t1, c{m, 1}(n, :)));

        % 2. calculate p's and v's for each segment
        p_s{m, 1} = [p_s{m, 1}; calculate_pvt_p(t02t1, c{m, 1}(n, :))];
        v_s{m, 1} = [v_s{m, 1}; calculate_pvt_v(t02t1, c{m, 1}(n, :))];
        a_s{m, 1} = [a_s{m, 1}; calculate_pvt_a(t02t1, c{m, 1}(n, :))];
    end
end



end