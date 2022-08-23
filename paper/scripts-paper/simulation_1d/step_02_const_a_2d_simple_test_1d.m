clear;
% close all;
clc;

data_dir = '../../../data/paper/';
%% generate a very simple 5-point 2d path
% px = [1e-3, 2e-3, 3.5e-3, 5e-3, 1e-3];
% py = [0, 0, 0, 0, 0];
% pt = [0, 0.1, 0.12, 0.23, 0.3] * 5;

px = [1e-3, 2e-3, 3.5e-3, 5e-3];
py = [0, 0, 0, 0];
pt = [0, 0.09, 0.12, 0.17] * 5;

dt = diff(pt);


%% parameters
ax_max = 2;
vx_max = 250e-3; 

ay_max = 1;
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

figure;
plot(px(1: end-1), py(1: end-1), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'r'); hold on;
plot(px_calc, py_calc, 'b-', 'LineWidth', 2); hold off;


%% sampling
t = cumsum([pt(1) dt]);
tau = 1/60;

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

%% save data
save([data_dir mfilename '.mat'], ...
    'px_s', 'py_s', ...
    'vx_s', 'vy_s', ...
    'ax_s', 'ay_s' ...
    );