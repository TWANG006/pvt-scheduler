clear;
% close all;
clc;
addpath('../../functions/');

%% generate a very simple 5-point 2d path
px = [1e-3, 2e-3, 3.5e-3, 5e-3, 1e-3];
py = [1e-3, 2e-3, 2.5e-3, 1.8e-3, 1e-3];
pt = [0, 0.1, 0.12, 0.23, 0.3] * 5;

t = diff(pt);

%% parameters
ax_max = 2;
vx_max = 250e-3;

ay_max = 1;
vy_max = 150e-3;

tau = 1/20;

%% calculate pvt for x and y seperately
vx = velocities_with_const_acc_scheduler(px, t, vx_max, ax_max);
vy = velocities_with_const_acc_scheduler(py, t, vy_max, ay_max);

% calculated positions
% sx = velocities_with_const_acc_calculate_s(vx, t, ax_max);
% sy = velocities_with_const_acc_calculate_s(vy, t, ay_max);
[sx, sx_a, sx_c, tx_a, tx_c, ax] = velocities_with_const_acc_calculate_s_t(vx, t, ax_max);
[sy, sy_a, sy_c, ty_a, ty_c, ay] = velocities_with_const_acc_calculate_s_t(vy, t, ay_max);

%% simulation
px_s = px(1);
vx_s = vx(1);
ax_s = 0;% ax(1);

py_s = py(1);
vy_s = vy(1);
ay_s = 0;% ay(1);

for n = 1: length(t)
    % 1. generate t's for each segment
    t0 = pt(n);
    t1 = pt(n + 1);
    t02t1 = linspace(t0, t1, ceil((t1 - t0) / tau));
    
    % x-axis sampling
    [px_t02t1, vx_t02t1, ax_t02t1] = calculate_const_acc_pva(...
        t02t1,   ... t02t1
        px(n), ... 
        sx_a(n),   ... s1
        tx_a(n),   ... t1
        ax(n), ... acc
        vx(n), ... v_(k-1)
        vx(n+1) ... v_k
        );
%     if n < length(t)
%         ax_t02t1(end) = ax(n+1); % ax_t02t1(end) is the start of the next part.
%     end
    px_s = [px_s, px_t02t1];
    vx_s = [vx_s, vx_t02t1];
    ax_s = [ax_s, ax_t02t1];
    
    % y-axis sampling
    [py_t02t1, vy_t02t1, ay_t02t1] = calculate_const_acc_pva(...
        t02t1,   ... t02t1
        py(n), ...
        sy_a(n),   ... s1
        ty_a(n),   ... t1
        ay(n), ... acc
        vy(n), ... v_(k-1)
        vy(n+1) ... v_k
        );
%     if n < length(t)
%         ay_t02t1(end) = ay(n+1); % ay_t02t1(end) is the start of the next part.
%     end
    py_s = [py_s, py_t02t1];
    vy_s = [vy_s, vy_t02t1];
    ay_s = [ay_s, ay_t02t1];
    
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
plot(vx_s, 'LineWidth', 2);
hold on;
plot(ones(size(vx_s)) * vx_max, 'r-', 'LineWidth', 2);
plot(-ones(size(vx_s)) * vx_max,'r-', 'LineWidth', 2); hold off;
title('Velicities x');
axis square;

subplot(2, 4, 4);
plot(ax_s, 'LineWidth', 2);
hold on;
plot(ones(size(ax_s)) * ax_max, 'r-', 'LineWidth', 2); hold on;
plot(-ones(size(ax_s)) * ax_max,'r-', 'LineWidth', 2); hold off;
title('Accelerations x');
axis square;

subplot(2, 4, 6);
plot(py_s, 'LineWidth', 2);
title('Positions y');
axis square;

subplot(2, 4, 7);
plot(vy_s, 'LineWidth', 2);
hold on;
plot(ones(size(vy_s)) * vy_max, 'r-', 'LineWidth', 2);
plot(-ones(size(vy_s)) * vy_max,'r-', 'LineWidth', 2); hold off;
title('Velicities y');
axis square;

subplot(2, 4, 8);
plot(ay_s, 'LineWidth', 2);
hold on;
plot(ones(size(ay_s)) * ay_max, 'r-', 'LineWidth', 2); hold on;
plot(-ones(size(ay_s)) * ay_max,'r-', 'LineWidth', 2); hold off;
title('Accelerations y');
axis square;
