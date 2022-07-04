function [p, v, t, c, a] = pvt_scheduler_raster_path(...
    x, ... x coordinates (this is the main axis)
    dt, ...dwell time 
    dist_ex, ... extra move in both end [m]
    t_ex, ... extra time for the extra move [s]
    a_max, ... max acceleration [m/s^2]
    v_max, ... max feed rate [m/s]
    is_c1_smooth, ... if constrain the feedrate to be c1 smooth
    is_back_forth ... if the feed is back & forth or single direction
)
%-------------------------------------------------------------------------%
% Purpose:
%     Scheduling the CNC parameters for the PVT controll mode, with the 
%     motion profile in x direction like
%         x......o..*..o..*..o......x
%     where x-o is the extra move, o is the feedrate control points, and * 
%     is the dwell point. 
%
% Outputs:
%     p: position [m]
%     v: velocity [m/s]
%     t: time [s]
%     c: coefficients of each piecewise cubic polynomials
%     a: accelerations [m/s^2]
%
% Information:
%     Author: Tianyi Wang (tianyiwang666@gmail.com)
%-------------------------------------------------------------------------%

n_scans = length(dt);  % number of scans in y direction
p = cell(n_scans, 1);
v = cell(n_scans, 1);
t = cell(n_scans, 1);
c = cell(n_scans, 1);
a = cell(n_scans, 1);


% Process scans one by one
for m = 1: n_scans    
    % 1. Extract the p and t for the pvt
    if is_back_forth == true && mod(m, 2) == 0
        t_line = flip(dt{m});
        x_line = flip(x{m});
    else
        t_line = dt{m};
        x_line = x{m};
    end
    % flatten the vectors
    x_line = x_line(:);
    t_line = t_line(:);
    
    % initial and final conditions feedrate
    v0 = (x_line(2) - x_line(1)) / t_line(1);  
    vt = (x_line(end) - x_line(end - 1)) / t_line(end);
    a0 = 0;  % initial acc.
    at = 0;

    
    % 2. Build C and d
    [C, d, cum_t, ~, direction] = build_Cd(x_line, t_line, dist_ex, t_ex, a0, v0, at, vt);
    
    % 3. Build Aeq and beq
    if is_c1_smooth == true
        [Aeq, beq] = build_Aeqbeq(cum_t);
    end
    
    % 4. Build lb and ub
    [lb, ub] = build_lbub(length(cum_t) - 1, direction, v_max, a_max);
    
    % 5. Solve for the v for pvt
    options =  optimoptions('lsqlin', 'Display', 'off');
    
    if is_c1_smooth == true
        res = lsqlin(C, d, [], [], Aeq, beq, lb, ub, [], options);
    else
        res = lsqlin(C, d, [], [], [], [], lb, ub, [], options);
    end
    
    % 6. Solve again with updated v0 and a0
    temp_v = res(5: 6: end);
    v0 = temp_v(2);  % initial feedrate
    vt = temp_v(end - 1);
    
    [C, d, ~, pvt_p, ~] = build_Cd(x_line, t_line, dist_ex, t_ex, a0, v0, at, vt);
    
    if is_c1_smooth == true
        res = lsqlin(C, d, [], [], Aeq, beq, lb, ub, [], options);
    else
        res = lsqlin(C, d, [], [], [], [], lb, ub, [], options);
    end
    
    % 7. Assemble the outputs
    c{m, 1} = [...
        res(1: 6: end)'; ...
        res(2: 6: end)'; ...
        res(3: 6: end)'; ...
        res(4: 6: end)' ...
    ]';
    c{m, 1} = c{m, 1}(1: end - 1, :);  % exclude the final coefficients   
        
    v{m, 1} = res(5: 6: end);
    v{m, 1} = v{m, 1}(1: end - 1);  % exclude the final feedrate
    
    a{m, 1} = res(6: 6: end);  
    a{m, 1} = a{m, 1}(1: end - 1);  % exclude the final acceleration
    
    p{m, 1} = pvt_p(2: end - 1);   % exclude the initial and final p
    t{m, 1} = cum_t(2: end - 1);
    
    % 8. Recalculate pvt coefficients
    n_positions = length(p{m, 1});
    cn = zeros((n_positions - 1), 4);
    
    for n = 1: n_positions - 1
        cn(n, :) = pvt_coefficients(...
            p{m, 1}(n), p{m, 1}(n + 1),...
            v{m, 1}(n), v{m, 1}(n + 1),...
            t{m, 1}(n), t{m, 1}(n + 1)...
        );          
    end
    c{m, 1} = cn;          
end

end


%     figure;
%     subplot(323);
%     plot(pvt_p*1e3, zeros(size(pvt_p)), 'b-o'); 
%     hold on;
%     plot(x{i}*1e3, zeros(size(x{i})), 'r*'); 
%     hold off;
%     title('Feedrate points vs. dwell pionts');
%     xlabel('[mm]')
%     legend('Feedrate points', 'Dwell points');
% 
%     subplot(325);
%     plot(pvt_p*1e3, cum_t, 's-');
%     title('Cumulated dwell time')
%     xlabel('[mm]');
%     ylabel('[s]');
%     
%     subplot(322);
%     yyaxis left;
%     plot(x_line*1e3, t_line, '-*');
%     ylabel('[s]');
% 
%     yyaxis right;
%     plot(p{i}*1e3, abs(v{i})*1e3, '-*');
%     title('Dwell time vs. Feedrates');
%     xlabel('[mm]');
%     ylabel('[mm/s]');
% 
%     subplot(324);
%     plot(x{i}*1e3, diff( p{i, 1})./v{i, 1}(1: end - 1), 's-');
%     title('Converted dwell time');
%     xlabel('[mm]');
%     ylabel('[mm/s]');
% 
%     subplot(326);
%     plot(p{i}*1e3, a{i}*1e3, 'r-*');
%     title('Optimized acceleration');
%     xlabel('[mm]');
%     ylabel('[mm/s^2]');
