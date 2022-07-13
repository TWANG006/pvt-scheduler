clear;
close all;
clc;
addpath(genpath('../functions'));

%% generate a very simple 5-point 2d path
data_dir = '../../data/sim_data/';
data_file = 'step_01_dt_lsmr.mat';
load([data_dir data_file]);
% load([data_dir data_file], 'xp', 'yp', 't', 'Xca', 'Yca', 'Z_to_remove_ca','Xtif', 'Ytif', 'Ztif');

px = xp;
py = yp;
t = cumsum(t);

% px = [1e-3, 2e-3, 3.5e-3, 5e-3, 1e-3];
% py = [1e-3, 2e-3, 2.5e-3, 1.8e-3, 1e-3];
% t = [0, 0.1, 0.12, 0.23, 0.3] * 10;


%% parameters
ax_max = 2;
vx_max = 250e-3;

ay_max = 1;
vy_max = 150e-3;

tau = 1/120;


%% calculate pvt for x and y seperately
[vx, ax, cx] = pvt_scheduler(px, t, ax_max, vx_max, true);
[vy, ay, cy] = pvt_scheduler(py, t, ay_max, vy_max, true);


%% simulation
px_s = [];
ax_s = [];
vx_s = [];

py_s = [];
ay_s = [];
vy_s = [];

for n = 1: length(t) - 1
    % 1. generate t's for each segment
    if n == 1
        t0 = t(n);
    else
        t0 = t(n) + tau;
    end
    t1 = t(n + 1);
    t02t1 = linspace(t0, t1, ceil((t1 - t0) / tau));
    
    px_s = [px_s; calculate_pvt_p(t02t1, cx(n, :))];
    vx_s = [vx_s; calculate_pvt_v(t02t1, cx(n, :))];
    ax_s = [ax_s; calculate_pvt_a(t02t1, cx(n, :))];
    
    py_s = [py_s; calculate_pvt_p(t02t1, cy(n, :))];
    vy_s = [vy_s; calculate_pvt_v(t02t1, cy(n, :))];
    ay_s = [ay_s; calculate_pvt_a(t02t1, cy(n, :))];
end


%% plot
% figure;
% subplot(1, 4, 1);
% plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
% xlim([0 6e-3]);
% ylim([0 4e-3]);
% plot(px_s, py_s, 'b-', 'LineWidth', 2); hold off;
% title('Trajectory');
% axis square;
% 
% subplot(1, 4, 2);
% plot(px_s + py_s, 'LineWidth', 2);
% title('Positions');
% axis square;
% 
% subplot(1, 4, 3);
% plot(vx_s + vy_s, 'LineWidth', 2);
% title('Velicities');
% axis square;
% 
% subplot(1, 4, 4);
% plot(ax_s + ay_s, 'LineWidth', 2);
% title('Accelerations');
% axis square;

%% plot
figure;
subplot(2, 4, 1);
plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
xlim([0 6e-3]);
ylim([0 4e-3]);
plot(px_s, py_s, 'b-', 'LineWidth', 2); hold off;
title('Trajectory');
axis square;

subplot(2, 4, 2);
plot(px_s, 'LineWidth', 2);
title('Positions x');
axis square;

subplot(2, 4, 3);
plot(vx_s, 'LineWidth', 2);
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(ax_s, 'LineWidth', 2);
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(vy_s, 'LineWidth', 2);
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(ay_s, 'LineWidth', 2);
title('Accelerations y');
axis square;

%% t
for i = 1: size(px_s)-1
    tx(i) = abs(px_s(i+1) - px_s(i)) / (0.5 * abs(vx_s(i+1) + vx_s(i)));
    ty(i) = abs(py_s(i+1) - py_s(i)) / (0.5 * abs(vy_s(i+1) + vy_s(i)));
    delta_t(i) = tx(i) - ty(i);
    
    p_s = sqrt(px_s(i)^2 +  py_s(i)^2);
end

total_tx = sum(tx);
total_ty = sum(ty);
 

F = griddedInterpolant(...
    Xtif', ...
    (-Ytif)', ...
    flipud(Ztif)', ...
    'cubic', ...
    'none' ...
);

Zremoval = 0 * Z_to_remove_ca;

for i = 1: size(px_s)-1
    [Zn, xdg, ydg] = feedrate_simulator_maze_path_per_segment(...
            Xca, ...
            Yca, ...
            px_s(i), px_s(i + 1), ...
            py_s(i), py_s(i + 1), ...
            vx_s(i), vx_s(i + 1), ...
            vy_s(i), vy_s(i + 1), ...
            F ...
        );
    Zremoval = Zremoval + Zn;
    Zresidual = Z_to_remove_ca - Zremoval;
    Zresidual = remove_polynomials(Xca, Yca, Zresidual, 1);
    
end

%% display
figure;
subplot(131);
ShowSurfaceMap(X, Y, Z, 3, true, 1e9, 'nm', 'initial map');
subplot(132);
ShowSurfaceMap(Xca, Yca, Zremoval, 3, true, 1e9, 'nm', 'Zremoval');
subplot(133);
ShowSurfaceMap(Xca, Yca, Zresidual, 3, true, 1e9, 'nm', 'Zresidual');
