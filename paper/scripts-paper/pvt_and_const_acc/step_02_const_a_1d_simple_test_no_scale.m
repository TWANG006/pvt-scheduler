clear;
% close all;
clc;

outDir = '../../../data/paper_data/';
%% generate a very simple 5-point 2d path
% px = [0, 1667, 18333, 20000]; % [pulse]
% pt = [0, 750, 2250, 3000]; % [ms]

px = [0, 1667, 18333, 20000]; % [pulse]
pt = [0, 750, 2250, 3500]; % [ms]

dt = diff(pt);

%% parameters
ax_max = 0.02;
vx_max = 20;

tau = 2;

%% calculate for x and y seperately
% calculate the actual t
[vx, tx] = velocities_with_const_acc_scheduler(px, dt, vx_max, ax_max);


% calculated positions
% [sx, sxa, ~] = velocities_with_const_acc_calculate_s(vx, dt, ax_max); %%1
[sx, sxa, ~] = velocities_with_const_acc_calculate_s(vx, tx, ax_max); %%2

pa = ones(size(tx)) * ax_max;
pa(vx(2: end) - vx(1: end - 1) < 0) = -ax_max;
pa = [pa, 0];

px_calc = cumsum([px(1) sx]);


%% sampling
% t = cumsum([pt(1) dt]); %%1
t = cumsum([pt(1) tx]); %%2

[px_s, vx_s, tx_s, ax_s] = velocities_with_const_acc_sampler(px, vx, t, ax_max, tau);


%% plot - axis x: time
% figure;
figure('Position', [600, 300, 400, 460]);
subplot(3, 1, 1);
plot(tx_s, px_s, 'b', 'LineWidth', 2); hold on;
plot(pt, px, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); hold on;
plot(tx_s, ones(size(px_s)) * px(end), 'r:', 'LineWidth', 1); hold off;
% title('Positions x');
ylim([-1000 25000]);
set(gca,'xtick', []); set(gca,'ytick', []);

subplot(3, 1, 2);
plot(tx_s, vx_s, 'color', [0.929, 0.694, 0.125], 'LineWidth', 2); hold on;
plot(pt, vx, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); hold on;
plot(tx_s, ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold on;
plot(tx_s, ones(size(vx_s)) * 0, 'r:', 'LineWidth', 1); hold on;
plot(tx_s, -ones(size(vx_s)) * vx_max, 'r--', 'LineWidth', 1); hold off;
% title('Velicities x');
ylim([-23 23]);
set(gca,'xtick', []); set(gca,'ytick', []);

subplot(3, 1, 3);
plot(pt, pa, 'ro', 'MarkerSize', 5, 'MarkerFaceColor', 'r'); hold on;
plot(tx_s, ax_s, 'm', 'LineWidth', 2); hold on;
plot(tx_s, ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold on;
plot(tx_s, -ones(size(ax_s)) * ax_max, 'r--', 'LineWidth', 1); hold off;
% title('Accelerations x');
ylim([-0.025 0.025]);
set(gca,'xtick', []); set(gca,'ytick', []);
