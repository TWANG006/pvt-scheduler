clear;
% close all;
clc;

outDir = '../../../data/paper_data/';
%% generate a very simple 5-point 2d path
px = [0e-3, 800e-3];
py = [0e-3, 800e-3];
pt = [0, 6];

dt = diff(pt);


%% parameters
ax_max = 0.1;
vx_max = 250e-3; 

ay_max = 0.1;
vy_max = 150e-3;


%% calculate for x and y seperately
% calculate the actual t
[~, tx] = velocities_with_const_acc_scheduler(px, dt, vx_max, ax_max);
[~, ty] = velocities_with_const_acc_scheduler(py, dt, vy_max, ay_max);
dt = max(tx, ty);

% calculate vx & vy using the actual t
[vx, ~] = velocities_with_const_acc_scheduler(px, dt, vx_max, ax_max);
[vy, ~] = velocities_with_const_acc_scheduler(py, dt, vy_max, ay_max);

% calculated positions
[sx, sxa, ~] = velocities_with_const_acc_calculate_s(vx, dt, ax_max);
[sy, sya, ~] = velocities_with_const_acc_calculate_s(vy, dt, ay_max);

px_calc = cumsum([px(1) sx]);
py_calc = cumsum([py(1) sy]);

% figure;
% plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
% plot(px_calc, py_calc, 'b-', 'LineWidth', 2); hold off;


%% sampling
t = cumsum([pt(1) dt]);
tau = 0.01; % 1/20

[px_s, vx_s, tx_s, ax_s] = velocities_with_const_acc_sampler(px, vx, t, ax_max, tau);
[py_s, vy_s, ty_s, ay_s] = velocities_with_const_acc_sampler(py, vy, t, ay_max, tau);

% px_s = [];
% ax_s = [];
% vx_s = [];
% 
% py_s = [];
% ay_s = [];
% vy_s = [];
% 
% for n = 1: length(pt) - 1
%     % 1. generate t's for each segment
%     if n == 1
%         t0 = pt(n);
%     else
%         t0 = pt(n) + tau;
%     end
%     t1 = pt(n + 1);
%     t02t1 = linspace(t0, t1, ceil((t1 - t0) / tau));
%     
%     px_s = [px_s; calculate_pvt_p(t02t1, cx(n, :))];
%     vx_s = [vx_s; calculate_pvt_v(t02t1, cx(n, :))];
%     ax_s = [ax_s; calculate_pvt_a(t02t1, cx(n, :))];
%     
%     py_s = [py_s; calculate_pvt_p(t02t1, cy(n, :))];
%     vy_s = [vy_s; calculate_pvt_v(t02t1, cy(n, :))];
%     ay_s = [ay_s; calculate_pvt_a(t02t1, cy(n, :))];
% end


%% plot
figure;
subplot(2, 4, 1);
plot(px(1: end), py(1: end), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
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
plot(ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold on;
plot(-ones(size(vx_s)) * vx_max,'r--', 'LineWidth', 1); hold off;
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(ax_s, 'LineWidth', 2); hold on;
plot(ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold on;
plot(-ones(size(ax_s)) * ax_max,'r--', 'LineWidth', 1); hold off;
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(vy_s, 'LineWidth', 2); hold on;
plot(ones(size(vy_s)) * vy_max, 'r--', 'LineWidth', 1); hold on;
plot(-ones(size(vy_s)) * vy_max,'r--', 'LineWidth', 1); hold off;
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(ay_s, 'LineWidth', 2); hold on;
plot(ones(size(ay_s)) * ay_max, 'r--', 'LineWidth', 1); hold on;
plot(-ones(size(ay_s)) * ay_max,'r--', 'LineWidth', 1); hold off;
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
plot(tx_s, px_s, 'LineWidth', 2);
title('Positions x');
axis square;

subplot(2, 4, 3);
plot(tx_s, vx_s, 'LineWidth', 2); hold on;
plot(tx_s, ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold on;
plot(tx_s, -ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold off;
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(tx_s, ax_s, 'LineWidth', 2); hold on;
plot(tx_s, ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold on;
plot(tx_s, -ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold off;
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(ty_s, py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(ty_s, vy_s, 'LineWidth', 2); hold on;
plot(ty_s, ones(size(vy_s)) * vy_max, 'r--', 'LineWidth', 1); hold on;
plot(ty_s, -ones(size(vy_s)) * vy_max, 'r--', 'LineWidth', 1); hold off;
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(ty_s, ay_s, 'LineWidth', 2); hold on;
plot(ty_s, ones(size(ay_s)) * ay_max, 'r--', 'LineWidth', 1); hold on;
plot(ty_s, -ones(size(ay_s)) * ay_max, 'r--', 'LineWidth', 1); hold off;
title('Accelerations y');
axis square;

%%
figure;
plot(tx_s, px_s, 'LineWidth', 2);
set(gca,'xtick', []);
set(gca,'ytick', []);

%% Save the cleaned data
outFile = [outDir mfilename '.mat'];

save(outFile, ...
    'tx_s', 'px_s', 'vx_s', 'ax_s' ...
);