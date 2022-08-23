clear;
% close all;
clc;
addpath(genpath('../functions'));
outDir = '../../../data/paper_data/';
%% generate a very simple 5-point 2d path
px = [0e-3, 800e-3, 1300e-3];
py = [0e-3, 800e-3, 1000e-3];
t = [0, 6, 12];

% px = [0e-3, 800e-3];
% py = [0e-3, 800e-3];
% t = [0, 6];

%% parameters
ax_max = 0.15;
vx_max = 250e-3;

ay_max = 0.15;
vy_max = 150e-3;

tau = 0.2;


% % %% calculate pvt for x and y seperately
[vx, ax, cx] = pvt_scheduler(px, t, ax_max, vx_max, true);
[vy, ay, cy] = pvt_scheduler(py, t, ay_max, vy_max, true);


%% simulation
px_s = [];
ax_s = [];
vx_s = [];

py_s = [];
ay_s = [];
vy_s = [];

t_s = [];

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
    
    t_s = [t_s; t02t1'];
end


%% plot
figure;
subplot(2, 4, 1);
plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
% xlim([0 6e-3]);
% ylim([0 4e-3]);
plot(px_s, py_s, 'b-', 'LineWidth', 2); hold off;
title('Trajectory');
axis square;

subplot(2, 4, 2);
plot(px_s, 'LineWidth', 2);
title('Positions x');
axis square;

subplot(2, 4, 3);
plot(vx_s, 'LineWidth', 2); hold on;
plot(ones(size(vx_s)) * vx_max, 'r-', 'LineWidth', 2); hold on;
plot(-ones(size(vx_s)) * vx_max,'r-', 'LineWidth', 2); hold off;
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(ax_s, 'LineWidth', 2); hold on;
plot(ones(size(ax_s)) * ax_max, 'r-', 'LineWidth', 2); hold on;
plot(-ones(size(ax_s)) * ax_max,'r-', 'LineWidth', 2); hold off;
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(vy_s, 'LineWidth', 2); hold on;
plot(ones(size(vy_s)) * vy_max, 'r-', 'LineWidth', 2); hold on;
plot(-ones(size(vy_s)) * vy_max,'r-', 'LineWidth', 2); hold off;
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(ay_s, 'LineWidth', 2); hold on;
plot(ones(size(ay_s)) * ay_max, 'r-', 'LineWidth', 2); hold on;
plot(-ones(size(ay_s)) * ay_max,'r-', 'LineWidth', 2); hold off;
title('Accelerations y');
axis square;

%% plot - axis x: time
figure;
subplot(2, 4, 1);
plot(px(1: end), py(1: end), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
% xlim([0 6e-3]);
% ylim([0 4e-3]);
plot(px_s, py_s, 'b-', 'LineWidth', 2); hold off;
title('Trajectory');
axis square;

subplot(2, 4, 2);
plot(t_s, px_s, '-', 'LineWidth', 2);
title('Positions x');
axis square;

subplot(2, 4, 3);
plot(t_s, vx_s, 'LineWidth', 2); hold on;
plot(t_s, ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold on;
plot(t_s, -ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold off;
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(t_s, ax_s, 'LineWidth', 2); hold on;
plot(t_s, ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold on;
plot(t_s, -ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold off;
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(t_s, py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(t_s, vy_s, 'LineWidth', 2); hold on;
plot(t_s, ones(size(vy_s)) * vy_max, 'r--', 'LineWidth', 1); hold on;
plot(t_s, -ones(size(vy_s)) * vy_max, 'r--', 'LineWidth', 1); hold off;
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(t_s, ay_s, 'LineWidth', 2); hold on;
plot(t_s, ones(size(ay_s)) * ay_max, 'r--', 'LineWidth', 1); hold on;
plot(t_s, -ones(size(ay_s)) * ay_max, 'r--', 'LineWidth', 1); hold off;
title('Accelerations y');
axis square;

%% Save the cleaned data
outFile = [outDir mfilename '.mat'];

save(outFile, ...
    't_s', 'px_s', 'vx_s', 'ax_s' ...
);


